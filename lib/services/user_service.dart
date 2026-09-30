import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../models/user.dart' as model;

enum LoginType { firebase, dummyJSON }

class UserService {
  UserService._();

  static final _instance = UserService._();

  factory UserService() => _instance;

  final firebaseAuth = fb.FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  LoginType? loginType;
  bool _busy = false;

  fb.User? get currentUser => firebaseAuth.currentUser;

  Stream<fb.User?> get authStateChanges =>
      firebaseAuth.authStateChanges();

  static const _keys = [
    'loginType',
    'uid',
    'id',
    'username',
    'email',
    'firstName',
    'lastName',
    'gender',
    'image',
    'age',
    'contactNo',
    'accessToken',
    'refreshToken',
    'token',
  ];

  Future<T> _action<T>(
    Future<T> Function() action,
  ) async {
    if (_busy) {
      throw StateError(
        'Please wait for the current request.',
      );
    }

    _busy = true;

    try {
      return await action();
    } finally {
      _busy = false;
    }
  }

  Future<void> initialize() async {
    await firebaseAuth
        .authStateChanges()
        .first
        .timeout(const Duration(seconds: 20));

    final prefs = await SharedPreferences.getInstance();

    if (currentUser != null) {
      loginType = LoginType.firebase;
    } else if (prefs.getString('loginType') != 'firebase' &&
        (prefs.getString('accessToken') ?? '').isNotEmpty) {
      loginType = LoginType.dummyJSON;
    } else {
      loginType = null;
    }
  }

  Future<bool> isLoggedIn() async {
    await initialize();
    return loginType != null;
  }

  Future<Map<String, dynamic>> loginUser(
    String username,
    String password,
  ) {
    return _action(() async {
      final response = await http
          .post(
            Uri.parse('$host/auth/login'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'username': username.trim(),
              'password': password,
              'expiresInMins': 30,
            }),
          )
          .timeout(const Duration(seconds: 20));

      final data = _decode(response);

      if (data['accessToken'] is! String ||
          data['refreshToken'] is! String) {
        throw StateError(
          'The API returned invalid login tokens.',
        );
      }

      await firebaseAuth.signOut();
      await _clear();
      await saveUserData(data);

      return getUserData();
    });
  }

  Future<Map<String, dynamic>> signInDummyJSON({
    required String username,
    required String password,
  }) {
    return loginUser(username, password);
  }

  Future<fb.UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return _action(() async {
      final result =
          await firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      await _clear();

      loginType = LoginType.firebase;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('loginType', 'firebase');

      return result;
    });
  }

  Future<fb.UserCredential> createAccount({
    required String fName,
    required String lName,
    required int age,
    required String contactNo,
    required String username,
    required String emailAddress,
    required String password,
  }) {
    return _action(() async {
      if (fName.trim().isEmpty ||
          fName.trim().length > 100 ||
          lName.trim().isEmpty ||
          lName.trim().length > 100 ||
          age < 1 ||
          age > 120 ||
          !RegExp(r'^\+?[0-9]{7,15}$')
              .hasMatch(contactNo.trim()) ||
          username.trim().length < 3 ||
          username.trim().length > 100 ||
          !validPassword(password)) {
        throw StateError(
          'Please check your signup details '
          'and password requirements.',
        );
      }

      final result =
          await firebaseAuth.createUserWithEmailAndPassword(
        email: emailAddress.trim(),
        password: password,
      );

      final user = result.user!;

      try {
        await user.updateDisplayName(username.trim());

        await _db.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'fName': fName.trim(),
          'lName': lName.trim(),
          'age': age,
          'contactNo': contactNo.trim(),
          'username': username.trim(),
          'emailAddress': user.email!,
        });
      } catch (_) {
        // Roll back the new Auth account if profile setup fails.
        try {
          await user.delete();
        } finally {
          await firebaseAuth.signOut();
        }

        rethrow;
      }

      await _clear();

      loginType = LoginType.firebase;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('loginType', 'firebase');

      return result;
    });
  }

  Future<void> saveUserData(
    Map<String, dynamic> data,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    final id = data['id'];

    if (id is! num) {
      throw StateError('Invalid DummyJSON user ID.');
    }

    await prefs.setInt('id', id.toInt());
    await prefs.setString('loginType', 'dummyJSON');

    for (final key in [
      'username',
      'email',
      'firstName',
      'lastName',
      'gender',
      'image',
    ]) {
      await prefs.setString(
        key,
        data[key]?.toString() ??
            prefs.getString(key) ??
            '',
      );
    }

    if (data['age'] is num) {
      await prefs.setInt(
        'age',
        (data['age'] as num).toInt(),
      );
    }

    if (data['phone'] != null) {
      await prefs.setString(
        'contactNo',
        '${data['phone']}',
      );
    }

    // /auth/me does not return tokens.
    // Keep the existing tokens when refreshing profile data.
    final access =
        data['accessToken']?.toString() ??
        prefs.getString('accessToken') ??
        '';

    final refresh =
        data['refreshToken']?.toString() ??
        prefs.getString('refreshToken') ??
        '';

    await prefs.setString('accessToken', access);
    await prefs.setString('refreshToken', refresh);
    await prefs.setString('token', access);

    loginType = LoginType.dummyJSON;
  }

  Future<Map<String, dynamic>> getUserData() async {
    if (currentUser != null) {
      final user = currentUser!;

      final document =
          await _db.collection('users').doc(user.uid).get();

      final data = document.data() ?? <String, dynamic>{};

      loginType = LoginType.firebase;

      return {
        'loginType': 'firebase',
        'uid': user.uid,

        // Compatibility value, never used as a DummyJSON ID.
        'id': 0,

        'username':
            data['username'] ?? user.displayName ?? '',
        'email': user.email ?? '',
        'emailAddress': user.email ?? '',
        'firstName': data['fName'] ?? '',
        'lastName': data['lName'] ?? '',
        'fName': data['fName'] ?? '',
        'lName': data['lName'] ?? '',
        'age': data['age'],
        'contactNo': data['contactNo'] ?? '',
        'gender': '',
        'image': user.photoURL ?? '',
        'accessToken': '',
        'refreshToken': '',
      };
    }

    final prefs = await SharedPreferences.getInstance();

    if (prefs.getString('loginType') == 'firebase' ||
        (prefs.getString('accessToken') ?? '').isEmpty) {
      throw StateError('Please sign in again.');
    }

    loginType = LoginType.dummyJSON;

    return {
      'loginType': 'dummyJSON',
      'id': prefs.getInt('id') ?? 0,
      'age': prefs.getInt('age'),
      'contactNo': prefs.getString('contactNo') ?? '',
      for (final key in [
        'username',
        'email',
        'firstName',
        'lastName',
        'gender',
        'image',
        'accessToken',
        'refreshToken',
      ])
        key: prefs.getString(key) ?? '',
    };
  }

  Future<model.User> getUser() async {
    return model.User.fromJson(await getUserData());
  }

  Future<Map<String, dynamic>> refreshUser() async {
    await initialize();

    if (loginType == LoginType.firebase) {
      try {
        await currentUser!.reload();
      } on fb.FirebaseAuthException catch (error) {
        if (error.code == 'user-disabled' ||
            error.code == 'user-not-found' ||
            error.code == 'user-token-expired') {
          await logout();
        }

        rethrow;
      }

      if (currentUser == null) {
        await _clear();
        throw StateError('Please sign in again.');
      }

      return getUserData();
    }

    if (loginType != LoginType.dummyJSON) {
      throw StateError('No saved session found.');
    }

    final prefs = await SharedPreferences.getInstance();

    var access = prefs.getString('accessToken') ?? '';

    Future<http.Response> fetchProfile() {
      return http
          .get(
            Uri.parse('$host/auth/me'),
            headers: {
              'Authorization': 'Bearer $access',
            },
          )
          .timeout(const Duration(seconds: 20));
    }

    var response = await fetchProfile();

    if (response.statusCode == 401) {
      final refresh =
          prefs.getString('refreshToken') ?? '';

      if (refresh.isEmpty) {
        await _expired();
      }

      final refreshResponse = await http
          .post(
            Uri.parse('$host/auth/refresh'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'refreshToken': refresh,
              'expiresInMins': 30,
            }),
          )
          .timeout(const Duration(seconds: 20));

      if ([400, 401, 403]
          .contains(refreshResponse.statusCode)) {
        await _expired();
      }

      final tokens = _decode(refreshResponse);

      if (tokens['accessToken'] is! String ||
          tokens['refreshToken'] is! String) {
        throw StateError('Invalid refreshed tokens.');
      }

      access = tokens['accessToken'] as String;

      await prefs.setString('accessToken', access);
      await prefs.setString('token', access);
      await prefs.setString(
        'refreshToken',
        tokens['refreshToken'] as String,
      );

      response = await fetchProfile();
    }

    if ([401, 403].contains(response.statusCode)) {
      await _expired();
    }

    final data = _decode(response);
    data.remove('password');

    await saveUserData(data);

    return {
      ...await getUserData(),
      'age': data['age'],
      'contactNo': data['phone'] ?? '',
    };
  }

  Future<void> updateUsername({
    required String username,
  }) {
    return _action(() async {
      if (username.trim().length < 3 ||
          username.trim().length > 100) {
        throw StateError(
          'Use 3-100 characters for your username.',
        );
      }

      final user = _firebaseUser();
      final oldName = user.displayName;

      await user.updateDisplayName(username.trim());

      try {
        await _db.collection('users').doc(user.uid).update({
          'username': username.trim(),
        });
      } catch (_) {
        await user.updateDisplayName(oldName);
        rethrow;
      }
    });
  }

  Future<void> resetPasswordFromCurrentPassword({
    required String currentPassword,
    required String newPassword,
  }) {
    return _action(() async {
      if (!validPassword(newPassword)) {
        throw StateError('Use a stronger password.');
      }

      final user = _firebaseUser();

      await _reauth(user, currentPassword);
      await user.updatePassword(newPassword);
    });
  }

  Future<void> sendPasswordReset({
    required String email,
  }) {
    return _action(() async {
      await firebaseAuth.sendPasswordResetEmail(
        email: email.trim(),
      );
    });
  }

  Future<void> deleteAccount({
    required String password,
  }) {
    return _action(() async {
      final user = _firebaseUser();

      await _reauth(user, password);

      final reference =
          _db.collection('users').doc(user.uid);

      final backup = (await reference.get()).data();

      await reference.delete();

      try {
        await user.delete();
      } catch (_) {
        if (backup != null) {
          await reference.set(backup);
        }

        rethrow;
      }

      await firebaseAuth.signOut();
      await _clear();
    });
  }

  Future<void> logout() {
    return _action(() async {
      await firebaseAuth.signOut();
      await _clear();
    });
  }

  Future<void> signOut() => logout();

  Future<void> logoutUser() => logout();

  fb.User _firebaseUser() {
    final user = currentUser;

    if (user == null) {
      throw StateError(
        'Use a Firebase account for account changes.',
      );
    }

    return user;
  }

  Future<void> _reauth(
    fb.User user,
    String password,
  ) async {
    if (user.email == null) {
      throw StateError(
        'This account has no email/password login.',
      );
    }

    await user.reauthenticateWithCredential(
      fb.EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      ),
    );
  }

  Future<void> _clear() async {
    final prefs = await SharedPreferences.getInstance();

    for (final key in _keys) {
      await prefs.remove(key);
    }

    loginType = null;
  }

  Future<Never> _expired() async {
    await _clear();

    throw StateError(
      'Session expired. Please sign in again.',
    );
  }

  Map<String, dynamic> _decode(
    http.Response response,
  ) {
    final data = jsonDecode(response.body);

    if (data is! Map<String, dynamic>) {
      throw StateError('Unexpected server response.');
    }

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw StateError(
        '${data['message'] ?? 'Request failed.'}',
      );
    }

    return data;
  }

  static bool validPassword(String value) {
    return value.length >= 8 &&
        RegExp(r'[A-Z]').hasMatch(value) &&
        RegExp(r'[a-z]').hasMatch(value) &&
        RegExp(r'[0-9]').hasMatch(value) &&
        RegExp(r'[^A-Za-z0-9]').hasMatch(value);
  }

  static String errorMessage(Object error) {
    if (error is fb.FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-credential':
        case 'wrong-password':
        case 'user-not-found':
          return 'Incorrect email or password.';

        case 'email-already-in-use':
          return 'This email is already registered.';

        case 'weak-password':
          return 'Use a stronger password.';

        case 'too-many-requests':
          return 'Too many attempts. Try again later.';

        case 'network-request-failed':
          return 'Check your internet connection.';

        case 'operation-not-allowed':
          return 'Enable Email/Password in Firebase Authentication.';

        default:
          return error.message ?? 'Authentication failed.';
      }
    }

    if (error is FirebaseException &&
        error.code == 'permission-denied') {
      return 'Check the Firestore rules in your Firebase project.';
    }

    if (error is TimeoutException) {
      return 'Request timed out. Please try again.';
    }

    if (error is StateError) {
      return '${error.message}';
    }

    return 'Request failed. Check your connection and try again.';
  }
}
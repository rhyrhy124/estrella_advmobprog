import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../services/product_service.dart';
import '../services/user_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _service = UserService();

  late Future<Map<String, dynamic>> _userFuture;
  late Future<List<Product>> _productsFuture;

  bool _busy = false;

  @override
  void initState() {
    super.initState();

    // Loads the profile and products when the screen opens
    _userFuture = _loadProfile();
    _productsFuture = ProductService().getAllProducts();
  }

  // Loads the latest user profile
  Future<Map<String, dynamic>> _loadProfile() async {
    await _service.refreshUser();
    return _service.getUserData();
  }

  // Refreshes the profile and products
  Future<void> _refresh() async {
    if (_busy) return;

    final user = _loadProfile();
    final products = ProductService().getAllProducts();

    setState(() {
      _userFuture = user;
      _productsFuture = products;
    });

    try {
      await Future.wait<dynamic>([user, products]);
    } catch (_) {
      // FutureBuilder displays the error and retry button.
    }
  }

  // Shows a message to the user
  void _message(String text) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  // Handles update username, change password, and delete account
  Future<void> _edit(
    String mode,
    Map<String, dynamic> data,
  ) async {
    if (_busy) return;

    setState(() => _busy = true);

    try {
      // Opens the form for the selected account action
      final values = await showDialog<List<String>>(
        context: context,
        builder: (_) => _AccountDialog(
          mode: mode,
          username: '${data['username'] ?? ''}',
        ),
      );

      if (values == null || !mounted) return;

      final cart = context.read<CartProvider>();

      // Updates the username
      if (mode == 'username') {
        await _service.updateUsername(
          username: values[0],
        );

      // Changes the password
      } else if (mode == 'password') {
        await _service.resetPasswordFromCurrentPassword(
          currentPassword: values[0],
          newPassword: values[1],
        );

      // Deletes the user's account
      } else {
        await _service.deleteAccount(
          password: values[0],
        );

        if (!mounted) return;

        // Clears the current session after deleting the account
        cart.resetSession();

        // Returns to the sign in screen
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/signin',
          (_) => false,
        );

        return;
      }

      if (!mounted) return;

      // Reloads the profile after an account change
      setState(() {
        _userFuture = _loadProfile();
      });

      _message(
        mode == 'username'
            ? 'Username updated.'
            : 'Password updated.',
      );
    } catch (error) {
      _message(UserService.errorMessage(error));
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return RefreshIndicator(
      // Pull down to refresh the profile
      onRefresh: _refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          18.w,
          18.h,
          18.w,
          28.h,
        ),
        children: [
          Text(
            'My profile',
            style: TextStyle(
              fontSize: 25.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Your details, all in one place.',
            style: TextStyle(
              fontSize: 12.sp,
              color: colors.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 20.h),

          // Loads and displays the user's profile
          FutureBuilder<Map<String, dynamic>>(
            future: _userFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return _card(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 40.h,
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                );
              }

              // Shows an error if the profile cannot load
              if (snapshot.hasError || snapshot.data == null) {
                return _card(
                  child: Column(
                    children: [
                      Icon(
                        Icons.person_off_outlined,
                        size: 38.sp,
                        color: colors.onSurfaceVariant,
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        snapshot.hasError
                            ? UserService.errorMessage(
                                snapshot.error!,
                              )
                            : 'No profile found.',
                        textAlign: TextAlign.center,
                      ),
                      TextButton(
                        onPressed: _busy
                            ? null
                            : () {
                                setState(() {
                                  _userFuture = _loadProfile();
                                });
                              },
                        child: const Text('Try again'),
                      ),
                    ],
                  ),
                );
              }

              final data = snapshot.data!;

              // Checks if the user is using Firebase
              final firebase = data['loginType'] == 'firebase';

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Shows the user's profile header
                  _header(data, firebase),

                  SizedBox(height: 22.h),

                  // Personal information
                  _section(
                    'Personal information',
                    'Your account details',
                  ),

                  SizedBox(height: 12.h),
                  _card(
                    child: Column(
                      children: [
                        _info(
                          Icons.mail_outline_rounded,
                          'Email address',
                          '${data['email'] ?? ''}',
                        ),
                        _divider(),
                        _info(
                          Icons.alternate_email_rounded,
                          'Username',
                          '${data['username'] ?? ''}',
                        ),
                        _divider(),
                        _info(
                          Icons.cake_outlined,
                          'Age',
                          '${data['age'] ?? ''}',
                        ),
                        _divider(),
                        _info(
                          Icons.phone_outlined,
                          'Contact number',
                          '${data['contactNo'] ?? ''}',
                        ),

                        // Shows gender for DummyJSON users
                        if (!firebase &&
                            '${data['gender'] ?? ''}'.isNotEmpty) ...[
                          _divider(),
                          _info(
                            Icons.person_outline_rounded,
                            'Gender',
                            '${data['gender']}',
                          ),
                        ],
                      ],
                    ),
                  ),

                  SizedBox(height: 22.h),

                  // Account management features
                  _section(
                    'Manage account',
                    'Keep your details up to date',
                  ),

                  SizedBox(height: 12.h),

                  // Account changes are only available for Firebase users
                  if (!firebase)
                    Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: Text(
                        'Account changes are available when you '
                        'sign in with Firebase.',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),

                  _card(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        // Update username feature
                        _action(
                          Icons.edit_outlined,
                          'Update username',
                          'Change your display name',
                          enabled: firebase && !_busy,
                          onTap: () => _edit('username', data),
                        ),
                        _divider(),

                        // Change password feature
                        _action(
                          Icons.lock_outline_rounded,
                          'Change password',
                          'Update your account password',
                          enabled: firebase && !_busy,
                          onTap: () => _edit('password', data),
                        ),
                        _divider(),

                        // Delete account feature
                        _action(
                          Icons.delete_outline_rounded,
                          'Delete account',
                          'Permanently remove your account',
                          danger: true,
                          enabled: firebase && !_busy,
                          onTap: () => _edit('delete', data),
                        ),
                      ],
                    ),
                  ),

                  if (_busy)
                    Padding(
                      padding: EdgeInsets.only(top: 12.h),
                      child: const LinearProgressIndicator(),
                    ),
                ],
              );
            },
          ),

          SizedBox(height: 24.h),

          // Shows the user's order overview
          _section(
            'My Items',
            'Your order overview',
          ),

          SizedBox(height: 12.h),
          _card(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Orders waiting for payment
                _order(
                  Icons.account_balance_wallet_outlined,
                  'To Pay',
                ),

                // Orders waiting to be shipped
                _order(
                  Icons.local_shipping_outlined,
                  'To Ship',
                ),

                // Orders waiting to be received
                _order(
                  Icons.inventory_2_outlined,
                  'To Receive',
                ),
              ],
            ),
          ),

          SizedBox(height: 24.h),

          // Recommended products
          _section(
            'Recommended for you',
            'A few finds you might like',
          ),

          SizedBox(height: 12.h),

          // Loads products for recommendations
          FutureBuilder<List<Product>>(
            future: _productsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return Padding(
                  padding: EdgeInsets.all(24.r),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              // Shows an error if products cannot load
              if (snapshot.hasError) {
                return _card(
                  child: Column(
                    children: [
                      const Text(
                        'Could not load recommendations.',
                      ),
                      TextButton(
                        onPressed: () {
                          // Tries to load the products again
                          setState(() {
                            _productsFuture =
                                ProductService().getAllProducts();
                          });
                        },
                        child: const Text('Try again'),
                      ),
                    ],
                  ),
                );
              }

              // Gets the first two products for recommendations
              final products =
                  snapshot.data?.take(2).toList() ?? <Product>[];

              if (products.isEmpty) {
                return _card(
                  child: const Text('No recommendations yet.'),
                );
              }

              return LayoutBuilder(
                builder: (context, constraints) {
                  final columns =
                      constraints.maxWidth < 300 ? 1 : 2;

                  final gap = 12.w;

                  final width =
                      (constraints.maxWidth -
                          gap * (columns - 1)) /
                      columns;

                  return Wrap(
                    spacing: gap,
                    runSpacing: 12.h,
                    children: [
                      for (final product in products)
                        SizedBox(
                          width: width,
                          child: _productCard(product),
                        ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _card({
    required Widget child,
    EdgeInsetsGeometry? padding,
  }) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: padding ?? EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: colors.outlineVariant.withValues(
            alpha: 0.5,
          ),
        ),
      ),
      child: child,
    );
  }

  // Shows the user's name, photo, and account type
  Widget _header(
    Map<String, dynamic> data,
    bool firebase,
  ) {
    final colors = Theme.of(context).colorScheme;

    final name =
        '${data['firstName'] ?? ''} '
                '${data['lastName'] ?? ''}'
            .trim();

    final username = '${data['username'] ?? ''}'.trim();

    final displayName = name.isNotEmpty
        ? name
        : username.isNotEmpty
        ? username
        : 'Bulldog member';

    final image = '${data['image'] ?? ''}';

    final fallback = Icon(
      Icons.person_rounded,
      size: 38.sp,
      color: colors.primary,
    );

    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.primaryContainer,
            colors.surface,
          ],
        ),
        border: Border.all(
          color: colors.primary.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 88.r,
            height: 88.r,
            padding: EdgeInsets.all(4.r),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.surface,
            ),
            child: ClipOval(
              child: ColoredBox(
                color: colors.primary.withValues(alpha: 0.08),

                // Shows the user's image or a default icon
                child: image.isEmpty
                    ? Center(child: fallback)
                    : Image.network(
                        image,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, trace) {
                          return Center(child: fallback);
                        },
                      ),
              ),
            ),
          ),
          SizedBox(height: 14.h),
          Text(
            displayName,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (username.isNotEmpty) ...[
            SizedBox(height: 4.h),
            Text(
              '@$username',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
          SizedBox(height: 12.h),

          // Shows if the account is Firebase or DummyJSON
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 6.h,
            ),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(30.r),
            ),
            child: Text(
              firebase
                  ? 'Firebase account'
                  : 'DummyJSON account',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: colors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 3.h),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 11.sp,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _divider() {
    return Divider(
      height: 1,
      thickness: 0.6,
      color: Theme.of(context).colorScheme.outlineVariant
          .withValues(alpha: 0.5),
    );
  }

  // Shows one profile information item
  Widget _info(
    IconData icon,
    String label,
    String value,
  ) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 11.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(9.r),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              icon,
              size: 20.sp,
              color: colors.primary,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: colors.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  value.trim().isEmpty ? 'Not provided' : value,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Creates an account action button
  Widget _action(
    IconData icon,
    String title,
    String subtitle, {
    required bool enabled,
    required VoidCallback onTap,
    bool danger = false,
  }) {
    final colors = Theme.of(context).colorScheme;

    final color = !enabled
        ? colors.onSurface.withValues(alpha: 0.35)
        : danger
        ? colors.error
        : colors.primary;

    return ListTile(
      enabled: enabled,
      onTap: enabled ? onTap : null,
      contentPadding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 6.h,
      ),
      leading: Container(
        padding: EdgeInsets.all(9.r),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(
          icon,
          size: 20.sp,
          color: color,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
          color: danger || !enabled
              ? color
              : colors.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 10.sp),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        size: 20.sp,
        color: color,
      ),
    );
  }

  // Shows one order status
  Widget _order(IconData icon, String label) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary
                  .withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 24.sp,
            ),
          ),
          SizedBox(height: 9.h),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // Shows one recommended product
  Widget _productCard(Product product) {
    final colors = Theme.of(context).colorScheme;

    return _card(
      padding: EdgeInsets.all(12.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120.h,
            width: double.infinity,
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Image.network(
              product.thumbnail,
              fit: BoxFit.contain,
              errorBuilder: (context, error, trace) {
                return Icon(
                  Icons.image_outlined,
                  color: colors.onSurfaceVariant,
                );
              },
            ),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            height: 42.h,
            child: Text(
              product.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            '₱${product.price.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: colors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// Dialog used for account changes
class _AccountDialog extends StatefulWidget {
  const _AccountDialog({
    required this.mode,
    required this.username,
  });

  final String mode;
  final String username;

  @override
  State<_AccountDialog> createState() => _AccountDialogState();
}

class _AccountDialogState extends State<_AccountDialog> {
  final _form = GlobalKey<FormState>();

  final _first = TextEditingController();
  final _second = TextEditingController();
  final _confirm = TextEditingController();

  bool _visible = false;

  @override
  void initState() {
    super.initState();

    // Shows the current username when updating it
    if (widget.mode == 'username') {
      _first.text = widget.username;
    }
  }

  @override
  void dispose() {
    _first.dispose();
    _second.dispose();
    _confirm.dispose();
    super.dispose();
  }

  InputDecoration _field(
    String label, {
    String? helper,
    bool password = false,
  }) {
    return InputDecoration(
      labelText: label,
      helperText: helper,
      helperMaxLines: 3,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),

      // Show or hide password
      suffixIcon: password
          ? IconButton(
              onPressed: () {
                setState(() => _visible = !_visible);
              },
              icon: Icon(
                _visible
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final username = widget.mode == 'username';
    final password = widget.mode == 'password';
    final deleting = widget.mode == 'delete';

    final colors = Theme.of(context).colorScheme;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      title: Text(
        username
            ? 'Update username'
            : password
            ? 'Change password'
            : 'Delete account',
      ),
      content: SizedBox(
        width: 360,
        child: SingleChildScrollView(
          child: Form(
            key: _form,

            // Checks the fields while the user is typing
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Shows a warning before deleting the account
                if (deleting)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Text(
                      'Your account and profile will be permanently '
                      'deleted. Enter your current password to confirm.',
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),

                TextFormField(
                  controller: _first,
                  obscureText: !username && !_visible,
                  decoration: _field(
                    username
                        ? 'New username'
                        : 'Current password',
                    password: !username,
                  ),
                  validator: (value) {
                    // Checks if the field is empty
                    if (value == null || value.trim().isEmpty) {
                      return 'Required';
                    }

                    // Checks the username length
                    if (username &&
                        (value.trim().length < 3 ||
                            value.trim().length > 100)) {
                      return 'Use 3-100 characters';
                    }

                    return null;
                  },
                ),

                // New password fields
                if (password) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _second,
                    obscureText: !_visible,
                    decoration: _field(
                      'New password',
                      helper: '8+ characters with uppercase, '
                          'lowercase, a number and a symbol.',
                      password: true,
                    ),
                    validator: (value) {
                      // Checks if the new password is strong
                      if (value == null ||
                          !UserService.validPassword(value)) {
                        return 'Use a stronger password';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirm,
                    obscureText: !_visible,
                    decoration: _field(
                      'Confirm new password',
                      password: true,
                    ),
                    validator: (value) {
                      // Checks if both passwords match
                      if (value != _second.text) {
                        return 'Passwords do not match';
                      }

                      return null;
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        // Cancels the account change
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),

        // Saves the change or deletes the account
        FilledButton(
          style: deleting
              ? FilledButton.styleFrom(
                  backgroundColor: colors.error,
                  foregroundColor: colors.onError,
                )
              : null,
          onPressed: () {
            // Continues only when the form is valid
            if (_form.currentState!.validate()) {
              Navigator.pop(
                context,
                [_first.text, _second.text],
              );
            }
          },
          child: Text(
            deleting ? 'Delete account' : 'Save changes',
          ),
        ),
      ],
    );
  }
}
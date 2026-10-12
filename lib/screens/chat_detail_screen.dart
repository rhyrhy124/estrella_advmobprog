
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/chat_service.dart';

class ChatDetailScreen extends StatefulWidget {
  final String currentUserEmail;
  final Map<String, dynamic> tappedUser;

  const ChatDetailScreen({
    super.key,
    required this.currentUserEmail,
    required this.tappedUser,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isSending = false;
  bool _statusUpdateRunning = false;

  Map<String, dynamic>? _receiverProfile;

  String get _currentUserId =>
      FirebaseAuth.instance.currentUser?.uid ?? '';

  String get _receiverId =>
      (widget.tappedUser['uid'] ?? '').toString();

  String get _receiverName {
    final profile = _receiverProfile ?? widget.tappedUser;

    final firstName =
        (profile['firstName'] ?? profile['fName'] ?? '')
            .toString()
            .trim();

    final lastName =
        (profile['lastName'] ?? profile['lName'] ?? '')
            .toString()
            .trim();

    final fullName = '$firstName $lastName'.trim();

    if (fullName.isNotEmpty) return fullName;

    final username = (profile['username'] ?? '').toString().trim();

    return username.isNotEmpty ? username : 'Chat';
  }

  String get _receiverImageUrl {
    final profile = _receiverProfile ?? widget.tappedUser;

    return (
      profile['profileImage'] ??
      profile['profileImageUrl'] ??
      profile['photoURL'] ??
      profile['photoUrl'] ??
      ''
    ).toString();
  }

  @override
  void initState() {
    super.initState();
    _loadReceiverProfile();
  }

  // Load the recipient using the selected user's actual Firebase UID.
  Future<void> _loadReceiverProfile() async {
    final receiverId = _receiverId;
    final currentUserId = _currentUserId;

    if (receiverId.isEmpty || receiverId == currentUserId) {
      debugPrint(
        'CHAT RECIPIENT ERROR: '
        'receiverId=$receiverId, currentUserId=$currentUserId',
      );
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(receiverId)
          .get();

      if (!doc.exists) {
        debugPrint('CHAT RECIPIENT PROFILE NOT FOUND: $receiverId');
        return;
      }

      if (!mounted) return;

      final data = doc.data()!;

      setState(() {
        _receiverProfile = {
          ...data,
          'uid': doc.id,
          'firstName': data['fName'] ?? data['firstName'] ?? '',
          'lastName': data['lName'] ?? data['lastName'] ?? '',
          'username': data['username'] ?? '',
          'email': data['emailAddress'] ?? data['email'] ?? '',
          'profileImage': data['profileImage'] ??
              data['profileImageUrl'] ??
              data['photoURL'] ??
              data['photoUrl'] ??
              '',
        };
      });

      debugPrint(
        'CHAT DEBUG: currentUserId=$currentUserId, '
        'receiverId=$receiverId, '
        'receiverName=$_receiverName',
      );
    } catch (error) {
      debugPrint('Failed to load recipient profile: $error');
    }
  }

  Widget _buildAvatar({
    required String name,
    required double radius,
    String? imageUrl,
  }) {
    final colors = Theme.of(context).colorScheme;
    final url = (imageUrl ?? '').trim();

    return CircleAvatar(
      radius: radius,
      backgroundColor: colors.primaryContainer,
      foregroundColor: colors.onPrimaryContainer,
      backgroundImage: url.isNotEmpty ? NetworkImage(url) : null,
      onBackgroundImageError: url.isNotEmpty
          ? (exception, stackTrace) {}
          : null,
      child: url.isNotEmpty
          ? null
          : Icon(
              Icons.person_rounded,
              size: radius * 1.15,
              color: colors.onPrimaryContainer,
            ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();

    if (text.isEmpty || _isSending) return;

    setState(() => _isSending = true);

    try {
      await _chatService.sendMessage(_receiverId, text);
      _messageController.clear();

      if (_scrollController.hasClients) {
        await _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Message was not sent. Please try again. ($error)',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  Future<void> _updateIncomingStatuses() async {
    if (_statusUpdateRunning) return;

    _statusUpdateRunning = true;

    try {
      await _chatService.markMessagesDelivered(_receiverId);
      await _chatService.markMessagesRead(_receiverId);
    } catch (error) {
      debugPrint('Message status update failed: $error');
    } finally {
      _statusUpdateRunning = false;
    }
  }

  String _formatTime(Timestamp timestamp) {
    final date = timestamp.toDate();
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }

  Widget _buildStatus(
    Map<String, dynamic> data,
    Color normalColor,
    Color seenColor,
  ) {
    final status = (data['status'] ?? 'sent').toString();

    IconData icon;
    String label;
    Color color;

    switch (status) {
      case 'read':
        icon = Icons.done_all;
        label = 'Seen';
        color = seenColor;
        break;
      case 'delivered':
        icon = Icons.done_all;
        label = 'Delivered';
        color = normalColor;
        break;
      default:
        icon = Icons.check;
        label = 'Sent';
        color = normalColor;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: color),
        ),
      ],
    );
  }

  Widget _buildMessageBubble(
    Map<String, dynamic> data,
    bool isMe,
    ColorScheme colors,
    int index,
  ) {
    final bubbleColor =
        isMe ? colors.primary : colors.surfaceContainerHighest;

    final textColor = isMe ? colors.onPrimary : colors.onSurface;

    final timeColor = isMe
        ? colors.onPrimary.withValues(alpha: 0.75)
        : colors.onSurfaceVariant;

    final message = (data['message'] ?? '').toString();

    final timestamp = data['timestamp'] is Timestamp
        ? data['timestamp'] as Timestamp
        : Timestamp.now();

    final messageContent = Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.72,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: bubbleColor,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(isMe ? 18 : 5),
          bottomRight: Radius.circular(isMe ? 5 : 18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              message,
              style: TextStyle(
                color: textColor,
                fontSize: 15,
                height: 1.35,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _formatTime(timestamp),
                style: TextStyle(
                  fontSize: 10,
                  color: timeColor,
                ),
              ),
              if (isMe) ...[
                const SizedBox(width: 6),
                _buildStatus(
                  data,
                  timeColor,
                  colors.tertiary,
                ),
              ],
            ],
          ),
        ],
      ),
    );

    return TweenAnimationBuilder<double>(
      key: ValueKey('${timestamp.toDate()}_$index'),
      tween: Tween(begin: 0, end: 1),
      duration: Duration(
        milliseconds: 180 + (index.clamp(0, 5) * 35),
      ),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 8),
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 5,
        ),
        child: Row(
          mainAxisAlignment:
              isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isMe) ...[
              _buildAvatar(
                name: _receiverName,
                radius: 16,
                imageUrl: _receiverImageUrl,
              ),
              const SizedBox(width: 7),
            ],
            Flexible(child: messageContent),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (_currentUserId.isEmpty ||
        _receiverId.isEmpty ||
        _currentUserId == _receiverId) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chat')),
        body: const Center(
          child: Text('Unable to open this conversation.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            _buildAvatar(
              name: _receiverName,
              radius: 20,
              imageUrl: _receiverImageUrl,
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Text(
                _receiverName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _chatService.getMessages(
                _currentUserId,
                _receiverId,
              ),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Unable to load messages.'),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final docs = snapshot.data?.docs ?? [];

                if (docs.isNotEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      _updateIncomingStatuses();
                    }
                  });
                }

                if (docs.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildAvatar(
                            name: _receiverName,
                            radius: 30,
                            imageUrl: _receiverImageUrl,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Say hello to $_receiverName!',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Send a message to start the conversation.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data();
                    final senderId = (data['senderId'] ?? '').toString();
                    final isMe = senderId == _currentUserId;

                    return _buildMessageBubble(
                      data,
                      isMe,
                      colors,
                      index,
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              decoration: BoxDecoration(
                color: colors.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      minLines: 1,
                      maxLines: 5,
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        filled: true,
                        fillColor: colors.surfaceContainerHighest,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    tooltip: 'Send message',
                    onPressed: _isSending ? null : _sendMessage,
                    icon: _isSending
                        ? const SizedBox(
                            width: 19,
                            height: 19,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
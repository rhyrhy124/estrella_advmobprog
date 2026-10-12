import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/chat_service.dart';
import 'chat_detail_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';

  String _displayName(Map<String, dynamic> user) {
    final firstName =
        (user['firstName'] ?? user['fName'] ?? '').toString().trim();
    final lastName =
        (user['lastName'] ?? user['lName'] ?? '').toString().trim();

    final fullName = '$firstName $lastName'.trim();

    if (fullName.isNotEmpty) return fullName;

    final username = (user['username'] ?? '').toString().trim();

    if (username.isNotEmpty) return username;

    return 'Unknown user';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openConversation({
    required String userId,
    required String name,
    String email = '',
  }) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null || userId.isEmpty) return;

    // Never open a conversation with the currently signed-in user.
    if (userId == currentUser.uid) {
      debugPrint('CHAT ERROR: Cannot open a chat with yourself.');
      return;
    }

    debugPrint(
      'OPEN CHAT: currentUserId=${currentUser.uid}, '
      'receiverId=$userId, selectedName=$name',
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatDetailScreen(
          currentUserEmail: currentUser.email ?? '',
          tappedUser: {
            // This must be the recipient's actual Firebase Auth UID.
            'uid': userId,
            'firstName': name,
            'lastName': '',
            'username': name,
            'email': email,
          },
        ),
      ),
    );
  }

  Future<void> _showNewChatSheet() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) return;

    final searchController = TextEditingController();
    String query = '';

    try {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (sheetContext) {
          final colors = Theme.of(sheetContext).colorScheme;

          return StatefulBuilder(
            builder: (context, setSheetState) {
              return SafeArea(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.75,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'New Chat',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            IconButton(
                              tooltip: 'Close',
                              onPressed: () => Navigator.pop(sheetContext),
                              icon: const Icon(Icons.close),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: TextField(
                          controller: searchController,
                          onChanged: (value) {
                            setSheetState(() => query = value.trim());
                          },
                          decoration: InputDecoration(
                            hintText: 'Search by name...',
                            prefixIcon: const Icon(Icons.search),
                            filled: true,
                            fillColor: colors.surfaceContainerHighest,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: StreamBuilder<List<Map<String, dynamic>>>(
                          stream: _chatService.getUsersStream(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return const Center(
                                child: Text('Could not load users.'),
                              );
                            }

                            if (snapshot.connectionState ==
                                    ConnectionState.waiting &&
                                !snapshot.hasData) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            final users = snapshot.data ?? [];

                            final filteredUsers = users.where((user) {
                              final name = _displayName(user).toLowerCase();
                              return name.contains(query.toLowerCase());
                            }).toList();

                            if (filteredUsers.isEmpty) {
                              return const Center(
                                child: Text('No users found.'),
                              );
                            }

                            return ListView.separated(
                              padding:
                                  const EdgeInsets.fromLTRB(12, 4, 12, 16),
                              itemCount: filteredUsers.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 2),
                              itemBuilder: (context, index) {
                                final user = filteredUsers[index];
                                final name = _displayName(user);

                                // getUsersStream supplies the Firestore
                                // document ID as the actual UID.
                                final uid =
                                    (user['uid'] ?? '').toString().trim();

                                final email =
                                    (user['email'] ?? '').toString();

                                return ListTile(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  leading: CircleAvatar(
                                    backgroundColor: colors.primaryContainer,
                                    foregroundColor:
                                        colors.onPrimaryContainer,
                                    child: Text(
                                      name.isNotEmpty
                                          ? name[0].toUpperCase()
                                          : '?',
                                    ),
                                  ),
                                  title: Text(
                                    name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  onTap: () {
                                    if (uid.isEmpty ||
                                        uid == currentUser.uid) {
                                      debugPrint(
                                        'CHAT ERROR: Invalid recipient UID: '
                                        '$uid',
                                      );
                                      return;
                                    }

                                    Navigator.pop(sheetContext);

                                    _openConversation(
                                      userId: uid,
                                      name: name,
                                      email: email,
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
    } finally {
      searchController.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chats',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'New Chat',
            onPressed: _showNewChatSheet,
            icon: const Icon(Icons.edit_square),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() => _searchQuery = value.trim());
              },
              decoration: InputDecoration(
                hintText: 'Search chats by name...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: colors.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _chatService.getConversationsStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Unable to load chats. Check your Firestore rules.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final conversations = snapshot.data ?? [];

                final filteredConversations = conversations.where((chat) {
                  final name =
                      (chat['otherName'] ?? '').toString().toLowerCase();

                  return name.contains(_searchQuery.toLowerCase());
                }).toList();

                if (filteredConversations.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 58,
                            color: colors.primary.withValues(alpha: 0.65),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            _searchQuery.isEmpty
                                ? 'No messages yet'
                                : 'No chats found',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _searchQuery.isEmpty
                                ? 'Tap the new chat icon to send your first message.'
                                : 'Try searching with another name.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                          if (_searchQuery.isEmpty) ...[
                            const SizedBox(height: 16),
                            FilledButton.icon(
                              onPressed: _showNewChatSheet,
                              icon: const Icon(Icons.edit),
                              label: const Text('Start a Chat'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                  itemCount: filteredConversations.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 3),
                  itemBuilder: (context, index) {
                    final chat = filteredConversations[index];

                    final name =
                        (chat['otherName'] ?? 'Unknown user').toString();

                    final otherUserId =
                        (chat['otherUserId'] ?? '').toString();

                    final lastMessage =
                        (chat['lastMessage'] ?? '').toString();

                    final lastSenderId =
                        (chat['lastSenderId'] ?? '').toString();

                    final currentUserId =
                        FirebaseAuth.instance.currentUser?.uid ?? '';

                    final preview = lastSenderId == currentUserId
                        ? 'You: $lastMessage'
                        : lastMessage;

                    final timestamp = chat['lastMessageAt'] is Timestamp
                        ? chat['lastMessageAt'] as Timestamp
                        : Timestamp(0, 0);

                    final time = _formatListTime(timestamp);

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      leading: CircleAvatar(
                        radius: 27,
                        backgroundColor: colors.primaryContainer,
                        foregroundColor: colors.onPrimaryContainer,
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : '?',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      title: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text(
                          preview.isEmpty ? 'Start a conversation' : preview,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                      trailing: Text(
                        time,
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                      ),
                      onTap: () {
                        _openConversation(
                          userId: otherUserId,
                          name: name,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatListTime(Timestamp timestamp) {
    final date = timestamp.toDate();
    final now = DateTime.now();

    final isToday = date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;

    if (isToday) {
      final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
      final minute = date.minute.toString().padLeft(2, '0');
      final period = date.hour >= 12 ? 'PM' : 'AM';

      return '$hour:$minute $period';
    }

    final yesterday = now.subtract(const Duration(days: 1));

    final isYesterday = date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;

    if (isYesterday) return 'Yesterday';

    return '${date.month}/${date.day}/${date.year}';
  }
}
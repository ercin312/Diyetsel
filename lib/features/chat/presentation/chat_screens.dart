import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:just_audio/just_audio.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/data/app_store.dart';
import '../../../core/data/providers.dart';
import '../../../core/data/seed_data.dart';
import '../../../core/models/enums.dart';
import '../../../core/models/models.dart';
import '../../../core/widgets/app_page.dart';
import '../../../core/widgets/diyetsel_widgets.dart';
import '../../auth/presentation/auth_controller.dart';
import 'soft_chat_screen.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (context.isModern) {
      return const SoftChatListScreen();
    }

    final user = ref.watch(authControllerProvider).user!;
    final threads = ref.watch(chatsProvider(user.id)).valueOrNull ?? [];
    final cartoon = context.isCartoon;
    return AppPage(
      title: 'Sohbet',
      fab: user.isAdmin
          ? null
          : FloatingActionButton(
              backgroundColor: cartoon ? AppColors.kawaiiLeaf : null,
              foregroundColor: cartoon ? Colors.white : null,
              onPressed: () async {
                final store = ref.read(appStoreProvider);
                final admin = store.user(SeedData.adminId) ?? store.users().firstWhere((u) => u.isAdmin);
                final thread = await store.ensureThread(user, admin);
                if (context.mounted) {
                  Navigator.push(context, MaterialPageRoute<void>(builder: (_) => ChatRoomScreen(thread: thread)));
                }
              },
              child: const Icon(Icons.chat),
            ),
      child: cartoon
          ? ColoredBox(
              color: AppColors.kawaiiSurfaceCream,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.kawaiiPeach.withValues(alpha: 0.7),
                          AppColors.kawaiiMint.withValues(alpha: 0.65),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.kawaiiOutline),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.favorite_rounded, color: AppColors.kawaiiCoral, size: 22),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Diyetisyeninle buradan yazış — sorularını kısa ve net tut, yanıt daha hızlı gelir.',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              height: 1.35,
                              color: AppColors.kawaiiInk,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 280.ms),
                  const SizedBox(height: 14),
                  if (threads.isEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: AppColors.kawaiiOutline),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.chat_bubble_outline_rounded, size: 48, color: AppColors.kawaiiLeaf.withValues(alpha: 0.7)),
                          const SizedBox(height: 12),
                          const Text(
                            'Henüz mesaj yok',
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: AppColors.kawaiiInk),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            user.isAdmin
                                ? 'Danışanlar yazınca sohbetler burada görünecek.'
                                : 'Sağ alttaki butonla diyetisyene ilk mesajını gönder.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.kawaiiMuted),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 40.ms, duration: 300.ms)
                  else
                    for (var i = 0; i < threads.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute<void>(builder: (_) => ChatRoomScreen(thread: threads[i])),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: AppColors.kawaiiOutline),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: AppColors.kawaiiMint,
                                    child: Text(
                                      () {
                                        final name = threads[i]
                                            .participantNames
                                            .where((n) => n != user.displayName)
                                            .join(', ');
                                        return name.isEmpty ? '?' : name.substring(0, 1).toUpperCase();
                                      }(),
                                      style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.kawaiiLeafDeep),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          threads[i].participantNames.where((n) => n != user.displayName).join(', '),
                                          style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.kawaiiInk),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          threads[i].lastMessage,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.kawaiiMuted),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right_rounded, color: AppColors.kawaiiMuted),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ).animate().fadeIn(delay: (40 * i).ms, duration: 280.ms),
                ],
              ),
            )
          : threads.isEmpty
              ? const EmptyState(icon: Icons.chat, title: 'Henüz mesaj yok')
              : ListView(
                  children: [
                    for (final t in threads)
                      ListTile(
                        title: Text(t.participantNames.where((n) => n != user.displayName).join(', ')),
                        subtitle: Text(t.lastMessage),
                        onTap: () =>
                            Navigator.push(context, MaterialPageRoute<void>(builder: (_) => ChatRoomScreen(thread: t))),
                      ),
                  ],
                ),
    );
  }
}

class ChatRoomScreen extends ConsumerStatefulWidget {
  const ChatRoomScreen({super.key, required this.thread});
  final ChatThread thread;

  @override
  ConsumerState<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends ConsumerState<ChatRoomScreen> {
  final _text = TextEditingController();
  final _player = AudioPlayer();

  @override
  void dispose() {
    _text.dispose();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (context.isModern) {
      return SoftChatRoomScreen(thread: widget.thread);
    }

    final user = ref.watch(authControllerProvider).user!;
    final messages = ref.watch(messagesProvider(widget.thread.id)).valueOrNull ?? [];
    return Scaffold(
      appBar: AppBar(title: Text(widget.thread.participantNames.where((n) => n != user.displayName).join(', '))),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (context, i) {
                final m = messages[i];
                final mine = m.senderId == user.id;
                final cartoon = context.isCartoon;
                final bubbleRadius = cartoon ? 26.0 : (20.0);
                Widget bubble = Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.all(12),
                  constraints: const BoxConstraints(maxWidth: 320),
                  decoration: BoxDecoration(
                    color: cartoon
                        ? (mine
                            ? AppColors.kawaiiCoral.withValues(alpha: 0.22)
                            : AppColors.kawaiiMint.withValues(alpha: 0.9))
                        : (mine
                            ? context.brandPrimary
                            : Theme.of(context).colorScheme.surfaceContainerHighest),
                    borderRadius: BorderRadius.circular(bubbleRadius),
                    border: null,
                    boxShadow: cartoon
                        ? const [
                            BoxShadow(
                              color: AppColors.kawaiiShadow,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: m.type == ChatMediaType.text
                      ? Text(
                          m.content,
                          style: TextStyle(
                            color: cartoon
                                ? AppColors.kawaiiInk
                                : (mine ? Colors.white : null),
                          ),
                        )
                      : TextButton(
                          onPressed: () async {
                            try {
                              await _player.setFilePath(m.content);
                              await _player.play();
                            } catch (_) {}
                          },
                          child: Text(
                            '${m.type.name}: ${m.content.split(RegExp(r'[\\/]')).last}',
                            style: TextStyle(
                              color: cartoon
                                  ? AppColors.kawaiiInk
                                  : (mine ? Colors.white : null),
                            ),
                          ),
                        ),
                );
                if (cartoon) {
                  bubble = bubble
                      .animate()
                      .fadeIn(duration: 220.ms)
                      .scale(begin: const Offset(0.92, 0.92), curve: Curves.easeOutBack, duration: 320.ms);
                }
                return Align(
                  alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
                  child: bubble,
                );
              },
            ),
          ),
          SafeArea(
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.photo),
                  onPressed: () async {
                    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
                    if (file == null) return;
                    await _send(user, file.path, ChatMediaType.image);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  onPressed: () async {
                    final files = await FilePicker.pickFiles();
                    final path = files.isEmpty ? null : files.first.path;
                    if (path == null) return;
                    await _send(user, path, ChatMediaType.file);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.mic),
                  onPressed: () async {
                    final files = await FilePicker.pickFiles(type: FileType.audio);
                    final path = files.isEmpty ? null : files.first.path;
                    if (path == null) return;
                    await _send(user, path, ChatMediaType.audio);
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _text,
                    decoration: const InputDecoration(hintText: 'Mesaj yazın'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () async {
                    if (_text.text.trim().isEmpty) return;
                    await _send(user, _text.text.trim(), ChatMediaType.text);
                    _text.clear();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _send(UserProfile user, String content, ChatMediaType type) async {
    await ref.read(appStoreProvider).sendMessage(
          ChatMessage(
            id: newId(),
            threadId: widget.thread.id,
            senderId: user.id,
            type: type,
            content: content,
            createdAt: DateTime.now(),
          ),
          widget.thread,
        );
  }
}

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:just_audio/just_audio.dart';

import '../../../core/data/app_store.dart';
import '../../../core/data/providers.dart';
import '../../../core/data/seed_data.dart';
import '../../../core/models/enums.dart';
import '../../../core/models/models.dart';
import '../../../core/widgets/app_page.dart';
import '../../../core/widgets/diyetsel_widgets.dart';
import '../../auth/presentation/auth_controller.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user!;
    final threads = ref.watch(chatsProvider(user.id)).valueOrNull ?? [];
    return AppPage(
      title: 'Sohbet',
      fab: user.isAdmin
          ? null
          : FloatingActionButton(
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
      child: threads.isEmpty
          ? const EmptyState(icon: Icons.chat, title: 'Henüz mesaj yok')
          : ListView(
              children: [
                for (final t in threads)
                  ListTile(
                    title: Text(t.participantNames.where((n) => n != user.displayName).join(', ')),
                    subtitle: Text(t.lastMessage),
                    onTap: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => ChatRoomScreen(thread: t))),
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
                return Align(
                  alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    constraints: const BoxConstraints(maxWidth: 320),
                    decoration: BoxDecoration(
                      color: mine ? const Color(0xFFFF6B00) : Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: m.type == ChatMediaType.text
                        ? Text(m.content, style: TextStyle(color: mine ? Colors.white : null))
                        : TextButton(
                            onPressed: () async {
                              try {
                                await _player.setFilePath(m.content);
                                await _player.play();
                              } catch (_) {}
                            },
                            child: Text('${m.type.name}: ${m.content.split(RegExp(r'[\\/]')).last}', style: TextStyle(color: mine ? Colors.white : null)),
                          ),
                  ),
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

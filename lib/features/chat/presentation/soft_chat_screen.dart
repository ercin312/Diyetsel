import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:just_audio/just_audio.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/data/app_store.dart';
import '../../../core/data/providers.dart';
import '../../../core/data/seed_data.dart';
import '../../../core/models/enums.dart';
import '../../../core/models/models.dart';
import '../../../core/utils/desktop.dart';
import '../../../core/widgets/soft_desktop_frame.dart';
import '../../../core/widgets/soft_ui_kit.dart';
import '../../auth/presentation/auth_controller.dart';
import 'widgets/soft_chat_widgets.dart';
import '../../../core/l10n/ui_string.dart';

/// Soft premium modern chat list.
class SoftChatListScreen extends ConsumerWidget {
  const SoftChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user!;
    final threads = ref.watch(chatsProvider(user.id)).valueOrNull ?? [];
    final sorted = [...threads]..sort((a, b) => b.lastAt.compareTo(a.lastAt));
    final today = DateTime.now();
    final todayCount = sorted.where((t) {
      final d = t.lastAt;
      return d.year == today.year && d.month == today.month && d.day == today.day;
    }).length;

    Future<void> startChat() async {
      final store = ref.read(appStoreProvider);
      final admin = store.user(SeedData.adminId) ?? store.users().firstWhere((u) => u.isAdmin);
      final thread = await store.ensureThread(user, admin);
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute<void>(builder: (_) => SoftChatRoomScreen(thread: thread)),
        );
      }
    }

    return Scaffold(
      backgroundColor: AppColors.modernWash,
      floatingActionButton: user.isAdmin
          ? null
          : SoftChatFab(onPressed: startChat),
      body: SafeArea(
        child: SoftDesktopBody(
          child: ListView(
            padding: context.isDesktopLayout
                ? EdgeInsets.fromLTRB(0, context.pagePadding.top, 0, 100)
                : const EdgeInsets.fromLTRB(18, 12, 18, 100),
            children: [
              SoftChatHeader(isAdmin: user.isAdmin)
                  .animate()
                  .fadeIn(duration: 280.ms)
                  .slideY(begin: -0.05, curve: Curves.easeOutCubic),
              const SizedBox(height: 14),
              SoftChatHero(threadCount: sorted.length, isAdmin: user.isAdmin)
                  .animate()
                  .fadeIn(delay: 40.ms, duration: 300.ms)
                  .scale(
                    begin: const Offset(0.97, 0.97),
                    curve: Curves.easeOutCubic,
                    duration: 380.ms,
                  ),
            const SizedBox(height: 14),
            SoftChatStatsRow(threads: sorted.length, today: todayCount)
                .animate()
                .fadeIn(delay: 70.ms, duration: 280.ms),
            const SizedBox(height: 14),
            SoftTipCard(
              title: 'Net soru, hızlı yanıt',
              body: 'Öğün fotoğrafı, tartı ekranı veya lab sonucu paylaş — diyetisyenin bağlamı görünce daha net yönlendirir.',
              icon: Icons.tips_and_updates_outlined,
              accent: const Color(0xFF5BA3C9),
              tint: const Color(0xFFE3F2F8),
            ).animate().fadeIn(delay: 90.ms, duration: 280.ms),
            const SizedBox(height: 18),
            Row(
              children: [
                Text(('Konuşmalar').ui,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 17,
                    color: AppColors.primaryDeep,
                  ),
                ),
                if (sorted.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(('${sorted.length}').ui,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 11.5,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 10),
            if (sorted.isEmpty)
              SoftEmptyRich(
                title: user.isAdmin ? 'Henüz danışan mesajı yok' : 'Henüz sohbet yok',
                body: user.isAdmin
                    ? 'Danışanlar yazmaya başladığında konuşmalar burada toplanır.'
                    : 'Diyetisyeninle güvenli mesajlaşmaya buradan başla — fotoğraf ve dosya da gönderebilirsin.',
                icon: Icons.chat_bubble_outline_rounded,
                actionLabel: user.isAdmin ? null : 'Sohbeti başlat',
                onAction: user.isAdmin ? null : startChat,
              ).animate().fadeIn(duration: 300.ms)
            else
              for (var i = 0; i < sorted.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: SoftChatThreadCard(
                    thread: sorted[i],
                    index: i,
                    peerName: sorted[i]
                        .participantNames
                        .where((n) => n != user.displayName)
                        .join(', ')
                        .trim()
                        .isEmpty
                        ? 'Sohbet'
                        : sorted[i]
                            .participantNames
                            .where((n) => n != user.displayName)
                            .join(', '),
                    onOpen: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => SoftChatRoomScreen(thread: sorted[i]),
                      ),
                    ),
                  ),
                ),
          ],
        ),
        ),
      ),
    );
  }
}

/// Soft premium modern chat room.
class SoftChatRoomScreen extends ConsumerStatefulWidget {
  const SoftChatRoomScreen({super.key, required this.thread});

  final ChatThread thread;

  @override
  ConsumerState<SoftChatRoomScreen> createState() => _SoftChatRoomScreenState();
}

class _SoftChatRoomScreenState extends ConsumerState<SoftChatRoomScreen> {
  final _text = TextEditingController();
  final _player = AudioPlayer();
  final _scroll = ScrollController();

  @override
  void dispose() {
    _text.dispose();
    _player.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).user!;
    final messages = ref.watch(messagesProvider(widget.thread.id)).valueOrNull ?? [];
    final title = widget.thread.participantNames
            .where((n) => n != user.displayName)
            .join(', ')
            .trim()
            .isEmpty
        ? 'Sohbet'
        : widget.thread.participantNames.where((n) => n != user.displayName).join(', ');

    return Scaffold(
      backgroundColor: AppColors.modernWash,
      body: Column(
        children: [
          SoftChatRoomAppBar(title: title),
          Expanded(
            child: messages.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(24),
                    child: SoftEmptyRich(
                      title: 'Konuşmaya başla',
                      body: 'İlk mesajını yaz veya fotoğraf / dosya ekle — net bağlam hızlı yanıt getirir.',
                      icon: Icons.forum_outlined,
                    ),
                  )
                : ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: messages.length,
                    itemBuilder: (context, i) {
                      final m = messages[i];
                      final mine = m.senderId == user.id;
                      return SoftChatBubble(
                        message: m,
                        mine: mine,
                        onPlayMedia: () async {
                          try {
                            await _player.setFilePath(m.content);
                            await _player.play();
                          } catch (_) {}
                        },
                      );
                    },
                  ),
          ),
          SoftChatComposer(
            controller: _text,
            onSend: () async {
              if (_text.text.trim().isEmpty) return;
              await _send(user, _text.text.trim(), ChatMediaType.text);
              _text.clear();
            },
            onPhoto: () async {
              final file = await ImagePicker().pickImage(source: ImageSource.gallery);
              if (file == null) return;
              await _send(user, file.path, ChatMediaType.image);
            },
            onFile: () async {
              final files = await FilePicker.pickFiles();
              final path = files.isEmpty ? null : files.first.path;
              if (path == null) return;
              await _send(user, path, ChatMediaType.file);
            },
            onAudio: () async {
              final files = await FilePicker.pickFiles(type: FileType.audio);
              final path = files.isEmpty ? null : files.first.path;
              if (path == null) return;
              await _send(user, path, ChatMediaType.audio);
            },
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

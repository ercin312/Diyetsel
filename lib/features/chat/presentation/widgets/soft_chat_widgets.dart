import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/constants/diyetsel_assets.dart';
import '../../../../core/models/enums.dart';
import '../../../../core/models/models.dart';
import '../../../dashboard/presentation/widgets/premium_home_widgets.dart' show SoftTap;
import '../../../dashboard/presentation/widgets/soft_home_widgets.dart' show SoftModernIcon;

class SoftChatHeader extends StatelessWidget {
  const SoftChatHeader({super.key, required this.isAdmin});

  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SoftTap(
          onTap: () => Navigator.maybePop(context),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.modernLine),
              boxShadow: AppSpacing.soft,
            ),
            child: Icon(
              Icons.arrow_back_rounded,
              color: AppColors.primary.withValues(alpha: 0.75),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isAdmin ? 'Danışan sohbetleri' : 'Sohbet',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryDeep,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                isAdmin ? 'Mesajları yönet ve yanıtla' : 'Diyetisyeninle güvenli mesajlaş',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Color(0x991A4F45),
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: AppColors.modernLine),
            boxShadow: AppSpacing.soft,
          ),
          padding: const EdgeInsets.all(10),
          child: SoftModernIcon(
            DiyetselAssets.modernIconService,
            size: 28,
            fallback: Icons.chat_bubble_rounded,
            fallbackColor: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class SoftChatHero extends StatelessWidget {
  const SoftChatHero({
    super.key,
    required this.threadCount,
    required this.isAdmin,
  });

  final int threadCount;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 14, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE3F2F8), Color(0xFFFFF6E9), Color(0xFFE8F5F0)],
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.modernLine),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5BA3C9).withValues(alpha: 0.14),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5BA3C9).withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'Canlı destek',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 11.5,
                      color: Color(0xFF5BA3C9),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  isAdmin ? 'Klinik mesaj kutusu' : 'Sor, paylaş, ilerleme takip et',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    height: 1.2,
                    color: AppColors.primaryDeep,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  threadCount == 0
                      ? 'Henüz konuşma yok — ilk mesajı sen başlat.'
                      : '$threadCount aktif sohbet · yanıtlar burada',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    height: 1.35,
                    color: AppColors.primaryDeep.withValues(alpha: 0.65),
                  ),
                ),
              ],
            ),
          ),
          SoftModernIcon(
            DiyetselAssets.modernIconService,
            size: 72,
            fallback: Icons.headset_mic_rounded,
            fallbackColor: const Color(0xFF5BA3C9),
          ),
        ],
      ),
    );
  }
}

class SoftChatStatsRow extends StatelessWidget {
  const SoftChatStatsRow({
    super.key,
    required this.threads,
    required this.today,
  });

  final int threads;
  final int today;

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Sohbet', '$threads', DiyetselAssets.modernIconService, Icons.forum_rounded, AppColors.primary),
      ('Bugün', '$today', DiyetselAssets.modernIconBell, Icons.today_rounded, const Color(0xFF5BA3C9)),
      ('Durum', 'Açık', DiyetselAssets.modernIconCheck, Icons.check_circle_rounded, const Color(0xFFE07A5F)),
    ];
    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.modernLine),
                boxShadow: AppSpacing.soft,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SoftModernIcon(
                    items[i].$3,
                    size: 24,
                    fallback: items[i].$4,
                    fallbackColor: items[i].$5,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    items[i].$1,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 11.5,
                      color: AppColors.primary.withValues(alpha: 0.5),
                    ),
                  ),
                  Text(
                    items[i].$2,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: items[i].$5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class SoftChatTipsCard extends StatelessWidget {
  const SoftChatTipsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.modernLine),
        boxShadow: AppSpacing.soft,
      ),
      child: Row(
        children: [
          SoftModernIcon(
            DiyetselAssets.modernIconBell,
            size: 28,
            fallback: Icons.tips_and_updates_outlined,
            fallbackColor: AppColors.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Öğün fotoğrafı, tartı ekranı veya lab sonucu paylaşabilirsin — net soru = hızlı yanıt.',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                height: 1.35,
                color: AppColors.primary.withValues(alpha: 0.65),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SoftChatEmpty extends StatelessWidget {
  const SoftChatEmpty({super.key, required this.isAdmin, this.onStart});

  final bool isAdmin;
  final VoidCallback? onStart;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.modernLine),
        boxShadow: AppSpacing.soft,
      ),
      child: Column(
        children: [
          SoftModernIcon(
            DiyetselAssets.modernIconService,
            size: 56,
            fallback: Icons.chat_bubble_outline_rounded,
            fallbackColor: AppColors.primary.withValues(alpha: 0.45),
          ),
          const SizedBox(height: 14),
          Text(
            isAdmin ? 'Henüz danışan mesajı yok' : 'Henüz sohbet yok',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 17,
              color: AppColors.primaryDeep,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isAdmin
                ? 'Danışanlar yazınca konuşmalar burada listelenir.'
                : 'Diyetisyeninle ilk mesajı göndererek başla.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: AppColors.primary.withValues(alpha: 0.5),
            ),
          ),
          if (onStart != null) ...[
            const SizedBox(height: 16),
            SoftTap(
              onTap: onStart,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.28),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Text(
                  'Sohbeti başlat',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class SoftChatThreadCard extends StatelessWidget {
  const SoftChatThreadCard({
    super.key,
    required this.thread,
    required this.peerName,
    required this.onOpen,
    this.index = 0,
  });

  final ChatThread thread;
  final String peerName;
  final VoidCallback onOpen;
  final int index;

  String get _timeLabel {
    final now = DateTime.now();
    final d = thread.lastAt;
    if (now.year == d.year && now.month == d.month && now.day == d.day) {
      return DateFormat('HH:mm').format(d);
    }
    if (now.difference(d).inDays < 7) {
      return DateFormat('E', 'tr').format(d);
    }
    return DateFormat('d MMM', 'tr').format(d);
  }

  @override
  Widget build(BuildContext context) {
    final initial = peerName.isNotEmpty ? peerName.characters.first.toUpperCase() : '?';
    final accents = [
      AppColors.primary,
      const Color(0xFF5BA3C9),
      const Color(0xFFE07A5F),
      const Color(0xFFD4A017),
    ];
    final accent = accents[peerName.hashCode.abs() % accents.length];

    return SoftTap(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.modernLine),
          boxShadow: AppSpacing.soft,
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.lerp(accent, Colors.white, 0.55)!,
                    Color.lerp(accent, const Color(0xFFFFF6E9), 0.35)!,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: accent.withValues(alpha: 0.25)),
              ),
              alignment: Alignment.center,
              child: Text(
                initial,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                  color: accent,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          peerName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 15.5,
                            color: AppColors.primaryDeep,
                          ),
                        ),
                      ),
                      Text(
                        _timeLabel,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 11.5,
                          color: AppColors.primary.withValues(alpha: 0.45),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    thread.lastMessage.isEmpty ? 'Yeni sohbet' : thread.lastMessage,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      height: 1.3,
                      color: AppColors.primary.withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.primary.withValues(alpha: 0.35),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (40 * index).ms, duration: 280.ms).slideY(
          begin: 0.04,
          curve: Curves.easeOutCubic,
        );
  }
}

class SoftChatFab extends StatelessWidget {
  const SoftChatFab({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 2,
      icon: const Icon(Icons.chat_rounded),
      label: const Text('Yeni sohbet', style: TextStyle(fontWeight: FontWeight.w800)),
    );
  }
}

// ─── Room widgets ─────────────────────────────────────────────────────────────

class SoftChatRoomAppBar extends StatelessWidget {
  const SoftChatRoomAppBar({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final initial = title.isNotEmpty ? title.characters.first.toUpperCase() : '?';
    return SafeArea(
      bottom: false,
      child: Container(
        color: AppColors.modernWash,
        padding: const EdgeInsets.fromLTRB(12, 8, 18, 8),
        child: Row(
          children: [
            SoftTap(
              onTap: () => Navigator.maybePop(context),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.modernLine),
                  boxShadow: AppSpacing.soft,
                ),
                child: Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.primary.withValues(alpha: 0.75),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5F0),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.modernLine),
              ),
              alignment: Alignment.center,
              child: Text(
                initial,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: AppColors.primaryDeep,
                    ),
                  ),
                  Text(
                    'e-Diyet sohbet',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: AppColors.primary.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SoftChatBubble extends StatelessWidget {
  const SoftChatBubble({
    super.key,
    required this.message,
    required this.mine,
    required this.onPlayMedia,
  });

  final ChatMessage message;
  final bool mine;
  final VoidCallback onPlayMedia;

  @override
  Widget build(BuildContext context) {
    final time = DateFormat('HH:mm').format(message.createdAt);
    final isText = message.type == ChatMediaType.text;
    final fileName = message.content.split(RegExp(r'[\\/]')).last;

    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        constraints: const BoxConstraints(maxWidth: 300),
        child: Column(
          crossAxisAlignment: mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              decoration: BoxDecoration(
                color: mine ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(mine ? 20 : 6),
                  bottomRight: Radius.circular(mine ? 6 : 20),
                ),
                border: mine ? null : Border.all(color: AppColors.modernLine),
                boxShadow: [
                  BoxShadow(
                    color: (mine ? AppColors.primary : const Color(0xFF5BA3C9)).withValues(alpha: 0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: isText
                  ? Text(
                      message.content,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                        fontSize: 14.5,
                        color: mine ? Colors.white : AppColors.primaryDeep,
                      ),
                    )
                  : SoftTap(
                      onTap: onPlayMedia,
                      borderRadius: BorderRadius.circular(12),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _mediaIcon(message.type),
                            size: 20,
                            color: mine ? Colors.white : AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              '${_mediaLabel(message.type)} · $fileName',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: mine ? Colors.white : AppColors.primaryDeep,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                time,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                  color: AppColors.primary.withValues(alpha: 0.4),
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 220.ms).slideY(begin: 0.06, curve: Curves.easeOutCubic);
  }

  IconData _mediaIcon(ChatMediaType type) {
    switch (type) {
      case ChatMediaType.image:
      case ChatMediaType.mealPhoto:
        return Icons.image_rounded;
      case ChatMediaType.audio:
        return Icons.play_circle_fill_rounded;
      case ChatMediaType.file:
        return Icons.attach_file_rounded;
      case ChatMediaType.text:
        return Icons.chat_bubble_rounded;
    }
  }

  String _mediaLabel(ChatMediaType type) {
    switch (type) {
      case ChatMediaType.image:
        return 'Fotoğraf';
      case ChatMediaType.mealPhoto:
        return 'Öğün foto';
      case ChatMediaType.audio:
        return 'Ses';
      case ChatMediaType.file:
        return 'Dosya';
      case ChatMediaType.text:
        return 'Mesaj';
    }
  }
}

class SoftChatComposer extends StatelessWidget {
  const SoftChatComposer({
    super.key,
    required this.controller,
    required this.onSend,
    required this.onPhoto,
    required this.onFile,
    required this.onAudio,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onPhoto;
  final VoidCallback onFile;
  final VoidCallback onAudio;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.modernLine)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                _ComposerChip(icon: Icons.photo_rounded, label: 'Foto', onTap: onPhoto),
                const SizedBox(width: 8),
                _ComposerChip(icon: Icons.attach_file_rounded, label: 'Dosya', onTap: onFile),
                const SizedBox(width: 8),
                _ComposerChip(icon: Icons.mic_rounded, label: 'Ses', onTap: onAudio),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.modernWash,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.modernLine),
                    ),
                    child: TextField(
                      controller: controller,
                      minLines: 1,
                      maxLines: 4,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryDeep,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Mesaj yaz…',
                        hintStyle: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary.withValues(alpha: 0.4),
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      onSubmitted: (_) => onSend(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SoftTap(
                  onTap: onSend,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.28),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.send_rounded, color: Colors.white, size: 22),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SoftChatRoomEmpty extends StatelessWidget {
  const SoftChatRoomEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SoftModernIcon(
              DiyetselAssets.modernIconService,
              size: 56,
              fallback: Icons.forum_outlined,
              fallbackColor: AppColors.primary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 14),
            const Text(
              'Konuşmaya başla',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 17,
                color: AppColors.primaryDeep,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'İlk mesajını yaz veya fotoğraf / dosya ekle.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: AppColors.primary.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ComposerChip extends StatelessWidget {
  const _ComposerChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SoftTap(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.modernWash,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.modernLine),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 12,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

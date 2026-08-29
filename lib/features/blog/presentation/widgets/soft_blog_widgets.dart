import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/constants/diyetsel_assets.dart';
import '../../../../core/models/models.dart';
import '../../../../core/widgets/marketplace.dart';
import '../../../dashboard/presentation/widgets/premium_home_widgets.dart' show SoftTap;
import '../../../dashboard/presentation/widgets/soft_home_widgets.dart' show SoftModernIcon;
import '../../domain/blog_visuals.dart';

class SoftBlogHeader extends StatelessWidget {
  const SoftBlogHeader({super.key, required this.admin});

  final bool admin;

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
                admin ? 'Blog editörü' : 'Blog',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryDeep,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                admin ? 'Yazıları yönet ve yayınla' : 'Sağlıklı yaşam yazıları',
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
            DiyetselAssets.modernIconStory,
            size: 28,
            fallback: Icons.auto_stories_rounded,
            fallbackColor: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class SoftBlogHero extends StatelessWidget {
  const SoftBlogHero({super.key, required this.count, required this.categories});

  final int count;
  final int categories;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 14, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE8F5F0), Color(0xFFFFF6E9), Color(0xFFFFF0E8)],
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.modernLine),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.1),
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
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'Diyetisyen notları',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 11.5,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Sağlıklı yaşam',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                    height: 1.15,
                    color: AppColors.primaryDeep,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$count yazı · $categories kategori · pratik ipuçları',
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
            DiyetselAssets.modernCardBlog,
            size: 78,
            fallback: Icons.menu_book_rounded,
            fallbackColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class SoftBlogStatsRow extends StatelessWidget {
  const SoftBlogStatsRow({
    super.key,
    required this.posts,
    required this.likes,
    required this.saved,
  });

  final int posts;
  final int likes;
  final int saved;

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Yazı', '$posts', DiyetselAssets.modernIconStory, Icons.article_rounded, AppColors.primary),
      ('Beğeni', '$likes', DiyetselAssets.modernIconCheck, Icons.favorite_rounded, const Color(0xFFE07A5F)),
      ('Kayıt', '$saved', DiyetselAssets.modernIconPlan, Icons.bookmark_rounded, const Color(0xFF5BA3C9)),
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
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 17,
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

class SoftBlogSearchField extends StatelessWidget {
  const SoftBlogSearchField({super.key, required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSearch),
        border: Border.all(color: AppColors.modernLine),
        boxShadow: AppSpacing.soft,
      ),
      child: TextField(
        onChanged: onChanged,
        style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primaryDeep),
        decoration: InputDecoration(
          hintText: 'Yazı veya etiket ara…',
          hintStyle: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.primary.withValues(alpha: 0.4),
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 10, right: 6),
            child: SoftModernIcon(
              DiyetselAssets.modernIconSearch,
              size: 22,
              fallback: Icons.search_rounded,
              fallbackColor: AppColors.primary.withValues(alpha: 0.55),
            ),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
        ),
      ),
    );
  }
}

class SoftBlogCategoryChip extends StatelessWidget {
  const SoftBlogCategoryChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SoftTap(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.modernLine,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.28),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : AppSpacing.soft,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 12.5,
            color: selected ? Colors.white : AppColors.primaryDeep.withValues(alpha: 0.75),
          ),
        ),
      ),
    );
  }
}

class SoftBlogFeaturedCard extends StatelessWidget {
  const SoftBlogFeaturedCard({
    super.key,
    required this.post,
    required this.liked,
    required this.bookmarked,
    required this.onOpen,
    required this.onLike,
    required this.onBookmark,
  });

  final BlogPost post;
  final bool liked;
  final bool bookmarked;
  final VoidCallback onOpen;
  final VoidCallback onLike;
  final VoidCallback onBookmark;

  @override
  Widget build(BuildContext context) {
    final tint = BlogVisuals.softTintFor(post);
    final accent = BlogVisuals.softAccentFor(post);

    return SoftTap(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(26),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: AppColors.modernLine),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.14),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 168,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.lerp(tint, Colors.white, 0.1)!,
                    Color.lerp(tint, const Color(0xFFFFF6E9), 0.35)!,
                  ],
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: 6,
                    bottom: 0,
                    child: diyetselFoodPhoto(
                      url: BlogVisuals.coverFor(post),
                      width: 130,
                      height: 130,
                      fit: BoxFit.contain,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 110, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'Öne çıkan · ${post.category}',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 11.5,
                              color: accent,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          post.title,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 19,
                            height: 1.2,
                            color: AppColors.primaryDeep,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13.5,
                      height: 1.35,
                      color: AppColors.primary.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.schedule_rounded, size: 15, color: accent),
                      const SizedBox(width: 4),
                      Text(
                        '${BlogVisuals.readMinutes(post)} dk',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          color: accent,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        DateFormat('d MMM', 'tr').format(post.updatedAt),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          color: AppColors.primary.withValues(alpha: 0.45),
                        ),
                      ),
                      const Spacer(),
                      _SoftIconAction(
                        icon: liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: const Color(0xFFE07A5F),
                        onTap: onLike,
                      ),
                      Text(
                        '${post.likes}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDeep,
                        ),
                      ),
                      const SizedBox(width: 4),
                      _SoftIconAction(
                        icon: bookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                        color: AppColors.primary,
                        onTap: onBookmark,
                      ),
                    ],
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

class SoftBlogCard extends StatelessWidget {
  const SoftBlogCard({
    super.key,
    required this.post,
    required this.liked,
    required this.bookmarked,
    required this.onOpen,
    required this.onLike,
    required this.onBookmark,
    this.index = 0,
  });

  final BlogPost post;
  final bool liked;
  final bool bookmarked;
  final VoidCallback onOpen;
  final VoidCallback onLike;
  final VoidCallback onBookmark;
  final int index;

  @override
  Widget build(BuildContext context) {
    final tint = BlogVisuals.softTintFor(post);
    final accent = BlogVisuals.softAccentFor(post);

    return SoftTap(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.modernLine),
          boxShadow: AppSpacing.soft,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.lerp(tint, Colors.white, 0.15)!,
                    Color.lerp(tint, const Color(0xFFFFF6E9), 0.4)!,
                  ],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              alignment: Alignment.center,
              child: diyetselFoodPhoto(
                url: BlogVisuals.coverFor(post),
                width: 68,
                height: 68,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: tint,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(BlogVisuals.iconFor(post), size: 15, color: accent),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          post.category,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                            color: accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    post.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                      height: 1.2,
                      color: AppColors.primaryDeep,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    post.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12.5,
                      height: 1.3,
                      color: AppColors.primary.withValues(alpha: 0.55),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '${BlogVisuals.readMinutes(post)} dk',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 11.5,
                          color: AppColors.primary.withValues(alpha: 0.45),
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: onLike,
                        child: Icon(
                          liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          size: 18,
                          color: const Color(0xFFE07A5F),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${post.likes}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          color: AppColors.primaryDeep,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: onBookmark,
                        child: Icon(
                          bookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                          size: 18,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
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

class SoftBlogEmpty extends StatelessWidget {
  const SoftBlogEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.modernLine),
      ),
      child: Column(
        children: [
          SoftModernIcon(
            DiyetselAssets.modernIconSearch,
            size: 48,
            fallback: Icons.article_outlined,
            fallbackColor: AppColors.primary.withValues(alpha: 0.45),
          ),
          const SizedBox(height: 12),
          const Text(
            'Bu filtrede yazı yok',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 16,
              color: AppColors.primaryDeep,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Başka bir kategori dene veya aramayı temizle.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: AppColors.primary.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

class SoftBlogSectionTitle extends StatelessWidget {
  const SoftBlogSectionTitle({super.key, required this.title, this.count});

  final String title;
  final int? count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 17,
            color: AppColors.primaryDeep,
          ),
        ),
        if (count != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 11.5,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class SoftBlogFab extends StatelessWidget {
  const SoftBlogFab({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 2,
      icon: const Icon(Icons.edit_rounded),
      label: const Text(
        'Yeni yazı',
        style: TextStyle(fontWeight: FontWeight.w800),
      ),
    );
  }
}

class SoftBlogDetailHero extends StatelessWidget {
  const SoftBlogDetailHero({super.key, required this.post});

  final BlogPost post;

  @override
  Widget build(BuildContext context) {
    final tint = BlogVisuals.softTintFor(post);
    final accent = BlogVisuals.softAccentFor(post);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(tint, Colors.white, 0.1)!,
            const Color(0xFFFFF6E9),
          ],
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.modernLine),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    post.category,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      color: accent,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  post.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 24,
                    height: 1.2,
                    color: AppColors.primaryDeep,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  post.subtitle,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    height: 1.4,
                    color: AppColors.primary.withValues(alpha: 0.65),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${post.authorName} · ${BlogVisuals.readMinutes(post)} dk · ${DateFormat('d MMMM y', 'tr').format(post.updatedAt)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: accent,
                  ),
                ),
              ],
            ),
          ),
          diyetselFoodPhoto(
            url: BlogVisuals.coverFor(post),
            width: 96,
            height: 96,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}

class SoftBlogActionBar extends StatelessWidget {
  const SoftBlogActionBar({
    super.key,
    required this.post,
    required this.liked,
    required this.bookmarked,
    required this.onLike,
    required this.onBookmark,
  });

  final BlogPost post;
  final bool liked;
  final bool bookmarked;
  final VoidCallback onLike;
  final VoidCallback onBookmark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.modernLine),
        boxShadow: AppSpacing.soft,
      ),
      child: Row(
        children: [
          SoftTap(
            onTap: onLike,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  Icon(
                    liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: const Color(0xFFE07A5F),
                    size: 22,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${post.likes}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDeep,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SoftTap(
            onTap: onBookmark,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  Icon(
                    bookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    bookmarked ? 'Kayıtlı' : 'Kaydet',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: AppColors.primary.withValues(alpha: 0.75),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          for (final t in post.tags.take(2))
            Container(
              margin: const EdgeInsets.only(left: 6),
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.modernWash,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.modernLine),
              ),
              child: Text(
                t,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  color: AppColors.primary.withValues(alpha: 0.7),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class SoftBlogBlock extends StatelessWidget {
  const SoftBlogBlock({super.key, required this.block});

  final RichBlock block;

  @override
  Widget build(BuildContext context) {
    switch (block.type) {
      case 'heading':
        return Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 10),
          child: Text(
            block.text,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryDeep,
              letterSpacing: -0.2,
            ),
          ),
        );
      case 'quote':
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.modernLine),
            boxShadow: AppSpacing.soft,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.format_quote_rounded,
                color: AppColors.primary.withValues(alpha: 0.55),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  block.text,
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w600,
                    height: 1.45,
                    color: AppColors.primaryDeep.withValues(alpha: 0.9),
                  ),
                ),
              ),
            ],
          ),
        );
      case 'list':
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.modernLine),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SoftModernIcon(
                DiyetselAssets.modernIconCheck,
                size: 18,
                fallback: Icons.check_circle_rounded,
                fallbackColor: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  block.text,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                    color: AppColors.primaryDeep,
                  ),
                ),
              ),
            ],
          ),
        );
      default:
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            block.text,
            style: TextStyle(
              fontWeight: block.bold ? FontWeight.w800 : FontWeight.w500,
              fontStyle: block.italic ? FontStyle.italic : FontStyle.normal,
              height: 1.55,
              fontSize: 15,
              color: AppColors.primaryDeep.withValues(alpha: 0.88),
            ),
          ),
        );
    }
  }
}

class _SoftIconAction extends StatelessWidget {
  const _SoftIconAction({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      visualDensity: VisualDensity.compact,
      onPressed: onTap,
      icon: Icon(icon, color: color, size: 22),
    );
  }
}

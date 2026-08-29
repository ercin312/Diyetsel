import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/data/app_store.dart';
import '../../../core/data/providers.dart';
import '../../../core/models/models.dart';
import '../../../core/widgets/app_page.dart';
import '../../../core/widgets/cartoon_glyph.dart';
import '../../../core/widgets/diyetsel_widgets.dart';
import '../../../core/widgets/marketplace.dart';
import '../../auth/presentation/auth_controller.dart';
import '../domain/blog_visuals.dart';
import 'blog_editor_screen.dart';
import 'soft_blog_screen.dart';

class BlogListScreen extends ConsumerStatefulWidget {
  const BlogListScreen({super.key, this.admin = false});
  final bool admin;

  @override
  ConsumerState<BlogListScreen> createState() => _BlogListScreenState();
}

class _BlogListScreenState extends ConsumerState<BlogListScreen> {
  String _query = '';
  String? _category;

  @override
  Widget build(BuildContext context) {
    if (context.isModern) {
      return SoftBlogListScreen(admin: widget.admin);
    }

    final user = ref.watch(authControllerProvider).user!;
    final store = ref.watch(appStoreProvider);
    ref.watch(blogInteractionsProvider);
    var posts = (ref.watch(blogProvider).valueOrNull ?? []).where((p) => widget.admin || p.published);
    if (_category != null) posts = posts.where((p) => p.category == _category);
    if (_query.isNotEmpty) {
      posts = posts.where((p) => '${p.title} ${p.subtitle} ${p.tags.join()}'.toLowerCase().contains(_query.toLowerCase()));
    }
    final list = posts.toList()..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    final cartoon = context.isCartoon;

    if (cartoon) {
      return AppPage(
        title: 'Blog',
        padding: EdgeInsets.zero,
        fab: widget.admin
            ? FloatingActionButton(
                backgroundColor: AppColors.kawaiiLeaf,
                onPressed: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const BlogEditorScreen())),
                child: const Icon(Icons.edit_rounded, color: Colors.white),
              )
            : null,
        child: ColoredBox(
          color: AppColors.kawaiiSurfaceCream,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
                  children: [
                    _BlogHero(count: list.length)
                        .animate()
                        .fadeIn(duration: 300.ms)
                        .slideY(begin: -0.04, curve: Curves.easeOutCubic),
                    const SizedBox(height: 14),
                    _CartoonSearchField(
                      hint: 'Yazı veya etiket ara...',
                      onChanged: (v) => setState(() => _query = v),
                    ).animate().fadeIn(delay: 40.ms, duration: 280.ms),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 40,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _CatChip(
                            label: 'Tümü',
                            selected: _category == null,
                            onTap: () => setState(() => _category = null),
                          ),
                          const SizedBox(width: 8),
                          for (final c in blogCategories) ...[
                            _CatChip(
                              label: c,
                              selected: _category == c,
                              onTap: () => setState(() => _category = c),
                            ),
                            const SizedBox(width: 8),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (list.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(32),
                        child: Text(
                          'Bu filtrede yazı yok.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.kawaiiMuted),
                        ),
                      )
                    else ...[
                      if (list.isNotEmpty) ...[
                        _FeaturedBlogCard(
                          post: list.first,
                          liked: store.isLiked(user.id, list.first.id),
                          bookmarked: store.isBookmarked(user.id, list.first.id),
                          onOpen: () => _open(list.first),
                          onLike: () => store.toggleLike(user.id, list.first),
                          onBookmark: () => store.toggleBookmark(user.id, list.first.id),
                        )
                            .animate()
                            .fadeIn(delay: 80.ms, duration: 320.ms)
                            .scale(begin: const Offset(0.96, 0.96), curve: Curves.easeOutBack),
                        if (list.length > 1) ...[
                          const SizedBox(height: 18),
                          const Text(
                            'Tüm yazılar',
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: AppColors.kawaiiInk),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ],
                      for (var i = 1; i < list.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _CartoonBlogCard(
                            post: list[i],
                            liked: store.isLiked(user.id, list[i].id),
                            bookmarked: store.isBookmarked(user.id, list[i].id),
                            onOpen: () => _open(list[i]),
                            onLike: () => store.toggleLike(user.id, list[i]),
                            onBookmark: () => store.toggleBookmark(user.id, list[i].id),
                          )
                              .animate()
                              .fadeIn(delay: (60 * i).ms, duration: 300.ms)
                              .slideY(begin: 0.05, curve: Curves.easeOutCubic),
                        ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return AppPage(
      title: 'Sağlıklı yaşam',
      fab: widget.admin
          ? FloatingActionButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const BlogEditorScreen())),
              child: const Icon(Icons.edit),
            )
          : null,
      child: Column(
        children: [
          TextField(
            decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Yazı veya etiket ara'),
            onChanged: (v) => setState(() => _query = v),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                ChoiceChip(label: const Text('Tümü'), selected: _category == null, onSelected: (_) => setState(() => _category = null)),
                const SizedBox(width: 6),
                for (final c in blogCategories) ...[
                  ChoiceChip(label: Text(c), selected: _category == c, onSelected: (_) => setState(() => _category = c)),
                  const SizedBox(width: 6),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              children: [
                for (final post in list)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: DiyetselCard(
                      onTap: () => _open(post),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: diyetselFoodPhoto(
                              url: BlogVisuals.coverFor(post),
                              width: 72,
                              height: 72,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(post.category, style: TextStyle(color: context.brandPrimary, fontWeight: FontWeight.w800)),
                                Text(post.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                                Text(post.subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    IconButton(
                                      visualDensity: VisualDensity.compact,
                                      onPressed: () => store.toggleLike(user.id, post),
                                      icon: Icon(
                                        store.isLiked(user.id, post.id) ? Icons.favorite : Icons.favorite_border,
                                        color: AppColors.danger,
                                        size: 20,
                                      ),
                                    ),
                                    Text('${post.likes}'),
                                    IconButton(
                                      visualDensity: VisualDensity.compact,
                                      onPressed: () => store.toggleBookmark(user.id, post.id),
                                      icon: Icon(store.isBookmarked(user.id, post.id) ? Icons.bookmark : Icons.bookmark_border, size: 20),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _open(BlogPost post) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => BlogDetailScreen(post: post, admin: widget.admin)),
    );
  }
}

class _BlogHero extends StatelessWidget {
  const _BlogHero({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.kawaiiLilac, AppColors.kawaiiSurfaceCream],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusHero),
        border: Border.all(color: AppColors.kawaiiOutline),
        boxShadow: AppSpacing.softLift,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sağlıklı yaşam',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: AppColors.kawaiiInk, letterSpacing: -0.3),
                ),
                const SizedBox(height: 6),
                Text(
                  '$count yazı · diyetisyen notları, pratik ipuçları',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, height: 1.35, color: AppColors.kawaiiMuted),
                ),
              ],
            ),
          ),
          Image.asset(
            'assets/images/mascot_carrot.png',
            width: 72,
            height: 72,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => const Icon(Icons.auto_stories_rounded, size: 40, color: AppColors.kawaiiLeaf),
          ),
        ],
      ),
    );
  }
}

class _CartoonSearchField extends StatelessWidget {
  const _CartoonSearchField({required this.hint, required this.onChanged});
  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSearch),
        border: Border.all(color: AppColors.kawaiiOutline),
        boxShadow: AppSpacing.soft,
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded, color: AppColors.kawaiiMuted.withValues(alpha: 0.85)),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
                isDense: true,
                hintStyle: TextStyle(color: AppColors.kawaiiMuted.withValues(alpha: 0.9), fontWeight: FontWeight.w600),
              ),
              style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.kawaiiInk),
            ),
          ),
        ],
      ),
    );
  }
}

class _CatChip extends StatelessWidget {
  const _CatChip({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      selected: selected,
      showCheckmark: false,
      label: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 12.5,
          color: selected ? Colors.white : AppColors.kawaiiInk,
        ),
      ),
      selectedColor: AppColors.kawaiiLeaf,
      backgroundColor: Colors.white,
      side: BorderSide(color: selected ? AppColors.kawaiiLeaf : AppColors.kawaiiOutline),
      onSelected: (_) => onTap(),
    );
  }
}

class _FeaturedBlogCard extends StatelessWidget {
  const _FeaturedBlogCard({
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
    final tint = BlogVisuals.tintFor(post);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(AppSpacing.radiusHero),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusHero),
            border: Border.all(color: AppColors.kawaiiOutline),
            boxShadow: AppSpacing.softLift,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 148,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.lerp(tint, Colors.white, 0.15)!,
                      Color.lerp(tint, AppColors.kawaiiCream, 0.4)!,
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusHero - 1)),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: 8,
                      bottom: 4,
                      child: diyetselFoodPhoto(
                        url: BlogVisuals.coverFor(post),
                        width: 120,
                        height: 120,
                        fit: BoxFit.contain,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 100, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Öne çıkan · ${post.category}',
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5, color: AppColors.kawaiiInk),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            post.title,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                              height: 1.2,
                              color: AppColors.kawaiiInk,
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
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5, height: 1.35, color: AppColors.kawaiiMuted),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          '${BlogVisuals.readMinutes(post)} dk okuma',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.kawaiiLeafDeep),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          DateFormat('d MMM', 'tr').format(post.updatedAt),
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.kawaiiMuted),
                        ),
                        const Spacer(),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          onPressed: onLike,
                          icon: Icon(liked ? Icons.favorite_rounded : Icons.favorite_border_rounded, color: AppColors.kawaiiCoral, size: 22),
                        ),
                        Text('${post.likes}', style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.kawaiiInk)),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          onPressed: onBookmark,
                          icon: Icon(bookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded, color: AppColors.kawaiiLeafDeep, size: 22),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CartoonBlogCard extends StatelessWidget {
  const _CartoonBlogCard({
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
    final tint = BlogVisuals.tintFor(post);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        child: Ink(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
            border: Border.all(color: AppColors.kawaiiOutline),
            boxShadow: AppSpacing.soft,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.lerp(tint, Colors.white, 0.2)!,
                      Color.lerp(tint, AppColors.kawaiiCream, 0.45)!,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                alignment: Alignment.center,
                child: diyetselFoodPhoto(
                  url: BlogVisuals.coverFor(post),
                  width: 64,
                  height: 64,
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
                        CartoonGlyph(
                          icon: BlogVisuals.iconFor(post),
                          accent: AppColors.kawaiiLeaf,
                          size: 28,
                          radius: 10,
                          iconSize: 14,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            post.category,
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: AppColors.kawaiiLeafDeep),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      post.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, height: 1.2, color: AppColors.kawaiiInk),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      post.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5, height: 1.3, color: AppColors.kawaiiMuted),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          '${BlogVisuals.readMinutes(post)} dk',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11.5, color: AppColors.kawaiiMuted),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: onLike,
                          child: Icon(liked ? Icons.favorite_rounded : Icons.favorite_border_rounded, size: 18, color: AppColors.kawaiiCoral),
                        ),
                        const SizedBox(width: 4),
                        Text('${post.likes}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: onBookmark,
                          child: Icon(bookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded, size: 18, color: AppColors.kawaiiLeafDeep),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BlogDetailScreen extends ConsumerWidget {
  const BlogDetailScreen({super.key, required this.post, required this.admin});
  final BlogPost post;
  final bool admin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (context.isModern) {
      return SoftBlogDetailScreen(post: post, admin: admin);
    }

    final user = ref.watch(authControllerProvider).user!;
    final store = ref.watch(appStoreProvider);
    ref.watch(blogInteractionsProvider);
    final cartoon = context.isCartoon;
    final liked = store.isLiked(user.id, post.id);
    final bookmarked = store.isBookmarked(user.id, post.id);

    if (cartoon) {
      return AppPage(
        title: 'Yazı',
        padding: EdgeInsets.zero,
        actions: [
          if (admin)
            IconButton(
              icon: const Icon(Icons.edit_rounded),
              onPressed: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => BlogEditorScreen(existing: post))),
            ),
        ],
        child: ColoredBox(
          color: AppColors.kawaiiSurfaceCream,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.lerp(BlogVisuals.tintFor(post), Colors.white, 0.15)!,
                      AppColors.kawaiiSurfaceCream,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusHero),
                  border: Border.all(color: AppColors.kawaiiOutline),
                  boxShadow: AppSpacing.softLift,
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
                              color: Colors.white.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              post.category,
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: AppColors.kawaiiInk),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            post.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 24,
                              height: 1.2,
                              color: AppColors.kawaiiInk,
                              letterSpacing: -0.4,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            post.subtitle,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, height: 1.4, color: AppColors.kawaiiMuted),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '${post.authorName} · ${BlogVisuals.readMinutes(post)} dk · ${DateFormat('d MMMM y', 'tr').format(post.updatedAt)}',
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.kawaiiLeafDeep),
                          ),
                        ],
                      ),
                    ),
                    diyetselFoodPhoto(url: BlogVisuals.coverFor(post), width: 96, height: 96, fit: BoxFit.contain),
                  ],
                ),
              ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.04),
              const SizedBox(height: 12),
              Row(
                children: [
                  for (final t in post.tags.take(4)) ...[
                    Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.kawaiiOutline),
                      ),
                      child: Text(t, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11.5, color: AppColors.kawaiiInk)),
                    ),
                  ],
                  const Spacer(),
                  IconButton(
                    onPressed: () => store.toggleLike(user.id, post),
                    icon: Icon(liked ? Icons.favorite_rounded : Icons.favorite_border_rounded, color: AppColors.kawaiiCoral),
                  ),
                  Text('${post.likes}', style: const TextStyle(fontWeight: FontWeight.w800)),
                  IconButton(
                    onPressed: () => store.toggleBookmark(user.id, post.id),
                    icon: Icon(bookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded, color: AppColors.kawaiiLeafDeep),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              for (var i = 0; i < post.body.length; i++)
                _CartoonBlock(block: post.body[i])
                    .animate()
                    .fadeIn(delay: (40 * i).ms, duration: 280.ms)
                    .slideY(begin: 0.03, curve: Curves.easeOutCubic),
            ],
          ),
        ),
      );
    }

    return AppPage(
      title: post.title,
      actions: [
        if (admin)
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => BlogEditorScreen(existing: post))),
          ),
      ],
      child: ListView(
        children: [
          Text(post.subtitle, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          for (final block in post.body) _legacyBlock(block),
        ],
      ),
    );
  }

  Widget _legacyBlock(RichBlock block) {
    switch (block.type) {
      case 'heading':
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(block.text, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
        );
      case 'quote':
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: AppColors.primary, width: 4)),
            color: AppColors.primary.withValues(alpha: 0.08),
          ),
          child: Text(block.text, style: const TextStyle(fontStyle: FontStyle.italic)),
        );
      case 'list':
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text('• ${block.text}'),
        );
      default:
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            block.text,
            style: TextStyle(
              fontWeight: block.bold ? FontWeight.w800 : FontWeight.w400,
              fontStyle: block.italic ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        );
    }
  }
}

class _CartoonBlock extends StatelessWidget {
  const _CartoonBlock({required this.block});
  final RichBlock block;

  @override
  Widget build(BuildContext context) {
    switch (block.type) {
      case 'heading':
        return Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 10),
          child: Text(
            block.text,
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: AppColors.kawaiiInk, letterSpacing: -0.2),
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
            border: Border.all(color: AppColors.kawaiiOutline),
            boxShadow: AppSpacing.soft,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.format_quote_rounded, color: AppColors.kawaiiLeaf.withValues(alpha: 0.7)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  block.text,
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w600,
                    height: 1.45,
                    color: AppColors.kawaiiInk,
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
            border: Border.all(color: AppColors.kawaiiOutline),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.check_circle_rounded, size: 18, color: AppColors.kawaiiLeaf),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  block.text,
                  style: const TextStyle(fontWeight: FontWeight.w600, height: 1.4, color: AppColors.kawaiiInk),
                ),
              ),
            ],
          ),
        );
      default:
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            block.text,
            style: TextStyle(
              fontWeight: block.bold ? FontWeight.w800 : FontWeight.w600,
              fontStyle: block.italic ? FontStyle.italic : FontStyle.normal,
              height: 1.5,
              fontSize: 14.5,
              color: AppColors.kawaiiInk.withValues(alpha: 0.9),
            ),
          ),
        );
    }
  }
}

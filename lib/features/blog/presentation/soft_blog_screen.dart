import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/data/app_store.dart';
import '../../../core/data/providers.dart';
import '../../../core/models/models.dart';
import '../../../core/widgets/nav_back.dart';
import '../../../core/widgets/soft_ui_kit.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../dashboard/presentation/widgets/premium_home_widgets.dart' show SoftTap;
import '../domain/blog_visuals.dart' show blogCategories;
import 'blog_editor_screen.dart';
import 'widgets/soft_blog_widgets.dart';


/// Soft premium modern blog list.
class SoftBlogListScreen extends ConsumerStatefulWidget {
  const SoftBlogListScreen({super.key, this.admin = false});

  final bool admin;

  @override
  ConsumerState<SoftBlogListScreen> createState() => _SoftBlogListScreenState();
}

class _SoftBlogListScreenState extends ConsumerState<SoftBlogListScreen> {
  String _query = '';
  String? _category;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).user!;
    final store = ref.watch(appStoreProvider);
    ref.watch(blogInteractionsProvider);
    var posts = (ref.watch(blogProvider).valueOrNull ?? []).where((p) => widget.admin || p.published);
    if (_category != null) posts = posts.where((p) => p.category == _category);
    if (_query.isNotEmpty) {
      posts = posts.where(
        (p) => '${p.title} ${p.subtitle} ${p.tags.join()}'.toLowerCase().contains(_query.toLowerCase()),
      );
    }
    final list = posts.toList()..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    final allPublished = (ref.watch(blogProvider).valueOrNull ?? [])
        .where((p) => widget.admin || p.published)
        .toList();
    final categoryCount = allPublished.map((e) => e.category).toSet().length;
    final totalLikes = allPublished.fold<int>(0, (s, p) => s + p.likes);
    final savedCount = allPublished.where((p) => store.isBookmarked(user.id, p.id)).length;

    return Scaffold(
      backgroundColor: AppColors.modernWash,
      floatingActionButton: widget.admin
          ? SoftBlogFab(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute<void>(builder: (_) => const BlogEditorScreen()),
              ),
            )
          : null,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 100),
          children: [
            SoftBlogHeader(admin: widget.admin)
                .animate()
                .fadeIn(duration: 280.ms)
                .slideY(begin: -0.05, curve: Curves.easeOutCubic),
            if (!widget.admin) ...[
              const SizedBox(height: 14),
              const SoftDailyTipBanner(),
            ],
            const SizedBox(height: 14),
            SoftBlogHero(count: allPublished.length, categories: categoryCount)
                .animate()
                .fadeIn(delay: 40.ms, duration: 300.ms)
                .scale(
                  begin: const Offset(0.97, 0.97),
                  curve: Curves.easeOutCubic,
                  duration: 380.ms,
                ),
            const SizedBox(height: 14),
            SoftBlogStatsRow(
              posts: allPublished.length,
              likes: totalLikes,
              saved: savedCount,
            ).animate().fadeIn(delay: 70.ms, duration: 280.ms),
            const SizedBox(height: 14),
            SoftBlogSearchField(
              onChanged: (v) => setState(() => _query = v),
            ).animate().fadeIn(delay: 90.ms, duration: 280.ms),
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  SoftBlogCategoryChip(
                    label: 'Tümü',
                    selected: _category == null,
                    onTap: () => setState(() => _category = null),
                  ),
                  const SizedBox(width: 8),
                  for (final c in blogCategories) ...[
                    SoftBlogCategoryChip(
                      label: c,
                      selected: _category == c,
                      onTap: () => setState(() => _category = c),
                    ),
                    const SizedBox(width: 8),
                  ],
                ],
              ),
            ).animate().fadeIn(delay: 100.ms, duration: 280.ms),
            const SizedBox(height: 16),
            if (list.isEmpty)
              const SoftBlogEmpty()
            else ...[
              SoftBlogFeaturedCard(
                post: list.first,
                liked: store.isLiked(user.id, list.first.id),
                bookmarked: store.isBookmarked(user.id, list.first.id),
                onOpen: () => _open(list.first),
                onLike: () => store.toggleLike(user.id, list.first),
                onBookmark: () => store.toggleBookmark(user.id, list.first.id),
              )
                  .animate()
                  .fadeIn(delay: 120.ms, duration: 320.ms)
                  .scale(begin: const Offset(0.96, 0.96), curve: Curves.easeOutBack),
              if (list.length > 1) ...[
                const SizedBox(height: 18),
                SoftBlogSectionTitle(title: 'Tüm yazılar', count: list.length - 1),
                const SizedBox(height: 10),
                for (var i = 1; i < list.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SoftBlogCard(
                      post: list[i],
                      index: i,
                      liked: store.isLiked(user.id, list[i].id),
                      bookmarked: store.isBookmarked(user.id, list[i].id),
                      onOpen: () => _open(list[i]),
                      onLike: () => store.toggleLike(user.id, list[i]),
                      onBookmark: () => store.toggleBookmark(user.id, list[i].id),
                    ),
                  ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  void _open(BlogPost post) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => SoftBlogDetailScreen(post: post, admin: widget.admin),
      ),
    );
  }
}

/// Soft premium modern blog detail.
class SoftBlogDetailScreen extends ConsumerWidget {
  const SoftBlogDetailScreen({super.key, required this.post, required this.admin});

  final BlogPost post;
  final bool admin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user!;
    final store = ref.watch(appStoreProvider);
    ref.watch(blogInteractionsProvider);
    final liked = store.isLiked(user.id, post.id);
    final bookmarked = store.isBookmarked(user.id, post.id);

    return Scaffold(
      backgroundColor: AppColors.modernWash,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 32),
          children: [
            Row(
              children: [
                const SoftNavBackButton(),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Yazı',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryDeep,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                if (admin)
                  SoftTap(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => BlogEditorScreen(existing: post),
                      ),
                    ),
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
                      child: const Icon(Icons.edit_rounded, color: AppColors.primary),
                    ),
                  ),
              ],
            ).animate().fadeIn(duration: 260.ms),
            const SizedBox(height: 14),
            SoftBlogDetailHero(post: post)
                .animate()
                .fadeIn(delay: 40.ms, duration: 300.ms)
                .slideY(begin: -0.04, curve: Curves.easeOutCubic),
            const SizedBox(height: 12),
            SoftBlogActionBar(
              post: post,
              liked: liked,
              bookmarked: bookmarked,
              onLike: () => store.toggleLike(user.id, post),
              onBookmark: () => store.toggleBookmark(user.id, post.id),
            ).animate().fadeIn(delay: 70.ms, duration: 280.ms),
            const SizedBox(height: 16),
            for (var i = 0; i < post.body.length; i++)
              SoftBlogBlock(block: post.body[i])
                  .animate()
                  .fadeIn(delay: (50 + 35 * i).ms, duration: 280.ms)
                  .slideY(begin: 0.03, curve: Curves.easeOutCubic),
          ],
        ),
      ),
    );
  }
}

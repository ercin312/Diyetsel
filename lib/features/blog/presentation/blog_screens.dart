import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/data/app_store.dart';
import '../../../core/data/providers.dart';
import '../../../core/models/models.dart';
import '../../../core/widgets/app_page.dart';
import '../../../core/widgets/diyetsel_widgets.dart';
import '../../../core/widgets/rich_editor.dart';
import '../../auth/presentation/auth_controller.dart';

const blogCategories = ['Keto', 'Aralıklı Oruç', 'Vegan', 'Akdeniz', 'Detoks', 'Spor'];

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
    final user = ref.watch(authControllerProvider).user!;
    final store = ref.watch(appStoreProvider);
    ref.watch(blogInteractionsProvider);
    var posts = (ref.watch(blogProvider).valueOrNull ?? []).where((p) => widget.admin || p.published);
    if (_category != null) posts = posts.where((p) => p.category == _category);
    if (_query.isNotEmpty) {
      posts = posts.where((p) => '${p.title} ${p.subtitle} ${p.tags.join()}'.toLowerCase().contains(_query.toLowerCase()));
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
                for (final post in posts)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: DiyetselCard(
                      onTap: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => BlogDetailScreen(post: post, admin: widget.admin))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(post.category, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800)),
                          Text(post.title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                          Text(post.subtitle),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () => store.toggleLike(user.id, post),
                                icon: Icon(store.isLiked(user.id, post.id) ? Icons.favorite : Icons.favorite_border, color: AppColors.danger),
                              ),
                              Text('${post.likes}'),
                              IconButton(
                                onPressed: () => store.toggleBookmark(user.id, post.id),
                                icon: Icon(store.isBookmarked(user.id, post.id) ? Icons.bookmark : Icons.bookmark_border),
                              ),
                            ],
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
}

class BlogDetailScreen extends StatelessWidget {
  const BlogDetailScreen({super.key, required this.post, required this.admin});
  final BlogPost post;
  final bool admin;

  @override
  Widget build(BuildContext context) {
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
          for (final block in post.body) _block(block),
        ],
      ),
    );
  }

  Widget _block(RichBlock block) {
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
          decoration: const BoxDecoration(
            border: Border(left: BorderSide(color: AppColors.primary, width: 4)),
            color: Color(0x14FF6B00),
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

class BlogEditorScreen extends ConsumerStatefulWidget {
  const BlogEditorScreen({super.key, this.existing});
  final BlogPost? existing;

  @override
  ConsumerState<BlogEditorScreen> createState() => _BlogEditorScreenState();
}

class _BlogEditorScreenState extends ConsumerState<BlogEditorScreen> {
  late final TextEditingController _title;
  late final TextEditingController _subtitle;
  String _category = blogCategories.first;
  late List<RichBlock> _body;
  bool _published = true;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _title = TextEditingController(text: e?.title ?? '');
    _subtitle = TextEditingController(text: e?.subtitle ?? '');
    _category = e?.category ?? blogCategories.first;
    _body = List.of(e?.body ?? [const RichBlock(type: 'paragraph', text: '')]);
    _published = e?.published ?? true;
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).user!;
    return AppPage(
      title: 'Yazı editörü',
      actions: [
        TextButton(
          onPressed: () async {
            final post = BlogPost(
              id: widget.existing?.id ?? newId(),
              title: _title.text,
              subtitle: _subtitle.text,
              authorId: user.id,
              authorName: user.displayName,
              category: _category,
              tags: [_category.toLowerCase()],
              body: _body,
              createdAt: widget.existing?.createdAt ?? DateTime.now(),
              updatedAt: DateTime.now(),
              published: _published,
              likes: widget.existing?.likes ?? 0,
            );
            await ref.read(appStoreProvider).saveBlog(post);
            if (context.mounted) Navigator.pop(context);
          },
          child: const Text('Yayınla'),
        ),
      ],
      child: ListView(
        children: [
          TextField(controller: _title, decoration: const InputDecoration(labelText: 'Başlık')),
          const SizedBox(height: 8),
          TextField(controller: _subtitle, decoration: const InputDecoration(labelText: 'Alt başlık')),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _category,
            items: [for (final c in blogCategories) DropdownMenuItem(value: c, child: Text(c))],
            onChanged: (v) => setState(() => _category = v ?? _category),
          ),
          SwitchListTile(value: _published, onChanged: (v) => setState(() => _published = v), title: const Text('Yayınla')),
          const SizedBox(height: 8),
          RichEditor(
            blocks: _body,
            onChanged: (b) => setState(() => _body = b),
            onPickImage: () async {
              final file = await ImagePicker().pickImage(source: ImageSource.gallery);
              if (file == null) return;
              setState(() => _body = [..._body, RichBlock(type: 'image', text: file.name, imagePath: file.path)]);
            },
          ),
        ],
      ),
    );
  }
}

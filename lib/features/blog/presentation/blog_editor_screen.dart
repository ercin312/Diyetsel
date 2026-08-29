import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/data/app_store.dart';
import '../../../core/models/models.dart';
import '../../../core/widgets/app_page.dart';
import '../../../core/widgets/rich_editor.dart';
import '../../auth/presentation/auth_controller.dart';
import '../domain/blog_visuals.dart';

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
              coverUrl: widget.existing?.coverUrl,
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

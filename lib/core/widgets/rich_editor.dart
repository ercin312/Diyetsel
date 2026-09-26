import 'package:flutter/material.dart';

import '../models/models.dart';
import 'diyetsel_widgets.dart';
import '../l10n/ui_string.dart';

class RichEditor extends StatelessWidget {
  const RichEditor({
    super.key,
    required this.blocks,
    required this.onChanged,
    required this.onPickImage,
  });

  final List<RichBlock> blocks;
  final ValueChanged<List<RichBlock>> onChanged;
  final VoidCallback onPickImage;

  void _update(int i, RichBlock block) {
    final next = [...blocks];
    next[i] = block;
    onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Wrap(
          spacing: 6,
          children: [
            ActionChip(label: Text(('Paragraf').ui), onPressed: () => onChanged([...blocks, const RichBlock(type: 'paragraph', text: '')])),
            ActionChip(label: Text(('Başlık').ui), onPressed: () => onChanged([...blocks, const RichBlock(type: 'heading', text: '', bold: true)])),
            ActionChip(label: Text(('Alıntı').ui), onPressed: () => onChanged([...blocks, const RichBlock(type: 'quote', text: '', italic: true)])),
            ActionChip(label: Text(('Liste').ui), onPressed: () => onChanged([...blocks, const RichBlock(type: 'list', text: '')])),
            ActionChip(label: Text(('Görsel').ui), onPressed: onPickImage),
          ],
        ),
        const SizedBox(height: 8),
        for (var i = 0; i < blocks.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: DiyetselCard(
              child: Column(
                children: [
                  Row(
                    children: [
                      Text((blocks[i].type).ui, style: const TextStyle(fontWeight: FontWeight.w800)),
                      const Spacer(),
                      IconButton(
                        icon: Icon(blocks[i].bold ? Icons.format_bold : Icons.format_bold_outlined),
                        onPressed: () => _update(i, RichBlock(type: blocks[i].type, text: blocks[i].text, bold: !blocks[i].bold, italic: blocks[i].italic, imagePath: blocks[i].imagePath)),
                      ),
                      IconButton(
                        icon: Icon(blocks[i].italic ? Icons.format_italic : Icons.format_italic_outlined),
                        onPressed: () => _update(i, RichBlock(type: blocks[i].type, text: blocks[i].text, bold: blocks[i].bold, italic: !blocks[i].italic, imagePath: blocks[i].imagePath)),
                      ),
                    ],
                  ),
                  TextFormField(
                    initialValue: blocks[i].text,
                    maxLines: 4,
                    onChanged: (v) => _update(i, RichBlock(type: blocks[i].type, text: v, bold: blocks[i].bold, italic: blocks[i].italic, imagePath: blocks[i].imagePath)),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

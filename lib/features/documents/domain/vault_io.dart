import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/models/models.dart';
import '../../../core/l10n/ui_string.dart';

class VaultVisuals {
  VaultVisuals._();

  static const categories = ['lab', 'plan', 'form', 'photo', 'other'];

  static String label(String cat) => switch (cat) {
        'lab' => 'Lab / tahlil',
        'plan' => 'Diyet planı',
        'form' => 'Form / sözleşme',
        'photo' => 'Fotoğraf',
        _ => 'Diğer',
      };

  static String hint(String cat) => switch (cat) {
        'lab' => 'Kan, hormon, vitamin sonuçları',
        'plan' => 'PDF menü veya diyetisyen notları',
        'form' => 'Onam, anamnez, sözleşme',
        'photo' => 'Önce-sonra veya ölçü fotoğrafları',
        _ => 'Diğer kişisel belgeler',
      };

  static IconData iconFor(String cat) => switch (cat) {
        'lab' => Icons.science_rounded,
        'plan' => Icons.menu_book_rounded,
        'form' => Icons.description_rounded,
        'photo' => Icons.photo_rounded,
        _ => Icons.folder_rounded,
      };

  static IconData iconForFile(VaultFile f) {
    final m = f.mime.toLowerCase();
    if (['png', 'jpg', 'jpeg', 'webp', 'gif', 'heic'].contains(m) || f.category == 'photo') {
      return Icons.image_rounded;
    }
    if (m == 'pdf') return Icons.picture_as_pdf_rounded;
    if (['doc', 'docx'].contains(m)) return Icons.article_rounded;
    return iconFor(f.category);
  }

  static Color tintFor(String cat) => switch (cat) {
        'lab' => AppColors.kawaiiSky,
        'plan' => AppColors.kawaiiMint,
        'form' => AppColors.kawaiiLilac,
        'photo' => AppColors.kawaiiPeach,
        _ => AppColors.kawaiiLemon,
      };

  static Color accentFor(String cat) => switch (cat) {
        'lab' => AppColors.kawaiiSkyBlue,
        'plan' => AppColors.kawaiiLeafDeep,
        'form' => AppColors.kawaiiPurple,
        'photo' => AppColors.kawaiiCoralDeep,
        _ => AppColors.kawaiiSalmon,
      };

  static String guessCategory(String name, String mime) {
    final n = name.toLowerCase();
    final m = mime.toLowerCase();
    if (['png', 'jpg', 'jpeg', 'webp', 'gif', 'heic'].contains(m)) return 'photo';
    if (n.contains('lab') || n.contains('tahlil') || n.contains('kan') || n.contains('sonuc')) return 'lab';
    if (n.contains('diyet') || n.contains('plan') || n.contains('menu') || n.contains('menü')) return 'plan';
    if (n.contains('sozlesme') || n.contains('sözleşme') || n.contains('onam') || n.contains('form')) return 'form';
    return 'other';
  }

  static String formatSize(int bytes) {
    if (bytes <= 0) return '';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  static bool isImage(VaultFile f) {
    final m = f.mime.toLowerCase();
    return ['png', 'jpg', 'jpeg', 'webp', 'gif', 'heic'].contains(m);
  }

  static bool isPdf(VaultFile f) => f.mime.toLowerCase() == 'pdf';
}

class VaultIO {
  VaultIO._();

  static Future<Directory> vaultDir() async {
    final root = await getApplicationDocumentsDirectory();
    final dir = Directory('${root.path}/diyetsel_vault');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  static Future<File> persistPickedFile({
    required String sourcePath,
    required String id,
    required String originalName,
  }) async {
    final dir = await vaultDir();
    final safe = originalName.replaceAll(RegExp(r'[^\w.\-ğüşıöçĞÜŞİÖÇ ]'), '_');
    final dest = File('${dir.path}/${id}_$safe');
    return File(sourcePath).copy(dest.path);
  }

  static Future<File> writeSeedBytes({
    required String id,
    required String fileName,
    required List<int> bytes,
  }) async {
    final dir = await vaultDir();
    final safe = fileName.replaceAll(RegExp(r'[^\w.\-ğüşıöçĞÜŞİÖÇ ]'), '_');
    final dest = File('${dir.path}/${id}_$safe');
    await dest.writeAsBytes(bytes, flush: true);
    return dest;
  }

  static Future<File> writeSeedText({
    required String id,
    required String fileName,
    required String contents,
  }) async {
    final dir = await vaultDir();
    final dest = File('${dir.path}/${id}_$fileName');
    await dest.writeAsString(contents, flush: true);
    return dest;
  }

  static Future<bool> exists(VaultFile file) async {
    try {
      return File(file.path).existsSync();
    } catch (_) {
      return false;
    }
  }

  static Future<void> open(BuildContext context, VaultFile file) async {
    final path = file.path;
    final f = File(path);
    if (!await f.exists()) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(('Dosya bulunamadı. Yeniden yüklemeyi dene.').ui)),
        );
      }
      return;
    }

    if (VaultVisuals.isImage(file)) {
      if (!context.mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => Dialog(
          backgroundColor: Colors.black,
          insetPadding: const EdgeInsets.all(16),
          child: Stack(
            children: [
              InteractiveViewer(
                child: Image.file(f, fit: BoxFit.contain),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  onPressed: () => Navigator.pop(ctx),
                  icon: const Icon(Icons.close_rounded, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
      return;
    }

    if (VaultVisuals.isPdf(file)) {
      try {
        final bytes = await f.readAsBytes();
        await Printing.layoutPdf(onLayout: (_) async => bytes, name: file.name);
        return;
      } catch (_) {
        // fall through to share
      }
    }

    await share(file);
  }

  static Future<void> share(VaultFile file) async {
    final f = File(file.path);
    if (!await f.exists()) return;
    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path, name: file.name)], text: file.name),
    );
  }

  static Future<void> deleteLocal(VaultFile file) async {
    try {
      final f = File(file.path);
      if (await f.exists()) await f.delete();
    } catch (_) {}
  }
}

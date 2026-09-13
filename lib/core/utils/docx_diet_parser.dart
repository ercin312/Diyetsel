import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:uuid/uuid.dart';
import 'package:xml/xml.dart';

import '../models/enums.dart';
import '../models/models.dart';

/// Parses a Word `.docx` into diet meals using Turkish section headings.
///
/// Expected headings (case-insensitive): Kahvaltı, Sabah Ara / Ara Öğün,
/// Öğle, İkindi / Ara Öğün 2, Akşam.
class DocxDietParser {
  DocxDietParser._();

  static final _uuid = const Uuid();

  static List<DietMeal> parseBytes(Uint8List bytes) {
    final archive = ZipDecoder().decodeBytes(bytes);
    final entry = archive.findFile('word/document.xml');
    if (entry == null) {
      throw StateError('Geçersiz Word dosyası (document.xml yok).');
    }
    final xmlBytes = entry.content as List<int>;
    final xml = utf8.decode(xmlBytes, allowMalformed: true);
    final text = _extractPlainText(xml);
    return parsePlainText(text);
  }

  static String _extractPlainText(String xml) {
    final doc = XmlDocument.parse(xml);
    final buffer = StringBuffer();
    for (final p in doc.findAllElements('w:p')) {
      final parts = <String>[];
      for (final t in p.findAllElements('w:t')) {
        parts.add(t.innerText);
      }
      final line = parts.join().trim();
      if (line.isNotEmpty) {
        buffer.writeln(line);
      } else {
        buffer.writeln();
      }
    }
    return buffer.toString();
  }

  static List<DietMeal> parsePlainText(String text) {
    final lines = text.split(RegExp(r'\r?\n'));
    MealType? current;
    final buckets = <MealType, List<String>>{};

    for (final raw in lines) {
      final line = raw.trim();
      if (line.isEmpty) continue;
      final heading = _matchHeading(line);
      if (heading != null) {
        current = heading;
        buckets.putIfAbsent(current, () => []);
        continue;
      }
      if (current != null) {
        buckets.putIfAbsent(current, () => []).add(line);
      }
    }

    if (buckets.isEmpty) {
      throw StateError(
        'Öğün başlığı bulunamadı. Dosyada Kahvaltı, Öğle, Akşam gibi başlıklar olmalı.',
      );
    }

    final meals = <DietMeal>[];
    for (final type in MealType.values) {
      final body = buckets[type];
      if (body == null || body.isEmpty) continue;
      final name = body.first;
      final description = body.length > 1 ? body.skip(1).join('\n') : body.first;
      final ingredients = _ingredientsFromBody(body);
      meals.add(
        DietMeal(
          id: _uuid.v4(),
          type: type,
          name: name.length > 80 ? type.tr : name,
          description: description,
          calories: 0,
          protein: 0,
          carbs: 0,
          fat: 0,
          ingredients: ingredients,
          reminderTime: type.defaultReminderTime,
        ),
      );
    }
    return meals;
  }

  static Ingredient _tokenToIngredient(String raw) {
    final pieces = raw
        .split(RegExp(r'\s*[+&]\s*'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    // Multi-product line: keep first as this ingredient; callers that need all
    // products should split earlier. For Word body we expand below.
    if (pieces.length > 1) {
      return _tokenToIngredient(pieces.first);
    }

    final t = raw.trim();
    // Prefer "150 g yoğurt" / "yoğurt 150 g" over swallowing food after "adet".
    final trailingAmt = RegExp(
      r'^(.*?)\s+(\d+(?:[.,]\d+)?\s*(?:g|kg|ml|lt|l))\s*$',
      caseSensitive: false,
    ).firstMatch(t);
    if (trailingAmt != null) {
      final name = trailingAmt.group(1)!.trim();
      return Ingredient(
        name: name.isEmpty ? t : '${name[0].toUpperCase()}${name.substring(1)}',
        amount: trailingAmt.group(2)!.trim(),
      );
    }
    final leadingAmt = RegExp(
      r'^(\d+(?:[.,]\d+)?\s*(?:g|kg|ml|lt|l))\s+(.+)$',
      caseSensitive: false,
    ).firstMatch(t);
    if (leadingAmt != null) {
      final name = leadingAmt.group(2)!.trim();
      return Ingredient(
        name: name.isEmpty ? t : '${name[0].toUpperCase()}${name.substring(1)}',
        amount: leadingAmt.group(1)!.trim(),
      );
    }

    return Ingredient(
      name: t.isEmpty ? raw : '${t[0].toUpperCase()}${t.substring(1)}',
      amount: '',
    );
  }

  /// Expand body lines that contain "+" into multiple ingredients.
  static List<Ingredient> _ingredientsFromBody(List<String> body) {
    if (body.length < 2) return const [];
    final lines = body
        .skip(1)
        .map((e) => e.replaceFirst(RegExp(r'^[\s\-\*•·\d\.\)\(]+'), '').trim())
        .where((e) => e.isNotEmpty && e.length < 80)
        .toList();
    if (lines.isEmpty) return const [];

    final expanded = <String>[];
    for (final line in lines) {
      final parts = line
          .split(RegExp(r'\s*[+&]\s*'))
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      if (parts.length >= 2) {
        expanded.addAll(parts);
      } else {
        expanded.add(line);
      }
    }

    if (expanded.length >= 2) {
      return [for (final line in expanded) _tokenToIngredient(line)];
    }

    final one = expanded.first;
    final parts = one
        .split(RegExp(r'[,;/•·|]'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty && e.length < 48)
        .toList();
    if (parts.length >= 2) {
      return [for (final p in parts) _tokenToIngredient(p)];
    }
    return [_tokenToIngredient(one)];
  }

  static MealType? _matchHeading(String line) {
    final n = _normalize(line);
    // Prefer specific before generic "ara ogun"
    if (n.contains('kahvalti')) return MealType.breakfast;
    if (n.contains('ikindi') || n.contains('ara ogun 2') || n.contains('araogun2')) {
      return MealType.afternoonSnack;
    }
    if (n.contains('sabah ara') ||
        n.contains('ara ogun 1') ||
        n.contains('araogun1') ||
        n == 'ara ogun' ||
        n.startsWith('ara ogun ')) {
      return MealType.morningSnack;
    }
    if (n.contains('ogle')) return MealType.lunch;
    if (n.contains('aksam')) return MealType.dinner;
    return null;
  }

  static String _normalize(String s) {
    var t = s.toLowerCase().trim();
    const map = {
      'ç': 'c',
      'ğ': 'g',
      'ı': 'i',
      'ö': 'o',
      'ş': 's',
      'ü': 'u',
      'â': 'a',
      'î': 'i',
      'û': 'u',
    };
    map.forEach((k, v) => t = t.replaceAll(k, v));
    return t.replaceAll(RegExp(r'\s+'), ' ');
  }
}

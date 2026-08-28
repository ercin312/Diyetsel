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
          reminderTime: type.defaultReminderTime,
        ),
      );
    }
    return meals;
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

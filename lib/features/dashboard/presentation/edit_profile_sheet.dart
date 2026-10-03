import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/ui_string.dart';
import '../../../core/models/models.dart';
import '../../auth/presentation/auth_controller.dart';

Future<void> showEditProfileSheet(BuildContext context, WidgetRef ref) async {
  final user = ref.read(authControllerProvider).user;
  if (user == null) return;
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (ctx) => _EditProfileSheet(user: user),
  );
}

class _EditProfileSheet extends ConsumerStatefulWidget {
  const _EditProfileSheet({required this.user});

  final UserProfile user;

  @override
  ConsumerState<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends ConsumerState<_EditProfileSheet> {
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _height;
  late final TextEditingController _weight;
  late final TextEditingController _water;
  var _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final user = widget.user;
    _name = TextEditingController(text: user.displayName);
    _phone = TextEditingController(text: user.phone ?? '');
    _height = TextEditingController(text: user.heightCm == null ? '' : _num(user.heightCm!));
    _weight = TextEditingController(text: user.targetWeightKg == null ? '' : _num(user.targetWeightKg!));
    _water = TextEditingController(text: (user.waterGoalMl / 1000).toStringAsFixed(1));
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _height.dispose();
    _weight.dispose();
    _water.dispose();
    super.dispose();
  }

  String _num(double value) {
    if (value == value.roundToDouble()) return '${value.round()}';
    return value.toStringAsFixed(1);
  }

  double? _read(TextEditingController controller) {
    final text = controller.text.trim().replaceAll(',', '.');
    if (text.isEmpty) return null;
    return double.tryParse(text);
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.length < 2) {
      setState(() => _error = 'Ad soyad en az 2 karakter olmalı.');
      return;
    }
    final height = _read(_height);
    final weight = _read(_weight);
    if (_height.text.trim().isNotEmpty && (height == null || height < 50 || height > 250)) {
      setState(() => _error = 'Boyu 50 ile 250 cm arasında yaz.');
      return;
    }
    if (_weight.text.trim().isNotEmpty && (weight == null || weight < 20 || weight > 400)) {
      setState(() => _error = 'Hedef kiloyu 20 ile 400 kg arasında yaz.');
      return;
    }
    int? waterMl;
    if (!widget.user.isAdmin) {
      final liters = _read(_water);
      if (liters == null || liters < 1 || liters > 6) {
        setState(() => _error = 'Su hedefini 1 ile 6 litre arasında yaz.');
        return;
      }
      waterMl = (liters * 1000).round();
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(authControllerProvider.notifier).saveProfileDetails(
            displayName: name,
            phone: _phone.text,
            heightCm: height,
            targetWeightKg: weight,
            waterGoalMl: waterMl,
          );
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(('Profilin güncellendi.').ui)),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = e.toString().replaceFirst('Bad state: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 16 + bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(('Profilini düzenle').ui,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text((widget.user.email).ui,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(labelText: ('Ad soyad').ui),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(labelText: ('Telefon').ui),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _height,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: ('Boy (cm)').ui),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _weight,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: ('Hedef kilo (kg)').ui),
            ),
            if (!widget.user.isAdmin) ...[
              const SizedBox(height: 10),
              TextField(
                controller: _water,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: ('Günlük su hedefi (L)').ui),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text((_error!).ui, style: TextStyle(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.w700)),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: Text((_saving ? 'Kaydediliyor…' : 'Kaydet').ui),
            ),
          ],
        ),
      ),
    );
  }
}

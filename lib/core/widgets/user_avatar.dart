import 'dart:io';

import 'package:flutter/material.dart';

/// Profile photo, or a plain silhouette when none is set.
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    this.photoUrl,
    this.size = 48,
    this.onTap,
    this.borderColor,
  });

  final String? photoUrl;
  final double size;
  final VoidCallback? onTap;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFE4E6EB),
        border: Border.all(color: borderColor ?? const Color(0xFFD0D3D8), width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: _photo(photoUrl, size) ??
          Icon(Icons.person, size: size * 0.62, color: const Color(0xFF8D949E)),
    );
    if (onTap == null) return avatar;
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: avatar,
      ),
    );
  }

  Widget? _photo(String? url, double size) {
    final value = url?.trim() ?? '';
    if (value.isEmpty) return null;
    final fallback = Icon(Icons.person, size: size * 0.62, color: const Color(0xFF8D949E));
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return Image.network(
        value,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => fallback,
      );
    }
    final file = File(value);
    if (!file.existsSync()) return null;
    return Image.file(file, fit: BoxFit.cover);
  }
}

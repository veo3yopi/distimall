import 'package:flutter/material.dart';

class BannerItem {
  const BannerItem({
    required this.title,
    required this.subtitle,
    this.imageUrl,
    this.backgroundColor,
  });

  final String title;
  final String subtitle;
  final String? imageUrl;
  final Color? backgroundColor;

  factory BannerItem.fromJson(Map<String, dynamic> json) {
    return BannerItem(
      title: (json['title'] ?? json['name'] ?? '').toString(),
      subtitle: (json['subtitle'] ?? json['tagline'] ?? '').toString(),
      imageUrl: _stringOrNull(json['image'] ?? json['image_url']),
      backgroundColor: _parseColor(json['background_color'] ?? json['color']),
    );
  }

  static String? _stringOrNull(dynamic value) {
    if (value == null) {
      return null;
    }
    final text = value.toString();
    return text.isEmpty ? null : text;
  }

  static Color? _parseColor(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is int) {
      return Color(value);
    }
    if (value is String) {
      final cleaned = value.replaceAll('#', '').trim();
      if (cleaned.length == 6 || cleaned.length == 8) {
        final hex = cleaned.length == 6 ? 'FF$cleaned' : cleaned;
        final parsed = int.tryParse(hex, radix: 16);
        if (parsed != null) {
          return Color(parsed);
        }
      }
    }
    return null;
  }
}

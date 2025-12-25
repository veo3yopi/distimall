import 'package:flutter/material.dart';

class BannerItem {
  const BannerItem({
    this.id,
    required this.title,
    required this.subtitle,
    this.imageUrl,
    this.backgroundColor,
    this.ctaText,
    this.ctaLink,
    this.isActive,
    this.sortOrder,
  });

  final int? id;
  final String title;
  final String subtitle;
  final String? imageUrl;
  final Color? backgroundColor;
  final String? ctaText;
  final String? ctaLink;
  final bool? isActive;
  final int? sortOrder;

  factory BannerItem.fromJson(Map<String, dynamic> json) {
    return BannerItem(
      id: _intOrNull(json['id']),
      title: (json['title'] ?? json['name'] ?? '').toString(),
      subtitle: (json['subtitle'] ?? json['tagline'] ?? '').toString(),
      imageUrl: _stringOrNull(json['image'] ?? json['image_url']),
      backgroundColor: _parseColor(json['background_color'] ?? json['color']),
      ctaText: _stringOrNull(json['cta_text']),
      ctaLink: _stringOrNull(json['cta_link']),
      isActive: json['is_active'] is bool ? json['is_active'] as bool : null,
      sortOrder: _intOrNull(json['sort_order']),
    );
  }

  BannerItem copyWith({
    int? id,
    String? title,
    String? subtitle,
    String? imageUrl,
    Color? backgroundColor,
    String? ctaText,
    String? ctaLink,
    bool? isActive,
    int? sortOrder,
  }) {
    return BannerItem(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      imageUrl: imageUrl ?? this.imageUrl,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      ctaText: ctaText ?? this.ctaText,
      ctaLink: ctaLink ?? this.ctaLink,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  static String? _stringOrNull(dynamic value) {
    if (value == null) {
      return null;
    }
    final text = value.toString();
    return text.isEmpty ? null : text;
  }

  static int? _intOrNull(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is int) {
      return value;
    }
    return int.tryParse(value.toString());
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

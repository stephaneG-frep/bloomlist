import 'package:flutter/material.dart';

class ProjectItem {
  const ProjectItem({
    required this.id,
    required this.name,
    required this.createdAt,
    this.colorValue = 0xFF4F46E5,
    this.iconCodePoint = 0xe0af,
    this.isArchived = false,
  });

  final String id;
  final String name;
  final DateTime createdAt;
  final int colorValue;
  final int iconCodePoint;
  final bool isArchived;

  Color get color => Color(colorValue);

  IconData get icon => IconData(iconCodePoint, fontFamily: 'MaterialIcons');

  ProjectItem copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    int? colorValue,
    int? iconCodePoint,
    bool? isArchived,
  }) {
    return ProjectItem(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      colorValue: colorValue ?? this.colorValue,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'colorValue': colorValue,
      'iconCodePoint': iconCodePoint,
      'isArchived': isArchived,
    };
  }

  factory ProjectItem.fromMap(Map<dynamic, dynamic> map) {
    return ProjectItem(
      id: map['id'] as String,
      name: map['name'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      colorValue: (map['colorValue'] as int?) ?? 0xFF4F46E5,
      iconCodePoint: (map['iconCodePoint'] as int?) ?? 0xe0af,
      isArchived: (map['isArchived'] as bool?) ?? false,
    );
  }
}

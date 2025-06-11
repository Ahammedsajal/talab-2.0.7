import 'package:flutter/material.dart';

class IconMapper {
  static const Map<String, IconData> _iconMap = {
    'home': Icons.home,
    'bed': Icons.bed,
    'bedroom': Icons.bed,
    'bath': Icons.bathtub,
    'bathroom': Icons.bathtub,
    'area': Icons.square_foot,
    'garage': Icons.garage,
    'calendar': Icons.calendar_today,
    'clock': Icons.access_time,
    'phone': Icons.phone,
    'email': Icons.email,
    'location': Icons.location_on,
    'star': Icons.star,
  };

  static IconData map(String? iconName) {
    if (iconName == null) return Icons.info_outline;
    return _iconMap[iconName] ?? Icons.info_outline;
  }
}

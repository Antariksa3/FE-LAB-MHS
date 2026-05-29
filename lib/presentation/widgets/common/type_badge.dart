import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class TypeBadge extends StatelessWidget {
  final String type;
  const TypeBadge({super.key, required this.type});

  Color get _color => switch (type) {
    'Sword' => AppColors.typeSword,
    'Claymore' => AppColors.typeClaymore,
    'Polearm' => AppColors.typePolearm,
    'Catalyst' => AppColors.typeCatalyst,
    'Bow' => AppColors.typeBow,
    _ => AppColors.textSecondary,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withOpacity(0.6)),
      ),
      child: Text(
        type,
        style: TextStyle(
          color: _color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

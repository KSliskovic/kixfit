import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';

class MacroRing extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final double size;
  final double strokeWidth;
  final Color color;
  final String label;
  final String value;
  final Color? backgroundColor;

  const MacroRing({
    super.key,
    required this.progress,
    this.size = 100,
    this.strokeWidth = 10,
    required this.color,
    required this.label,
    required this.value,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Ring
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: strokeWidth,
              color: backgroundColor ?? AppColors.glassStroke,
            ),
          ),
          // Progress Ring
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              strokeWidth: strokeWidth,
              color: color,
              strokeCap: StrokeCap.round,
            ),
          ),
          // Center Text
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: AppTypography.labelLg.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: size * 0.18,
                ),
              ),
              Text(
                label,
                style: AppTypography.caption.copyWith(
                  fontSize: size * 0.12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../domain/entities/captured_photo.dart';

class CapturedPhotoPreview extends StatelessWidget {
  const CapturedPhotoPreview({
    super.key,
    this.photo,
    required this.index,
  });

  final CapturedPhoto? photo;
  final int index;

  @override
  Widget build(BuildContext context) {
    final bool isCaptured = photo != null;
    final theme = Theme.of(context);

    final Color backgroundColor = isCaptured
        ? Color(photo!.placeholderColor)
        : theme.colorScheme.surfaceContainerHighest;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: backgroundColor,
        border: Border.all(
          color: isCaptured
              ? theme.colorScheme.onPrimary.withOpacity(0.6)
              : theme.colorScheme.outlineVariant,
          width: 1.5,
        ),
        boxShadow: isCaptured
            ? [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Stack(
        children: [
          if (!isCaptured)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.camera_alt_outlined, size: 42),
                  const SizedBox(height: AppSizes.sm),
                  Text(
                    'Photo ${index + 1}',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            )
          else if (photo!.imageBytes != null)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.memory(
                  photo!.imageBytes!,
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                ),
              ),
            )
          else
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [
                      backgroundColor.withOpacity(0.95),
                      backgroundColor.withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          Positioned(
            left: AppSizes.sm,
            top: AppSizes.sm,
            child: CircleAvatar(
              backgroundColor:
                  theme.colorScheme.onSurface.withOpacity(0.75),
              radius: 16,
              child: Text(
                '${index + 1}',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.surface,
                ),
              ),
            ),
          ),
          if (isCaptured)
            Positioned(
              right: AppSizes.sm,
              bottom: AppSizes.sm,
              child: Icon(
                Icons.check_circle,
                color: theme.colorScheme.onPrimaryContainer,
                size: 28,
              ),
            ),
        ],
      ),
    );
  }
}


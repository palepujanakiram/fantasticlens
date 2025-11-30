import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../domain/entities/photo_template.dart';

class TemplateCard extends StatelessWidget {
  const TemplateCard({
    super.key,
    required this.template,
    required this.onTap,
  });

  final PhotoTemplate template;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final themeData = template.theme;
    final gradientColors = themeData.backgroundGradient
        .map((color) => Color(color))
        .toList(growable: false);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: gradientColors.length > 1
                      ? LinearGradient(
                          colors: gradientColors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: gradientColors.isEmpty
                      ? Color(themeData.primaryColor)
                      : null,
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: AppSizes.md,
                      bottom: AppSizes.md,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Color(themeData.accentColor).withOpacity(0.8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.md,
                            vertical: AppSizes.xs,
                          ),
                          child: Text(
                            '${template.photoCount} photos',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                  color: Colors.white,
                                ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.lg,
                AppSizes.lg,
                AppSizes.lg,
                AppSizes.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    template.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSizes.xs),
                  Text(
                    template.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSizes.sm),
                  Row(
                    children: [
                      const Icon(Icons.timer, size: 18),
                      const SizedBox(width: AppSizes.xs),
                      Text(
                        'Interval ${template.captureInterval.inSeconds}s',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.lg,
                0,
                AppSizes.lg,
                AppSizes.lg,
              ),
              child: FilledButton(
                onPressed: onTap,
                child: const Text('Start session'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


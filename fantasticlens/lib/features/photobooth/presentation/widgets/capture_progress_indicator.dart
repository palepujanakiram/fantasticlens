import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';

class CaptureProgressIndicator extends StatelessWidget {
  const CaptureProgressIndicator({
    super.key,
    required this.total,
    required this.completed,
    required this.isProcessing,
  });

  final int total;
  final int completed;
  final bool isProcessing;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final double progress =
        total == 0 ? 0 : (completed.clamp(0, total) / total);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isProcessing
                  ? 'Processing session...'
                  : 'Capture progress: $completed of $total',
              style: textTheme.titleMedium,
            ),
            if (isProcessing)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
        const SizedBox(height: AppSizes.sm),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
          ),
        ),
      ],
    );
  }
}


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/router/app_router.dart';
import '../providers/photo_booth_providers.dart';
import '../widgets/captured_photo_preview.dart';
import '../widgets/primary_button.dart';

class SessionResultPage extends ConsumerWidget {
  const SessionResultPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(photoBoothControllerProvider);
    final controller = ref.read(photoBoothControllerProvider.notifier);

    final processedPhoto = state.processedPhoto;
    final template = state.selectedTemplate;

    if (processedPhoto == null || template == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context)
              .popUntil((route) => route.isFirst);
        }
      });
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Session complete'),
        actions: [
          TextButton(
            onPressed: () {
              controller.resetSession();
              Navigator.of(context)
                  .popUntil((route) => route.isFirst);
            },
            child: const Text('Finish'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI-enhanced photo ready!',
              style: theme.textTheme.headlineLarge,
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              'Share the final composite or start a new session with your guests.',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: AppSizes.lg),
            _ProcessedPhotoPreview(
              placeholderColor: processedPhoto.placeholderColor,
              templateName: template.name,
            ),
            const SizedBox(height: AppSizes.lg),
            Text(
              'Captured moments',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: AppSizes.sm),
            Wrap(
              spacing: AppSizes.md,
              runSpacing: AppSizes.md,
              children: [
                for (var i = 0; i < state.capturedPhotos.length; i++)
                  SizedBox(
                    width: 160,
                    height: 200,
                    child: CapturedPhotoPreview(
                      photo: state.capturedPhotos[i],
                      index: i,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSizes.xl),
            Text(
              'Share or print',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: AppSizes.md),
            Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    label: 'Send to WhatsApp',
                    icon: Icons.sms,
                    onPressed: () => _showActionConfirmation(
                      context,
                      'WhatsApp share scheduled.',
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: PrimaryButton(
                    label: 'Print photo',
                    icon: Icons.print,
                    onPressed: () => _showActionConfirmation(
                      context,
                      'Photo sent to the printer queue.',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.lg),
            OutlinedButton.icon(
              onPressed: () {
                controller.resetSession();
                Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRoutes.templates,
                  (route) => false,
                );
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Start new session'),
            ),
          ],
        ),
      ),
    );
  }

  void _showActionConfirmation(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _ProcessedPhotoPreview extends StatelessWidget {
  const _ProcessedPhotoPreview({
    required this.placeholderColor,
    required this.templateName,
  });

  final int placeholderColor;
  final String templateName;

  @override
  Widget build(BuildContext context) {
    final Color baseColor = Color(placeholderColor);
    return Card(
      elevation: 6,
      child: SizedBox(
        width: double.infinity,
        height: 360,
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      baseColor.withOpacity(0.9),
                      baseColor.withOpacity(0.7),
                      baseColor.withOpacity(0.5),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.auto_awesome,
                    size: 64,
                    color: Colors.white,
                  ),
                  const SizedBox(height: AppSizes.sm),
                  Text(
                    templateName,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                  const SizedBox(height: AppSizes.xs),
                  Text(
                    'Enhanced composite ready to share',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white70,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


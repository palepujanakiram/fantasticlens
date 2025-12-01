import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/presentation/widgets/app_async_value_widget.dart';
import '../../../../core/router/app_router.dart';
import '../../domain/entities/photo_template.dart';
import '../providers/photo_booth_providers.dart';
import '../widgets/template_card.dart';

class TemplateSelectionPage extends ConsumerStatefulWidget {
  const TemplateSelectionPage({super.key});

  @override
  ConsumerState<TemplateSelectionPage> createState() =>
      _TemplateSelectionPageState();
}

class _TemplateSelectionPageState
    extends ConsumerState<TemplateSelectionPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = ref.read(photoBoothControllerProvider.notifier);
      controller.resetSession(preserveCamera: true);
      controller.loadAvailableCameras();
    });
  }

  @override
  Widget build(BuildContext context) {
    final templatesValue = ref.watch(photoTemplatesProvider);
    final boothState = ref.watch(photoBoothControllerProvider);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fantastic Lens'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.lg,
          vertical: AppSizes.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose your photo experience',
              style: textTheme.headlineLarge,
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              'Select a template to begin the photo booth session. '
              'Each template defines the number of shots and visual style.',
              style: textTheme.bodyLarge,
            ),
            if (!boothState.isCameraReady && !boothState.isCameraLoading)
              Padding(
                padding: const EdgeInsets.only(top: AppSizes.lg),
                child: _CameraPermissionNotice(
                  message: boothState.cameraError ??
                      'Unable to access the camera. Check permissions or camera access settings.',
                  onOpenSettings: () => ref
                      .read(photoBoothControllerProvider.notifier)
                      .openCameraSettings(),
                  onRetry: () => ref
                      .read(photoBoothControllerProvider.notifier)
                      .ensureCameraAvailable(),
                ),
              ),
            const SizedBox(height: AppSizes.lg),
            Expanded(
              child: AppAsyncValueWidget<List<PhotoTemplate>>(
                value: templatesValue,
                dataBuilder: (templates) => _TemplateGrid(
                  templates: templates,
                  onSelect: (template) =>
                      _onTemplateSelected(context, ref, template),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onTemplateSelected(
    BuildContext context,
    WidgetRef ref,
    PhotoTemplate template,
  ) async {
    final controller = ref.read(photoBoothControllerProvider.notifier);
    final cameraReady = await controller.ensureCameraAvailable();
    if (!cameraReady) {
      final state = ref.read(photoBoothControllerProvider);
      final message = state.cameraError ??
          'Unable to access the camera. Check permissions or camera access settings.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      return;
    }
    controller.startSession(template);
    if (!mounted) {
      return;
    }
    Navigator.of(context).pushNamed(AppRoutes.capture);
  }
}

class _CameraPermissionNotice extends StatelessWidget {
  const _CameraPermissionNotice({
    required this.message,
    required this.onOpenSettings,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onOpenSettings;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.4),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSizes.sm),
            Row(
              children: [
                FilledButton.icon(
                  onPressed: onOpenSettings,
                  icon: const Icon(Icons.settings),
                  label: const Text('Open camera settings'),
                ),
                const SizedBox(width: AppSizes.sm),
                TextButton(
                  onPressed: onRetry,
                  child: const Text('Try again'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TemplateGrid extends StatelessWidget {
  const _TemplateGrid({
    required this.templates,
    required this.onSelect,
  });

  final List<PhotoTemplate> templates;
  final ValueChanged<PhotoTemplate> onSelect;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final bool isWide = width >= 900;
        final bool isTablet = width >= 600;

        final int crossAxisCount = isWide
            ? 3
            : isTablet
                ? 2
                : 1;

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: AppSizes.md,
            mainAxisSpacing: AppSizes.md,
            childAspectRatio: isTablet ? 1.2 : 1.0,
          ),
          itemCount: templates.length,
          itemBuilder: (context, index) {
            final template = templates[index];
            return TemplateCard(
              template: template,
              onTap: () => onSelect(template),
            );
          },
        );
      },
    );
  }
}


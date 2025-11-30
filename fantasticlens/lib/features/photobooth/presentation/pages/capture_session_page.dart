import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/router/app_router.dart';
import '../providers/photo_booth_providers.dart';
import '../state/photo_booth_state.dart';
import '../widgets/capture_progress_indicator.dart';
import '../widgets/captured_photo_preview.dart';
import '../widgets/primary_button.dart';

class CaptureSessionPage extends ConsumerStatefulWidget {
  const CaptureSessionPage({super.key});

  @override
  ConsumerState<CaptureSessionPage> createState() =>
      _CaptureSessionPageState();
}

class _CaptureSessionPageState extends ConsumerState<CaptureSessionPage> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final template = ref.read(photoBoothControllerProvider).selectedTemplate;
    if (template == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(photoBoothControllerProvider);
    final template = state.selectedTemplate;

    if (template == null) {
      return const SizedBox.shrink();
    }

    final controller =
        ref.read(photoBoothControllerProvider.notifier);

    final int total = template.photoCount;
    final int captured = state.capturedPhotos.length;

    final bool isProcessing =
        state.status == PhotoBoothStatus.processing;
    final bool showProcessButton = state.canProcess;
    final bool showCaptureButton = state.canCapture;

    return Scaffold(
      appBar: AppBar(
        title: Text('Capturing • ${template.name}'),
        actions: [
          TextButton(
            onPressed: () {
              controller.resetSession();
              Navigator.of(context)
                  .popUntil((route) => route.isFirst);
            },
            child: const Text('Change template'),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 0,
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withOpacity(0.65),
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        template.name,
                        style:
                            Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSizes.xs),
                      Text(
                        template.description,
                        style:
                            Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: AppSizes.sm),
                      Row(
                        children: [
                          const Icon(Icons.timer_outlined, size: 18),
                          const SizedBox(width: AppSizes.xs),
                          Text(
                            'Interval ${template.captureInterval.inSeconds}s',
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.lg),
              CaptureProgressIndicator(
                total: total,
                completed: captured,
                isProcessing: isProcessing,
              ),
              const SizedBox(height: AppSizes.lg),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final double width = constraints.maxWidth;
                    final bool isWide = width >= 960;
                    final bool isTablet = width >= 600;
                    final int crossAxisCount = isWide
                        ? 3
                        : isTablet
                            ? 2
                            : 1;

                    return GridView.builder(
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: AppSizes.md,
                        mainAxisSpacing: AppSizes.md,
                        childAspectRatio: isTablet ? 0.9 : 0.85,
                      ),
                      itemCount: total,
                      itemBuilder: (context, index) {
                        final photo = state.capturedPhotos.length > index
                            ? state.capturedPhotos[index]
                            : null;
                        return CapturedPhotoPreview(
                          photo: photo,
                          index: index,
                        );
                      },
                    );
                  },
                ),
              ),
              if (state.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSizes.md),
                  child: Text(
                    state.errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              Row(
                children: [
                  if (showCaptureButton)
                    Expanded(
                      child: PrimaryButton(
                        label:
                            'Capture photo ${captured + 1}',
                        onPressed: state.isCaptureInProgress
                            ? null
                            : controller.captureNextPhoto,
                        isLoading: state.isCaptureInProgress &&
                            !showProcessButton,
                      ),
                    ),
                  if (showCaptureButton && showProcessButton)
                    const SizedBox(width: AppSizes.md),
                  if (showProcessButton)
                    Expanded(
                      child: PrimaryButton(
                        label: 'Process session',
                        icon: Icons.bolt,
                        onPressed: state.isCaptureInProgress
                            ? null
                            : () async {
                                await controller.processSession();
                                if (!mounted) {
                                  return;
                                }
                                if (ref
                                        .read(photoBoothControllerProvider)
                                        .status ==
                                    PhotoBoothStatus.completed) {
                                  Navigator.of(context)
                                      .pushReplacementNamed(
                                          AppRoutes.result);
                                }
                              },
                        isLoading: isProcessing,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


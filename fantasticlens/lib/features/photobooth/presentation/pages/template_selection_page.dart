import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/presentation/widgets/app_async_value_widget.dart';
import '../../../../core/router/app_router.dart';
import '../../domain/entities/photo_template.dart';
import '../providers/photo_booth_providers.dart';
import '../widgets/template_card.dart';

class TemplateSelectionPage extends ConsumerWidget {
  const TemplateSelectionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templatesValue = ref.watch(photoTemplatesProvider);
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

  void _onTemplateSelected(
    BuildContext context,
    WidgetRef ref,
    PhotoTemplate template,
  ) {
    ref.read(photoBoothControllerProvider.notifier).startSession(template);
    Navigator.of(context).pushNamed(AppRoutes.capture);
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


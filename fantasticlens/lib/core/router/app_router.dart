import 'package:flutter/material.dart';

import '../../features/photobooth/presentation/pages/capture_session_page.dart';
import '../../features/photobooth/presentation/pages/session_result_page.dart';
import '../../features/photobooth/presentation/pages/template_selection_page.dart';

class AppRouter {
  static const String initialRoute = AppRoutes.templates;

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.templates:
        return MaterialPageRoute<void>(
          builder: (_) => const TemplateSelectionPage(),
          settings: settings,
        );
      case AppRoutes.capture:
        return MaterialPageRoute<void>(
          builder: (_) => const CaptureSessionPage(),
          settings: settings,
        );
      case AppRoutes.result:
        return MaterialPageRoute<void>(
          builder: (_) => const SessionResultPage(),
          settings: settings,
        );
      default:
        return MaterialPageRoute<void>(
          builder: (_) => const _UnknownRoutePage(),
          settings: settings,
        );
    }
  }
}

class AppRoutes {
  static const String templates = '/';
  static const String capture = '/capture';
  static const String result = '/result';
}

class _UnknownRoutePage extends StatelessWidget {
  const _UnknownRoutePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page not found')),
      body: const Center(
        child: Text('The page you are looking for does not exist.'),
      ),
    );
  }
}


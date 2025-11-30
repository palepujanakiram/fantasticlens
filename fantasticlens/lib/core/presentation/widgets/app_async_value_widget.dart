import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppAsyncValueWidget<T> extends StatelessWidget {
  const AppAsyncValueWidget({
    super.key,
    required this.value,
    required this.dataBuilder,
    this.loadingBuilder,
    this.errorBuilder,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) dataBuilder;
  final WidgetBuilder? loadingBuilder;
  final Widget Function(Object error, StackTrace? stackTrace)? errorBuilder;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: dataBuilder,
      loading: () =>
          loadingBuilder?.call(context) ?? const _DefaultLoadingIndicator(),
      error: (error, stackTrace) =>
          errorBuilder?.call(error, stackTrace) ??
          _DefaultErrorState(error: error.toString()),
    );
  }
}

class _DefaultLoadingIndicator extends StatelessWidget {
  const _DefaultLoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _DefaultErrorState extends StatelessWidget {
  const _DefaultErrorState({required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}


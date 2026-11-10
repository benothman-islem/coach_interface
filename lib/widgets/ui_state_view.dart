import 'package:flutter/material.dart';

import '../models/ui_state.dart';
import '../theme/app_theme.dart';

class UiStateView<T> extends StatelessWidget {
  const UiStateView({
    required this.state,
    required this.onRetry,
    required this.onSuccess,
    required this.emptyMessage,
    super.key,
  });

  final UiState<T> state;
  final VoidCallback onRetry;
  final Widget Function(T value) onSuccess;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) => switch (state) {
    UiLoading<T>() => const Center(
      child: CircularProgressIndicator(color: AppColors.lime),
    ),
    UiSuccess<T>(:final value) => onSuccess(value),
    UiEmpty<T>() => _MessageState(
      message: emptyMessage,
      actionLabel: 'Actualiser',
      onAction: onRetry,
    ),
    UiError<T>() => _MessageState(
      message: 'Une erreur est survenue. Vérifiez votre connexion.',
      actionLabel: 'Réessayer',
      onAction: onRetry,
    ),
  };
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: onAction,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.lime,
              side: const BorderSide(color: AppColors.border),
            ),
            child: Text(actionLabel),
          ),
        ],
      ),
    ),
  );
}

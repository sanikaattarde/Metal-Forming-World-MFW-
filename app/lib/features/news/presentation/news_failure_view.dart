import 'package:flutter/material.dart';
import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/features/news/presentation/news_text.dart';

/// A failed news read: the message, and a retry when the failure is
/// retryable (RS FR-STATE-003, FR-STATE-005; CODING_STANDARDS section 6.1).
class NewsFailureView extends StatelessWidget {
  /// Creates the view for [failure].
  const NewsFailureView({
    required this.failure,
    required this.onRetry,
    super.key,
  });

  /// What went wrong.
  final AppFailure failure;

  /// Reads again.
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(NewsText.failure(failure), textAlign: TextAlign.center),
            if (failure.retryable) ...<Widget>[
              const SizedBox(height: 16),
              FilledButton(
                onPressed: onRetry,
                child: const Text(NewsText.retry),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

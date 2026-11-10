import 'dart:async';

import 'package:flutter/material.dart';

import '../../contracts/result.dart';
import '../errors/failure_messages.dart';

/// A screen's read, with Retry and pull to refresh (RS FR-MAG-007).
///
/// - [result] is null while the first read runs.
/// - [retry] clears the screen and reads again.
/// - [refresh] reads again and keeps what is shown until the new result
///   arrives. A refresh that fails keeps what was shown and reports the
///   failure in a short message, unless [replaceOnFailure] says the
///   failure changes what the screen shows (an unpublished issue,
///   FR-MAG-008).
mixin Reloadable<W extends StatefulWidget, T> on State<W> {
  /// The latest result, or null while the first read runs.
  Result<T>? result;

  /// Reads the screen's content.
  Future<Result<T>> fetch();

  /// Whether a refresh that fails with [failure] replaces what is shown.
  bool replaceOnFailure(AppFailure failure) => false;

  @override
  void initState() {
    super.initState();
    unawaited(_run(keep: false));
  }

  /// Clears the screen and reads again.
  Future<void> retry() {
    setState(() {
      result = null;
    });
    return _run(keep: false);
  }

  /// Reads again, keeping what is shown on a failure.
  Future<void> refresh() => _run(keep: true);

  Future<void> _run({required bool keep}) async {
    final Result<T> next = await fetch();
    if (!mounted) {
      return;
    }
    if (keep &&
        result is Ok<T> &&
        next is Err<T> &&
        !replaceOnFailure(next.failure)) {
      ScaffoldMessenger.maybeOf(context)
          ?.showSnackBar(SnackBar(content: Text(messageFor(next.failure))));
      return;
    }
    setState(() {
      result = next;
    });
  }
}

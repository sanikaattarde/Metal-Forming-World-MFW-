import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mfw_app/contracts/contracts.dart';

import 'library_text.dart';

/// The favourite star on an issue (RS FR-BKM-003): filled when the issue
/// is a favourite, and a tap marks or unmarks it at once. Shown to a reader
/// with full access only, YG's answer to OQ-12 of 10 November 2026
/// (PROVISIONAL until MFW answers).
class FavouriteButton extends StatefulWidget {
  /// Creates the star for [issueId].
  const FavouriteButton({
    required this.library,
    required this.issueId,
    super.key,
  });

  /// MOD-08.
  final LibraryRepository library;

  /// The issue.
  final String issueId;

  @override
  State<FavouriteButton> createState() => _FavouriteButtonState();
}

class _FavouriteButtonState extends State<FavouriteButton> {
  late final StreamSubscription<Set<String>> _favourites;
  bool _favourite = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    // A failed watch, as at sign-out, keeps the last state shown.
    _favourites = widget.library.watchFavouriteIssueIds().listen((
      Set<String> ids,
    ) {
      setState(() {
        _favourite = ids.contains(widget.issueId);
      });
    }, onError: (Object _) {});
  }

  @override
  void dispose() {
    unawaited(_favourites.cancel());
    super.dispose();
  }

  Future<void> _toggle() async {
    final bool next = !_favourite;
    setState(() {
      _busy = true;
      // Shown at once (FR-BKM-003); the stream confirms or puts it back.
      _favourite = next;
    });
    final Result<void> result = await widget.library.setFavourite(
      widget.issueId,
      next,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _busy = false;
      if (result is Err<void>) {
        _favourite = !next;
      }
    });
    if (result case Err<void>(:final AppFailure failure)) {
      ScaffoldMessenger.maybeOf(context)
          ?.showSnackBar(SnackBar(content: Text(LibraryText.failure(failure))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: _favourite
          ? LibraryText.removeFavourite
          : LibraryText.addFavourite,
      isSelected: _favourite,
      icon: const Icon(Icons.star_border),
      selectedIcon: const Icon(Icons.star),
      onPressed: _busy ? null : () => unawaited(_toggle()),
    );
  }
}

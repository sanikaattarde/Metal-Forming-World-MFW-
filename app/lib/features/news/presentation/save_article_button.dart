import 'dart:async';

import 'package:flutter/material.dart';

import '../../../contracts/news.dart';
import '../domain/news_cache.dart';
import 'news_text.dart';

/// Save on SCR-A-19 (MOD09-P2-T02, RS FR-NEWS-006): keeps the article on
/// the device until the reader removes it. Open to visitors, because the
/// article is public and stays on this device.
class SaveArticleButton extends StatefulWidget {
  /// Creates the button for [post].
  const SaveArticleButton({required this.saved, required this.post, super.key});

  /// The saved articles.
  final SavedArticles saved;

  /// The article shown.
  final NewsPost post;

  @override
  State<SaveArticleButton> createState() => _SaveArticleButtonState();
}

class _SaveArticleButtonState extends State<SaveArticleButton> {
  bool? _saved;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    unawaited(_read());
  }

  Future<void> _read() async {
    final bool saved = await widget.saved
        .isSaved(widget.post.postId)
        .catchError((Object _) => false);
    if (mounted) {
      setState(() {
        _saved = saved;
      });
    }
  }

  Future<void> _toggle() async {
    final bool wasSaved = _saved ?? false;
    setState(() {
      _busy = true;
    });
    String message;
    try {
      if (wasSaved) {
        await widget.saved.remove(widget.post.postId);
        message = NewsText.removed;
      } else {
        await widget.saved.save(widget.post);
        message = NewsText.saved;
      }
      _saved = !wasSaved;
    } on Object {
      message = NewsText.saveFailed;
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _busy = false;
    });
    ScaffoldMessenger.maybeOf(context)
        ?.showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final bool? saved = _saved;
    return IconButton(
      tooltip: saved == true ? NewsText.unsave : NewsText.save,
      isSelected: saved == true,
      icon: const Icon(Icons.bookmark_add_outlined),
      selectedIcon: const Icon(Icons.bookmark_added),
      onPressed: saved == null || _busy ? null : () => unawaited(_toggle()),
    );
  }
}

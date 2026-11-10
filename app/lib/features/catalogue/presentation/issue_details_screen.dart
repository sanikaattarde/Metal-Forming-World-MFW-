import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mfw_app/contracts/contracts.dart';

import '../../../app/theme/mfw_tokens.dart';
import '../../../core/ui/content_widgets.dart';
import 'catalogue_text.dart';
import 'issue_row.dart';

/// What SCR-A-12 can ask the shell to do. Navigation stays in the shell
/// (DEC-013), so the screen only calls these.
final class IssueDetailsActions {
  /// Creates the set.
  const IssueDetailsActions({
    required this.onRead,
    required this.onSignIn,
    required this.onRegister,
    required this.onContinueSignUp,
    this.onDownload,
    this.onBack,
  });

  /// Opens the reader (SCR-A-14) for the issue.
  final ValueChanged<IssueSummary> onRead;

  /// Opens the download sheet (SCR-A-13), when downloads are available.
  final ValueChanged<IssueSummary>? onDownload;

  /// Goes to sign in (SCR-A-01).
  final VoidCallback onSignIn;

  /// Goes to registration (SCR-A-02).
  final VoidCallback onRegister;

  /// Goes to the step the reader is missing: verification (SCR-A-03) or
  /// the profile (SCR-A-05).
  final VoidCallback onContinueSignUp;

  /// Goes back.
  final VoidCallback? onBack;
}

/// Issue details (SCR-A-12): the cover, title, category, date, size and
/// description of a published issue, with Read and Download for a reader
/// with full access (RS FR-MAG-005). Others see what is missing and how to
/// get it (FR-AUTH-010, FR-PROF-004). The access check here is for the
/// reader's experience only; the backend checks every file request
/// (DEC-009).
class IssueDetailsScreen extends StatefulWidget {
  /// Creates the screen.
  const IssueDetailsScreen({
    required this.issueId,
    required this.catalogue,
    required this.accessState,
    required this.actions,
    this.appBarActions,
    super.key,
  });

  /// The issue shown.
  final String issueId;

  /// MOD-05's catalogue.
  final CatalogueRepository catalogue;

  /// The current access state.
  final ValueListenable<AccessState> accessState;

  /// The shell's actions.
  final IssueDetailsActions actions;

  /// Extra actions in the bar for a loaded issue, such as favourite and
  /// share (MOD-08, MOD-10).
  final List<Widget> Function(IssueSummary issue, AccessState state)?
  appBarActions;

  @override
  State<IssueDetailsScreen> createState() => _IssueDetailsScreenState();
}

class _IssueDetailsScreenState extends State<IssueDetailsScreen> {
  late Future<Result<IssueContent>> _content = _load();

  Future<Result<IssueContent>> _load() =>
      loadIssue(widget.catalogue, widget.issueId);

  void _reload() {
    setState(() {
      _content = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Result<IssueContent>>(
      future: _content,
      builder:
          (BuildContext context, AsyncSnapshot<Result<IssueContent>> snapshot) {
            final Result<IssueContent>? result = snapshot.data;
            final IssueContent? content = switch (result) {
              Ok<IssueContent>(:final IssueContent value) => value,
              _ => null,
            };
            return ValueListenableBuilder<AccessState>(
              valueListenable: widget.accessState,
              builder: (BuildContext context, AccessState state, Widget? _) =>
                  Scaffold(
                    appBar: AppBar(
                      automaticallyImplyLeading: false,
                      leading: widget.actions.onBack == null
                          ? null
                          : IconButton(
                              tooltip: CatalogueText.back,
                              icon: const Icon(Icons.arrow_back),
                              onPressed: widget.actions.onBack,
                            ),
                      title: Text(content?.issue.title ?? ''),
                      actions: content == null
                          ? null
                          : widget.appBarActions?.call(content.issue, state),
                    ),
                    body: switch (result) {
                      null => const LoadingContent(
                        label: CatalogueText.loadingIssue,
                      ),
                      Err<IssueContent>(:final AppFailure failure) => _Failure(
                        failure: failure,
                        onRetry: _reload,
                      ),
                      Ok<IssueContent>(:final IssueContent value) => _Details(
                        content: value,
                        state: state,
                        actions: widget.actions,
                      ),
                    },
                  ),
            );
          },
    );
  }
}

class _Failure extends StatelessWidget {
  const _Failure({required this.failure, required this.onRetry});

  final AppFailure failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(MfwSpace.lg),
      children: <Widget>[
        ContentNotice(
          CatalogueText.failure(failure),
          kind: failure.code == FailureCode.network
              ? NoticeKind.offline
              : NoticeKind.error,
          action: failure.retryable
              ? TextButton(
                  onPressed: onRetry,
                  child: const Text(CatalogueText.retry),
                )
              : null,
        ),
      ],
    );
  }
}

class _Details extends StatelessWidget {
  const _Details({
    required this.content,
    required this.state,
    required this.actions,
  });

  final IssueContent content;
  final AccessState state;
  final IssueDetailsActions actions;

  @override
  Widget build(BuildContext context) {
    final IssueSummary issue = content.issue;
    return ListView(
      padding: const EdgeInsets.all(MfwSpace.lg),
      children: <Widget>[
        Center(
          child: CoverImage(
            url: issue.coverImageUrl,
            semanticLabel: CatalogueText.coverOf(issue.title),
            width: 180,
            showLabel: true,
          ),
        ),
        const SizedBox(height: MfwSpace.lg),
        Semantics(header: true, child: Text(issue.title, style: MfwType.h2)),
        const SizedBox(height: MfwSpace.xs),
        Text(
          CatalogueText.detailMeta(
            content.categoryName,
            issue.publicationDate,
            issue.fileSizeBytes,
          ),
          style: MfwType.small,
        ),
        if (issue.description.isNotEmpty) ...<Widget>[
          const SizedBox(height: MfwSpace.lg),
          Text(issue.description, style: MfwType.body),
        ],
        const SizedBox(height: MfwSpace.xl),
        ..._actionsFor(issue),
      ],
    );
  }

  List<Widget> _actionsFor(IssueSummary issue) => switch (state) {
    AccessState.fullAccess => <Widget>[
      FilledButton(
        onPressed: () => actions.onRead(issue),
        child: const Text(CatalogueText.read),
      ),
      if (actions.onDownload
          case final ValueChanged<IssueSummary> download) ...<Widget>[
        const SizedBox(height: MfwSpace.sm),
        OutlinedButton(
          onPressed: () => download(issue),
          child: const Text(CatalogueText.download),
        ),
      ],
    ],
    AccessState.signedOut => <Widget>[
      const ContentNotice(CatalogueText.visitorNotice, kind: NoticeKind.info),
      FilledButton(
        onPressed: actions.onSignIn,
        child: const Text(CatalogueText.signIn),
      ),
      const SizedBox(height: MfwSpace.sm),
      OutlinedButton(
        onPressed: actions.onRegister,
        child: const Text(CatalogueText.register),
      ),
    ],
    AccessState.emailUnverified => <Widget>[
      const ContentNotice(CatalogueText.verifyNotice, kind: NoticeKind.info),
      FilledButton(
        onPressed: actions.onContinueSignUp,
        child: const Text(CatalogueText.verifyAction),
      ),
    ],
    AccessState.profileIncomplete => <Widget>[
      const ContentNotice(CatalogueText.profileNotice, kind: NoticeKind.info),
      FilledButton(
        onPressed: actions.onContinueSignUp,
        child: const Text(CatalogueText.profileAction),
      ),
    ],
  };
}

/// A published issue with its category's name.
typedef IssueContent = ({IssueSummary issue, String categoryName});

/// Reads [issueId] and the categories from [catalogue] at once. A failed
/// category read still shows the issue, with its category identifier.
Future<Result<IssueContent>> loadIssue(
  CatalogueRepository catalogue,
  String issueId,
) async {
  final (Result<IssueSummary> issue, Result<List<IssueCategory>> categories) =
      await (catalogue.getIssue(issueId), catalogue.listCategories()).wait;
  final List<IssueCategory> names = switch (categories) {
    Ok<List<IssueCategory>>(:final List<IssueCategory> value) => value,
    Err<List<IssueCategory>>() => const <IssueCategory>[],
  };
  return switch (issue) {
    Err<IssueSummary>(:final AppFailure failure) => Err<IssueContent>(failure),
    Ok<IssueSummary>(:final IssueSummary value) => Ok<IssueContent>((
      issue: value,
      categoryName: categoryNameOf(value.categoryId, names),
    )),
  };
}

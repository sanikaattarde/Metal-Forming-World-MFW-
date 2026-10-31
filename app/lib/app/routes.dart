/// Route of SCR-A-12 for [issueId].
String issueRoute(String issueId) => '/issues/${Uri.encodeComponent(issueId)}';

/// Route of SCR-A-14 for [issueId], at its first page.
String readerRoute(String issueId) => '${issueRoute(issueId)}/read';

/// Route of SCR-A-19 for [postId].
String newsPostRoute(String postId) => '/news/${Uri.encodeComponent(postId)}';

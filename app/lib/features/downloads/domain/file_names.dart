/// The stored file name for [issueId] at [revision] (CODING_STANDARDS
/// section 8.2, item 3).
///
/// Derived from the opaque issue ID only, never from a title, and carrying
/// no personal data. The ID is percent-encoded, so no ID can name a folder
/// or reach outside the downloads folder. [copy] above 1 tells apart a
/// second reader's copy of the same issue on one device (RD-05, PROPOSED).
String issueFileName(String issueId, int revision, {int copy = 1}) {
  final String base = 'issue-${Uri.encodeComponent(issueId)}-r$revision';
  return copy == 1 ? '$base.pdf' : '$base-c$copy.pdf';
}

/// The name of the partial file that becomes [fileName].
String partialFileName(String fileName) => '$fileName.part';

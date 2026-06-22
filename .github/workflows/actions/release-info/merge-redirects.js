// Merge regenerated download redirect lines with the manually-maintained lines
// already present in a _redirects file. The action regenerates only the
// download namespaces (e.g. /download/latest/, /download/prerelease/); every
// other line (manual redirects, comments, blanks) is preserved.
function mergeRedirects(existingContent, downloadLines, managedPrefixes) {
  const downloadBlock = downloadLines.join("\n");

  const existingLines = existingContent ? existingContent.split("\n") : [];
  const preserved = existingLines.filter((line) => {
    const token = line.trimStart().split(/\s+/)[0];
    return !managedPrefixes.some((prefix) => token.startsWith(prefix));
  });

  // Drop blank lines at the edges so re-runs stay stable.
  while (preserved.length && preserved[0].trim() === "") preserved.shift();
  while (preserved.length && preserved[preserved.length - 1].trim() === "") {
    preserved.pop();
  }

  if (preserved.length === 0) {
    return downloadBlock;
  }
  return downloadBlock + "\n\n" + preserved.join("\n");
}

module.exports = { mergeRedirects };

// Reject a release version that is older than the one already committed.
//
// The GitHub Releases API has served inconsistent paginated results, handing
// back a valid-looking but months-old release in response to a request for the
// newest page. Such a payload is indistinguishable from a good one by
// inspection: the release exists, is flagged prerelease, and still has assets.
// The version already committed to this repo is the only trustworthy reference
// point, so a resolved version may never move backwards.

// Parse "1.11.1" or "v1.11.1" into [1, 11, 1]. Returns undefined for anything
// that is not exactly three numeric segments.
function parseVersion(version) {
  if (typeof version !== "string") {
    return undefined;
  }
  const parts = version.trim().replace(/^v/, "").split(".");
  if (parts.length !== 3) {
    return undefined;
  }
  const numbers = parts.map((part) =>
    /^\d+$/.test(part) ? Number(part) : NaN
  );
  return numbers.some(Number.isNaN) ? undefined : numbers;
}

function assertNotOlder(candidate, previous, label) {
  const committed = parseVersion(previous);
  if (!committed) {
    throw new Error(
      `${label}: committed version "${previous}" is not a valid X.Y.Z version.`
    );
  }
  const resolved = parseVersion(candidate);
  if (!resolved) {
    throw new Error(
      `${label}: resolved version "${candidate}" is not a valid X.Y.Z version.`
    );
  }

  // Compare segment by segment. String comparison is wrong here - "1.10.2"
  // sorts above "1.10.10", and "1.9.10" sorts above "1.11.1".
  for (let i = 0; i < resolved.length; i++) {
    if (resolved[i] !== committed[i]) {
      if (resolved[i] < committed[i]) {
        throw new Error(
          `${label}: resolved version ${candidate} is older than the ` +
            `committed version ${previous}. Refusing to regenerate download ` +
            `data from a stale release.`
        );
      }
      break;
    }
  }
  console.log(`${label}: accepted ${candidate} (committed: ${previous})`);
}

module.exports = { assertNotOlder };

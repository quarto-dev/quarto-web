const assert = require("assert");
const { assertNotOlder } = require("./version-guard");

// 1. The four values the API served on 2026-08-17, against the version
// committed at the time. Every one must be rejected.
for (const bad of ["1.2.113", "0.2.434", "1.9.10", "1.5.49"]) {
  assert.throws(
    () => assertNotOlder(bad, "1.11.1", "Latest prerelease"),
    /older than the committed version/,
    `rejects stale ${bad}`
  );
}

// 2. Ordering is numeric, not lexicographic. Both of these invert under
// string comparison, which is the trap this module exists to avoid.
assert.throws(
  () => assertNotOlder("1.9.10", "1.11.1", "Latest prerelease"),
  /older than the committed version/,
  "minor 9 is older than 11"
);
assert.throws(
  () => assertNotOlder("1.10.2", "1.10.10", "Latest prerelease"),
  /older than the committed version/,
  "patch 2 is older than 10"
);

// 3. Equal and newer are accepted. Equal is the common case: the cron job
// runs every 15 minutes and usually resolves the same version.
assert.doesNotThrow(
  () => assertNotOlder("1.11.1", "1.11.1", "Latest prerelease"),
  "equal accepted"
);
assert.doesNotThrow(
  () => assertNotOlder("1.12.0", "1.11.1", "Latest prerelease"),
  "newer accepted"
);

// 4. Callers pass a raw tag_name, so a leading v must compare correctly.
assert.doesNotThrow(
  () => assertNotOlder("v1.11.2", "1.11.1", "Latest prerelease"),
  "leading v on candidate"
);
assert.throws(
  () => assertNotOlder("v1.9.10", "1.11.1", "Latest prerelease"),
  /older than the committed version/,
  "leading v on a stale candidate"
);

// 5. Unusable input fails loudly rather than silently skipping the check.
assert.throws(
  () => assertNotOlder("1.12.0-rc1", "1.11.1", "Latest prerelease"),
  /resolved version "1\.12\.0-rc1" is not a valid X\.Y\.Z version/,
  "unparseable candidate"
);
assert.throws(
  () => assertNotOlder("1.12.0", undefined, "Latest prerelease"),
  /committed version "undefined" is not a valid X\.Y\.Z version/,
  "missing baseline"
);

// 6. The rejection message names both versions and the channel, so the failed
// run is diagnosable from the log alone.
assert.throws(
  () => assertNotOlder("v1.9.10", "1.11.1", "Latest prerelease"),
  (error) =>
    error.message.includes("Latest prerelease") &&
    error.message.includes("1.9.10") &&
    error.message.includes("1.11.1"),
  "message identifies channel and both versions"
);

console.log("All version-guard tests passed");

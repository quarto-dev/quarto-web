#!/usr/bin/env bash
set -uo pipefail
# Print public facts about a submitter's GitHub account. Facts only: the caller judges.
# Usage: submitter-footprint.sh <login> [pr-created-at]
# pr-created-at is an ISO 8601 UTC timestamp (default: now); ages and the recent-repo window count back from it.
# Output: key=value lines, then one tab-separated `repo` line per repo created in the 14 days before that time.
# Only the 100 most recently created repos are inspected; an UNVERIFIED line says when they end inside the window.
# Always exits 0 — caller interprets output.

LOGIN="${1:?Usage: submitter-footprint.sh <login> [pr-created-at]}"
AT="${2:-$(date -u +%Y-%m-%dT%H:%M:%SZ)}"

if ! USER_JSON=$(gh api "users/$LOGIN" 2>&1); then
  echo "UNVERIFIED: could not fetch account '$LOGIN' (${USER_JSON:-unknown error}); submitter footprint not checked"
  exit 0
fi

printf '%s' "$USER_JSON" | jq -r --arg at "$AT" '
  "account_type=\(.type)",
  "account_created=\(.created_at)",
  "account_age_days_at_pr=\(((($at | fromdateiso8601) - (.created_at | fromdateiso8601)) / 86400 | floor))",
  "public_repos=\(.public_repos)",
  "followers=\(.followers)"' | tr -d '\r'

if ! REPOS_JSON=$(gh api "users/$LOGIN/repos?sort=created&direction=desc&per_page=100" 2>&1); then
  echo "UNVERIFIED: could not list repos (${REPOS_JSON:-unknown error}); recent repo burst not checked"
  exit 0
fi

printf '%s' "$REPOS_JSON" | jq -r --arg at "$AT" '
  ($at | fromdateiso8601) as $t
  | (if length == 100 and (.[-1].created_at | fromdateiso8601) > $t - 1209600
     then "UNVERIFIED: the 100 newest repos do not reach back to the start of the 14-day window; recent_repos_created may be incomplete"
     else empty end),
    ([.[] | select((.created_at | fromdateiso8601) > $t - 1209600 and (.created_at | fromdateiso8601) <= $t)]
  | "recent_repos_created=\(length)",
    (.[] | "repo\t\(.name)\t\(.language // "-")\t\(.created_at)\tfork=\(.fork)"))' | tr -d '\r'

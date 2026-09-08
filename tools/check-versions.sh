#!/bin/bash
# ===========================================================================
# Script:      check-versions.sh
# Version:     1.0.0
# Author:      Ladislav Osvald
# Updated:     2026-07-26
#
# Description:
#   Verifies, for every script in this repo, that the four hand-maintained
#   version facts agree:
#
#       header Version:  ==  newest CHANGELOG entry version
#       header Updated:  ==  newest CHANGELOG entry date
#
#   Unlike extendscript-automation there is no build here, so nothing generates
#   these fields — they drift silently unless something looks. This is that
#   something. Both the version and the DATE are checked, because in this repo
#   `Updated:` means "date of the version" and changes only at release
#   (in ES the same field is generated from the last src commit, so its date is
#   deliberately not checked there — see docs/conventions.md in both repos).
#
#   Run it as part of the release ritual, not on every commit: these values
#   change when you release, so checking each commit would be noise.
#
# Usage: bash tools/check-versions.sh
# ===========================================================================

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

fail=0
checked=0

for script in */*.applescript; do
    dir="$(dirname "$script")"
    changelog="$dir/CHANGELOG.md"
    name="$(basename "$dir")"

    # templates/ holds skeletons with placeholder values, not a released script.
    [ "$name" = "templates" ] && continue

    if [ ! -f "$changelog" ]; then
        echo "  SKIP $name — no CHANGELOG.md"
        continue
    fi

    hdr_version="$(sed -n 's/^-- Version:[[:space:]]*\([0-9][0-9.]*\).*/\1/p' "$script" | head -1)"
    hdr_updated="$(sed -n 's/^-- Updated:[[:space:]]*\([0-9-]*\).*/\1/p' "$script" | head -1)"
    cl_version="$(sed -n 's/^## \[\([0-9][^]]*\)\].*/\1/p' "$changelog" | head -1)"
    cl_date="$(sed -n 's/^## \[[0-9][^]]*\][^0-9]*\([0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}\).*/\1/p' "$changelog" | head -1)"

    checked=$((checked + 1))
    problems=""

    [ -z "$hdr_version" ] && problems="$problems\n      header has no 'Version:' field"
    [ -z "$cl_version" ]  && problems="$problems\n      CHANGELOG has no '## [x.y.z]' entry"

    if [ -n "$hdr_version" ] && [ -n "$cl_version" ] && [ "$hdr_version" != "$cl_version" ]; then
        problems="$problems\n      version: header=$hdr_version but CHANGELOG=$cl_version"
    fi
    if [ -n "$hdr_updated" ] && [ -n "$cl_date" ] && [ "$hdr_updated" != "$cl_date" ]; then
        problems="$problems\n      date:    header Updated=$hdr_updated but CHANGELOG=$cl_date"
    fi

    if [ -n "$problems" ]; then
        echo "  FAIL $name"
        printf "%b\n" "$problems"
        fail=$((fail + 1))
    else
        echo "  OK   $name — $hdr_version ($hdr_updated)"
    fi
done

echo ""
if [ "$fail" -gt 0 ]; then
    echo "$fail of $checked script(s) have version drift." >&2
    echo "Fix: the header's Version:/Updated: must match the newest CHANGELOG entry." >&2
    exit 1
fi

echo "All $checked script(s) consistent: header version/date == newest CHANGELOG entry."

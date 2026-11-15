#!/bin/sh
# Prints the changelog entry of one version, without its heading.
#
# Usage: Scripts/release-notes.sh 1.7.0       (the "### v1.7.0 (date)" section)
#        Scripts/release-notes.sh Unreleased  (the "### Unreleased" section)
#
# It reads CHANGELOG.md in the current directory and fails if the section is missing or empty,
# so a release can never go out with blank notes.
set -eu

if [ "$#" -ne 1 ]; then
    echo "usage: $0 <version|Unreleased>" >&2
    exit 64
fi

# A version may be written with or without the leading "v".
wanted="${1#v}"

notes=$(awk -v wanted="$wanted" '
    /^### / {
        if (found) { exit }
        heading = $0
        sub(/^### v?/, "", heading)
        sub(/ .*$/, "", heading)
        if (heading == wanted) { found = 1 }
        next
    }
    found { print }
' CHANGELOG.md)

# Drop blank lines at the start and the end.
notes=$(printf '%s\n' "$notes" | awk 'NF { started = 1 } started { lines[++count] = $0 } END { while (count > 0 && lines[count] !~ /[^[:space:]]/) { count-- } for (i = 1; i <= count; i++) { print lines[i] } }')

if [ -z "$notes" ]; then
    echo "error: CHANGELOG.md has no entry for $1, or the entry is empty" >&2
    exit 1
fi

printf '%s\n' "$notes"

#!/bin/sh
# Prepares the files for a release. It does not run git, so you can review the result first.
#
# Usage: Scripts/prepare-release.sh 1.7.0
#
# It turns the "### Unreleased" changelog section into "### v1.7.0 (today)", adds a new empty
# "### Unreleased" section above it, and sets the version in Configuration.xcconfig.
# Run it from the repository root.
set -eu

if [ "$#" -ne 1 ]; then
    echo "usage: $0 <major.minor.patch>" >&2
    exit 64
fi

version="$1"
case "$version" in
    [0-9]*.[0-9]*.[0-9]*) ;;
    *) echo "error: the version must look like 1.7.0" >&2; exit 64 ;;
esac
# Only digits and dots, with exactly three parts.
if ! printf '%s\n' "$version" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+$'; then
    echo "error: the version must look like 1.7.0" >&2
    exit 64
fi

current=$(awk -F' = ' '/^MARKETING_VERSION/ { print $2 }' Configuration.xcconfig)
if [ -z "$current" ]; then
    echo "error: no MARKETING_VERSION in Configuration.xcconfig" >&2
    exit 1
fi
newest=$(printf '%s\n%s\n' "$current" "$version" | sort -t. -k1,1n -k2,2n -k3,3n | tail -1)
if [ "$version" = "$current" ] || [ "$newest" != "$version" ]; then
    echo "error: $version is not newer than the current version $current" >&2
    exit 1
fi

if grep -Eq "^### v?$(printf '%s' "$version" | sed 's/\./\\./g')( |\$)" CHANGELOG.md; then
    echo "error: CHANGELOG.md already has an entry for $version" >&2
    exit 1
fi

# Fails when there is nothing to release.
"$(dirname "$0")/release-notes.sh" Unreleased > /dev/null

date="${RELEASE_DATE:-$(date +%Y-%m-%d)}"

# The build number is the version with two digits per part: 1.6.9 becomes 1060900.
major=${version%%.*}
rest=${version#*.}
minor=${rest%%.*}
patch=${rest#*.}
build=$((major * 1000000 + minor * 10000 + patch * 100))

awk -v version="$version" -v date="$date" '
    /^### Unreleased$/ && !done { print; print ""; print "### v" version " (" date ")"; done = 1; next }
    { print }
' CHANGELOG.md > CHANGELOG.md.new
mv CHANGELOG.md.new CHANGELOG.md

awk -v version="$version" -v build="$build" '
    /^MARKETING_VERSION = / { print "MARKETING_VERSION = " version; next }
    /^CURRENT_PROJECT_VERSION = / { print "CURRENT_PROJECT_VERSION = " build; next }
    { print }
' Configuration.xcconfig > Configuration.xcconfig.new
mv Configuration.xcconfig.new Configuration.xcconfig

echo "Prepared version $version (build $build)."
echo "Next: review the changes, commit them, then run: git tag v$version && git push origin v$version"

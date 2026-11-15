#!/bin/sh
# Tests release-notes.sh and prepare-release.sh on sample files in a temporary directory.
# Usage: Scripts/test-release-scripts.sh
set -u

scripts=$(cd "$(dirname "$0")" && pwd)
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
passed=0
failed=0

check() { # check <description> <expected> <actual>
    if [ "$2" = "$3" ]; then
        passed=$((passed + 1))
    else
        failed=$((failed + 1))
        printf 'FAIL: %s\n  expected: %s\n  actual:   %s\n' "$1" "$2" "$3"
    fi
}

# Runs a command and returns only its exit status.
status() { "$@" > /dev/null 2>&1; echo $?; }

fresh() { # a new sample project in $work/project
    rm -rf "$work/project"
    mkdir "$work/project"
    cd "$work/project" || exit 1
    cat > CHANGELOG.md <<'SAMPLE'
# Sample

## Changelog

Intro text.

### Unreleased

- added a new thing
- fixed another thing
	- with a nested detail

### v1.6.9 (2026-01-01)

- the previous release

### v1.6.90 (2025-12-01)

- an older release with a similar number

### v1.5.0

- the oldest release
SAMPLE
    cat > Configuration.xcconfig <<'SAMPLE'
MACOSX_DEPLOYMENT_TARGET = 12.0
MARKETING_VERSION = 1.6.9
CURRENT_PROJECT_VERSION = 1060900
OTHER_SETTING = keep me
SAMPLE
}

fresh

# ---- release-notes.sh
check "a version section is printed without its heading" "- the previous release" "$("$scripts/release-notes.sh" 1.6.9)"
check "a leading v is accepted" "- the previous release" "$("$scripts/release-notes.sh" v1.6.9)"
check "a similar version number is not matched" "- an older release with a similar number" "$("$scripts/release-notes.sh" 1.6.90)"
check "a heading without a date is found" "- the oldest release" "$("$scripts/release-notes.sh" 1.5.0)"
check "the Unreleased section keeps nested lines and stops at the next heading" "- added a new thing
- fixed another thing
	- with a nested detail" "$("$scripts/release-notes.sh" Unreleased)"
check "a missing version fails" "1" "$(status "$scripts/release-notes.sh" 9.9.9)"
check "a partial version does not match" "1" "$(status "$scripts/release-notes.sh" 1.6)"
check "no argument fails with a usage error" "64" "$(status "$scripts/release-notes.sh")"
check "two arguments fail with a usage error" "64" "$(status "$scripts/release-notes.sh" 1.6.9 extra)"
printf '### v2.0.0 (2026-02-02)\n\n\n### v1.0.0\n- x\n' > CHANGELOG.md
check "an empty section fails" "1" "$(status "$scripts/release-notes.sh" 2.0.0)"
fresh

# ---- prepare-release.sh
RELEASE_DATE=2026-03-04 "$scripts/prepare-release.sh" 1.7.0 > /dev/null
check "the changelog gets a new empty Unreleased and a dated version section" "### Unreleased

### v1.7.0 (2026-03-04)

- added a new thing" "$(sed -n '/^### Unreleased/,/^- added a new thing/p' CHANGELOG.md)"
check "the new version section holds the old Unreleased notes" "- added a new thing
- fixed another thing
	- with a nested detail" "$("$scripts/release-notes.sh" 1.7.0)"
check "older sections are untouched" "- the previous release" "$("$scripts/release-notes.sh" 1.6.9)"
check "Unreleased is empty after a release, so another release fails" "1" "$(status "$scripts/release-notes.sh" Unreleased)"
check "the marketing version is updated" "MARKETING_VERSION = 1.7.0" "$(grep '^MARKETING_VERSION' Configuration.xcconfig)"
check "the build number has two digits per part" "CURRENT_PROJECT_VERSION = 1070000" "$(grep '^CURRENT_PROJECT_VERSION' Configuration.xcconfig)"
check "other settings stay" "OTHER_SETTING = keep me" "$(grep '^OTHER_SETTING' Configuration.xcconfig)"
check "only one Unreleased heading exists" "1" "$(grep -c '^### Unreleased' CHANGELOG.md)"

fresh
RELEASE_DATE=2026-03-04 "$scripts/prepare-release.sh" 2.10.3 > /dev/null
check "the build number of 2.10.3" "CURRENT_PROJECT_VERSION = 2100300" "$(grep '^CURRENT_PROJECT_VERSION' Configuration.xcconfig)"

# ---- refusals leave both files exactly as they were
refuse() { # refuse <description> <version>
    fresh
    before=$(cat CHANGELOG.md Configuration.xcconfig)
    code=$(status "$scripts/prepare-release.sh" "$2")
    after=$(cat CHANGELOG.md Configuration.xcconfig)
    check "$1 is refused" "1" "$([ "$code" != 0 ] && echo 1 || echo 0)"
    check "$1 changes no file" "$before" "$after"
}
refuse "the current version" 1.6.9
refuse "an older version" 1.6.8
refuse "an older version with a bigger last part" 1.5.99
refuse "two parts" 1.7
refuse "four parts" 1.7.0.1
refuse "a leading v" v1.7.0
refuse "letters" a.b.c
refuse "a trailing command" '1.7.0; echo hacked'
refuse "an empty version" ''
refuse "a version that already has an entry" 1.6.90

fresh
printf '# Sample\n\n### Unreleased\n\n### v1.6.9 (2026-01-01)\n\n- old\n' > CHANGELOG.md
before=$(cat CHANGELOG.md Configuration.xcconfig)
check "an empty Unreleased section is refused" "1" "$([ "$(status "$scripts/prepare-release.sh" 1.7.0)" != 0 ] && echo 1 || echo 0)"
check "an empty Unreleased section changes no file" "$before" "$(cat CHANGELOG.md Configuration.xcconfig)"

check "a missing argument fails with a usage error" "64" "$(status "$scripts/prepare-release.sh")"

# ---- the real changelog works with the real script
cd "$scripts/.." || exit 1
check "the real Unreleased section has notes" "0" "$(status "$scripts/release-notes.sh" Unreleased)"

echo "passed: $passed, failed: $failed"
[ "$failed" -eq 0 ]

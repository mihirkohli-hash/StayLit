NAME = StayLit
# The version comes from the project settings, so it cannot drift from the app.
VERSION := $(shell awk -F' = ' '/^MARKETING_VERSION/ {print $$2}' Configuration.xcconfig)

SCHEME = $(NAME)
TARGET = $(NAME)
DIST_TARGET = $(NAME) (Direct)
WORKSPACE = $(NAME).xcworkspace

BUILD_DIR = build
OUTPUT_DIR = dist
LOCALIZATIONS_DIR = Localizations

XCODEBUILD = set -o pipefail && env NSUnbufferedIO=YES xcodebuild
BEAUTIFY = | xcbeautify
DISABLE_PACKAGE_RESOLUTION = -disableAutomaticPackageResolution -onlyUsePackageVersionsFromResolvedFile
SAVE_LOG = 2>&1 | tee "$(BUILD_DIR)/$(NAME).log"

LOCAL_INSTALL_DIR = /Applications
LOCAL_INSTALL_ENTITLEMENTS = StayLit/StayLit-LocalInstall.entitlements

default: clean

clean:
	$(RM) -r $(BUILD_DIR)
PHONY: clean

dist-clean:
	$(RM) -r $(OUTPUT_DIR)
PHONY: dist-clean

test:
	@mkdir -p "$(BUILD_DIR)"
	$(XCODEBUILD) test \
	-workspace "$(WORKSPACE)" \
	-scheme "$(SCHEME)" \
	-derivedDataPath "$(BUILD_DIR)" \
	$(DISABLE_PACKAGE_RESOLUTION) \
	$(SAVE_LOG) \
	$(BEAUTIFY)
PHONY: test

test-with-sanitizers:
	@mkdir -p "$(BUILD_DIR)"
	$(XCODEBUILD) test \
	-workspace "$(WORKSPACE)" \
	-scheme "$(SCHEME)" \
	-testPlan "SanitizerTestPlan" \
	-derivedDataPath "$(BUILD_DIR)" \
	$(DISABLE_PACKAGE_RESOLUTION) \
	$(SAVE_LOG) \
	$(BEAUTIFY)
PHONY: test-with-sanitizers

l10n-export:
	Localizations/l10n-export.sh
.PHONY: l10n-export

l10n-import:
	Localizations/l10n-import.sh
.PHONY: l10n-export

l10n-update:
	$(MAKE) l10n-export
	$(MAKE) l10n-import
	$(MAKE) l10n-export
.PHONY: l10n-update

$(OUTPUT_DIR)/$(NAME).xcarchive:
	$(XCODEBUILD) archive \
	-workspace "$(WORKSPACE)" \
	-scheme "$(SCHEME)" \
	-archivePath "$(OUTPUT_DIR)/$(NAME).xcarchive" \
	$(DISABLE_PACKAGE_RESOLUTION) \
	$(SAVE_LOG) \
	$(BEAUTIFY)

$(OUTPUT_DIR)/$(NAME).pkg: $(OUTPUT_DIR)/$(NAME).xcarchive
	$(XCODEBUILD) \
	-exportArchive \
	-archivePath "$(OUTPUT_DIR)/$(NAME).xcarchive" \
	-exportPath "$(OUTPUT_DIR)/" \
	-exportOptionsPlist "ExportOptions.plist" \
	$(DISABLE_PACKAGE_RESOLUTION) \
	$(SAVE_LOG) \
	$(BEAUTIFY)

$(OUTPUT_DIR)/$(NAME)-$(VERSION).zip:
	@echo "Exporting $(OUTPUT_DIR)/$(NAME)-$(VERSION).zip..."
	@ditto -c -k --sequesterRsrc --keepParent $(OUTPUT_DIR)/$(NAME).app $(OUTPUT_DIR)/$(NAME)-$(VERSION).zip

dist: $(OUTPUT_DIR)/$(NAME)-$(VERSION).zip
	@echo "Verifying code signing identity..."
	@spctl -a -vv $(OUTPUT_DIR)/$(NAME).app
PHONY: dist

# Fetches the Swift packages at the versions in Package.resolved. A machine with no package cache
# needs this before a build, because the build itself must not resolve packages.
resolve-packages:
	@mkdir -p "$(BUILD_DIR)"
	$(XCODEBUILD) -resolvePackageDependencies \
	-workspace "$(WORKSPACE)" \
	-scheme "$(SCHEME)" \
	-derivedDataPath "$(BUILD_DIR)" \
	-onlyUsePackageVersionsFromResolvedFile \
	-quiet
.PHONY: resolve-packages

# Runs the unit tests the way CI does. The full log goes to a file, and only failures and the summary
# are printed. The result bundle lets CI keep the details of a failed run.
test-ci: resolve-packages
	$(RM) -r "$(BUILD_DIR)/TestResults.xcresult"
	$(XCODEBUILD) test \
	-workspace "$(WORKSPACE)" \
	-scheme "$(SCHEME)" \
	-destination 'platform=macOS' \
	-derivedDataPath "$(BUILD_DIR)" \
	-resultBundlePath "$(BUILD_DIR)/TestResults.xcresult" \
	CODE_SIGNING_ALLOWED=NO \
	$(DISABLE_PACKAGE_RESOLUTION) \
	2>&1 | tee "$(BUILD_DIR)/test.log" | awk '/: error: |\*\* TEST|Executed [0-9]+ tests|Test Case .* (failed|skipped)/'
.PHONY: test-ci

LOCAL_APP = $(BUILD_DIR)/Build/Products/Release/$(NAME).app
DMG = $(OUTPUT_DIR)/$(NAME)-$(VERSION).dmg

# Builds the Direct app and signs it ad hoc for use outside the App Store. An ad-hoc signed Release
# build has no Team ID, and macOS then refuses to load the embedded Sparkle framework, which has its own.
# The local entitlements turn off library validation to allow that. This is not a release signature.
build-local-app: resolve-packages
	$(XCODEBUILD) build \
	-quiet \
	-workspace "$(WORKSPACE)" \
	-scheme "$(DIST_TARGET)" \
	-configuration Release \
	-destination 'platform=macOS' \
	-derivedDataPath "$(BUILD_DIR)" \
	CODE_SIGN_IDENTITY=- CODE_SIGN_STYLE=Manual DEVELOPMENT_TEAM= CODE_SIGNING_REQUIRED=YES \
	$(DISABLE_PACKAGE_RESOLUTION) \
	$(SAVE_LOG)
	codesign --force --sign - --options runtime --entitlements "$(LOCAL_INSTALL_ENTITLEMENTS)" "$(LOCAL_APP)"
	codesign --verify --deep --strict "$(LOCAL_APP)"
.PHONY: build-local-app

# Installs the ad-hoc signed app for this Mac only and starts it. Never ship a build signed this way.
install-local: build-local-app
	-pkill -x "$(NAME)"
	$(RM) -r "$(LOCAL_INSTALL_DIR)/$(NAME).app"
	ditto "$(LOCAL_APP)" "$(LOCAL_INSTALL_DIR)/$(NAME).app"
	codesign --verify --deep --strict "$(LOCAL_INSTALL_DIR)/$(NAME).app"
	open "$(LOCAL_INSTALL_DIR)/$(NAME).app"
.PHONY: install-local

# Packs the ad-hoc signed app into a disk image with a shortcut to the Applications folder.
# LICENSE and NOTICE go in too, because the license terms require them to ship with every copy.
# The image is not notarized, so macOS asks for confirmation the first time it opens the app.
dmg: build-local-app
	$(RM) -r "$(OUTPUT_DIR)/dmg-root" "$(DMG)"
	mkdir -p "$(OUTPUT_DIR)/dmg-root"
	ditto "$(LOCAL_APP)" "$(OUTPUT_DIR)/dmg-root/$(NAME).app"
	ln -s /Applications "$(OUTPUT_DIR)/dmg-root/Applications"
	cp LICENSE NOTICE "$(OUTPUT_DIR)/dmg-root/"
	hdiutil create -volname "$(NAME)" -srcfolder "$(OUTPUT_DIR)/dmg-root" -fs HFS+ -format UDZO -ov "$(DMG)"
	hdiutil verify "$(DMG)"
	$(RM) -r "$(OUTPUT_DIR)/dmg-root"
	@echo "Built $(DMG)"
.PHONY: dmg

# Release helpers. The scripts and their tests are in the Scripts folder.
test-scripts:
	Scripts/test-release-scripts.sh
.PHONY: test-scripts

# Turns the Unreleased changelog notes into the notes of a new version and sets the version number.
# Usage: make prepare-release VERSION=1.7.0
prepare-release:
	@test "$(origin VERSION)" = "command line" || { echo "usage: make prepare-release VERSION=1.7.0"; exit 64; }
	Scripts/prepare-release.sh "$(VERSION)"
.PHONY: prepare-release


NAME = StayLit
VERSION = 1.6.6

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

# Builds the Direct app and installs it for this Mac only. An ad-hoc signed Release build has no
# Team ID, and macOS then refuses to load the embedded Sparkle framework, which has its own.
# The local entitlements turn off library validation to allow that. Never ship a build signed this way.
install-local:
	@mkdir -p "$(BUILD_DIR)"
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
	-pkill -x "$(NAME)"
	$(RM) -r "$(LOCAL_INSTALL_DIR)/$(NAME).app"
	ditto "$(BUILD_DIR)/Build/Products/Release/$(NAME).app" "$(LOCAL_INSTALL_DIR)/$(NAME).app"
	codesign --force --sign - --options runtime --entitlements "$(LOCAL_INSTALL_ENTITLEMENTS)" "$(LOCAL_INSTALL_DIR)/$(NAME).app"
	codesign --verify --deep --strict "$(LOCAL_INSTALL_DIR)/$(NAME).app"
	open "$(LOCAL_INSTALL_DIR)/$(NAME).app"
.PHONY: install-local

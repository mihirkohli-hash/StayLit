//
//  NSApplication+SLTLaunchAtLogin.h
//  SLTApplicationSupport
//
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSApplication (SLTLaunchAtLogin)

/// Launches the app at login when enabled
@property (nonatomic, getter=slt_isLaunchAtLoginEnabled) BOOL slt_launchAtLoginEnabled;

/// Migrates the application login service from `SMLoginItemSetEnabled` to
/// `SMAppService` on macOS 13.0.
- (void)slt_migrateLaunchAtLoginToAppServiceIfNeeded API_AVAILABLE(macos(13.0));

@end

NS_ASSUME_NONNULL_END

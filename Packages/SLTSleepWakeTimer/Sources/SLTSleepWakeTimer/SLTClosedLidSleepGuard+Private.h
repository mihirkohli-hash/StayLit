//
//  SLTClosedLidSleepGuard+Private.h
//  StayLit
//
//  Created by Mihir Kohli on 2026.
//

#import <SLTSleepWakeTimer/SLTClosedLidSleepGuard.h>

NS_ASSUME_NONNULL_BEGIN

@interface SLTClosedLidSleepGuard ()

/// Returns the `sudoers` rule for a user, or nil if the user name has characters
/// that could change the meaning of the rule.
+ (nullable NSString *)sudoersRuleForUserName:(NSString *)userName;

/// Starts the watchdog without turning anything on.
///
/// The watchdog waits until either process exits. Then it runs the reset
/// command, but only if the marker file still holds this session's token. A newer
/// session replaces the token, so an older watchdog cannot undo it.
/// @param resetCommand The command that turns `SleepDisabled` off
+ (nullable NSTask *)launchWatchdogForProcessIdentifier:(int)watchedProcessIdentifier
                            caffeinateProcessIdentifier:(int)caffeinateProcessIdentifier
                                             markerPath:(NSString *)markerPath
                                                  token:(NSString *)token
                                           resetCommand:(NSArray<NSString *> *)resetCommand;

/// The file that records which session turned `SleepDisabled` on.
@property (class, nonatomic, readonly) NSString *markerPath;

@end

NS_ASSUME_NONNULL_END

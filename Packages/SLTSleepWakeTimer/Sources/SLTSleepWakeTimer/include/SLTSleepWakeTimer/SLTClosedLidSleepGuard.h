//
//  SLTClosedLidSleepGuard.h
//  StayLit
//
//  Created by Mihir Kohli on 2026.
//

#import <Foundation/Foundation.h>
#import <SLTCommon/SLTExport.h>

NS_ASSUME_NONNULL_BEGIN

/// Keeps a MacBook awake with the lid closed, also on battery power.
///
/// macOS has no supported API for this. The only way is the `SleepDisabled`
/// power setting, which `pmset` changes and which needs root. The guard asks for
/// administrator permission once, to let this user run exactly two `pmset`
/// commands through `sudo` without a password.
@interface SLTClosedLidSleepGuard : NSObject

/// Returns NO inside the App Sandbox, where an app cannot run `sudo` and so cannot use this.
@property (class, nonatomic, readonly) BOOL isSupported;

/// Returns YES if `sudo` allows the user to turn `SleepDisabled` on without a password.
@property (class, nonatomic, readonly) BOOL isAuthorized;

/// Returns YES if the Mac currently runs on battery power.
@property (class, nonatomic, readonly) BOOL isOnBatteryPower;

/// Asks for administrator permission and installs the `sudoers` rule.
/// - Returns: YES on success. On failure, `error` describes the reason.
+ (BOOL)installAuthorizationWithError:(NSError * _Nullable * _Nullable)error;

/// Turns `SleepDisabled` on and starts a watchdog that turns it off again.
///
/// The watchdog runs on its own, so it also works after the app crashes. It
/// turns the setting off when either process exits.
/// @param watchedProcessIdentifier The app process
/// @param caffeinateProcessIdentifier The `caffeinate` process of this session
/// @return NO if the setting could not be turned on, for example without authorization.
+ (BOOL)beginSessionWithWatchedProcessIdentifier:(int)watchedProcessIdentifier
                     caffeinateProcessIdentifier:(int)caffeinateProcessIdentifier;

/// Turns `SleepDisabled` off if a previous run turned it on and could not turn it off,
/// for example after a logout. Does nothing if this app did not turn it on.
+ (void)resetIfLeftEnabledByPreviousRun;

@end

NS_ASSUME_NONNULL_END

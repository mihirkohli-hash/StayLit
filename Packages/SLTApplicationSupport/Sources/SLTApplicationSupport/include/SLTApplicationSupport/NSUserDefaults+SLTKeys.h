//
//  NSUserDefaults+SLTKeys.h
//  SLTApplicationSupport
//
//

#import <Foundation/Foundation.h>
#import <SLTCommon/SLTExport.h>

NS_ASSUME_NONNULL_BEGIN

// User Default Keys
SLT_EXPORT NSString * const SLTUserDefaultsKeyActivateOnLaunch;
SLT_EXPORT NSString * const SLTUserDefaultsKeyAllowDisplaySleep;
SLT_EXPORT NSString * const SLTUserDefaultsKeyKeepAwakeOnLidCloseEnabled;
SLT_EXPORT NSString * const SLTUserDefaultsKeyActivateOnExternalDisplayConnectedEnabled;
SLT_EXPORT NSString * const SLTUserDefaultsKeyDeactivateOnUserSwitchEnabled;
SLT_EXPORT NSString * const SLTUserDefaultsKeyMenuBarIconHighlightDisabled;
SLT_EXPORT NSString * const SLTUserDefaultsKeyMenuBarIconColor;
SLT_EXPORT NSString * const SLTUserDefaultsKeyIsQuitOnTimerExpirationEnabled;
SLT_EXPORT NSString * const SLTUserDefaultsKeyBatteryCapacityThresholdEnabled;
SLT_EXPORT NSString * const SLTUserDefaultsKeyBatteryCapacityThreshold;
SLT_EXPORT NSString * const SLTUserDefaultsKeyLowPowerModeMonitoringEnabled;
SLT_EXPORT NSString * const SLTUserDefaultsKeyPreReleaseUpdatesEnabled;

/// The color of the menu bar icon.
///
/// The raw values are stored in the user defaults, so do not reorder them.
/// White is 0, so it is the default when nothing is stored.
typedef NS_ENUM(NSInteger, SLTMenuBarIconColor) {
    /// A white icon.
    SLTMenuBarIconColorWhite = 0,
    /// A black icon.
    SLTMenuBarIconColorDark = 1,
    /// A template icon that macOS draws white or black to match the menu bar.
    SLTMenuBarIconColorFollowSystem = 2,
};

@interface NSUserDefaults (SLTKeys)

/// Returns YES if the sleep wake timer should be activated on app launch.
@property (nonatomic, getter = slt_isActivatedOnLaunch) BOOL slt_activateOnLaunch;

/// Returns YES if the app should allow the display to sleep while still keeping
/// the system awake. This exposes the `caffeinate -i` command.
@property (nonatomic, getter = slt_shouldAllowDisplaySleep) BOOL slt_allowDisplaySleep;

/// Returns YES if the system should stay awake when the MacBook lid is closed.
/// This exposes the `caffeinate -s` command, which only has an effect on AC power.
@property (nonatomic, getter = slt_isKeepAwakeOnLidCloseEnabled) BOOL slt_keepAwakeOnLidCloseEnabled;

/// The color of the menu bar icon. A missing or unknown stored value returns white.
@property (nonatomic) SLTMenuBarIconColor slt_menuBarIconColor;

/// Returns YES if the menu bar icon should not be highlighted on left and right click.
@property (nonatomic, getter = slt_isMenuBarIconHighlightDisabled) BOOL slt_menuBarIconHighlightDisabled;

/// Returns YES if the sleep wake timer should deactivate below a defined battery capacity threshold.
@property (nonatomic, getter = slt_isBatteryCapacityThresholdEnabled) BOOL slt_batteryCapacityThresholdEnabled;

/// A battery capacity threshold.
///
/// If the user defaults value is below 10.0, 10.0 will be returned.
@property (nonatomic) CGFloat slt_batteryCapacityThreshold;

/// Returns YES if the sleep wake timer should deactivate when Low Power Mode is enabled.
@property (nonatomic, getter=slt_isLowPowerModeMonitoringEnabled) BOOL slt_lowPowerModeMonitoringEnabled;

/// Returns YES if Sparkle should check for pre-release updates.
@property (nonatomic, getter = slt_arePreReleaseUpdatesEnabled) BOOL slt_preReleaseUpdatesEnabled;

/// Returns YES if the app should quit when the sleep wake timer expires.
@property (nonatomic, getter=slt_isQuitOnTimerExpirationEnabled) BOOL slt_quitOnTimerExpirationEnabled;

/// Returns YES if the app should activate when external display is connected.
@property (nonatomic, getter=slt_isActivateOnExternalDisplayConnectedEnabled) BOOL slt_activateOnExternalDisplayConnectedEnabled;

/// Returns YES if the app should deactivate when the user account is switched.
@property (nonatomic, getter=slt_isDeactivateOnUserSwitchEnabled) BOOL slt_deactivateOnUserSwitchEnabled;

@end

NS_ASSUME_NONNULL_END

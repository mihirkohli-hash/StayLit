//
//  NSUserDefaults+SLTKeys.h
//  SLTApplicationSupport
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
SLT_EXPORT NSString * const SLTUserDefaultsKeyMenuBarIconPulseDisabled;
SLT_EXPORT NSString * const SLTUserDefaultsKeyMenuBarIconPulseColor;
SLT_EXPORT NSString * const SLTUserDefaultsKeyMenuBarIconPulseDurationMilliseconds;

/// The default length of one pulse, in seconds.
SLT_EXPORT const NSTimeInterval SLTDefaultMenuBarIconPulseDuration;
/// The shortest and longest pulse the user defaults can ask for, in seconds.
SLT_EXPORT const NSTimeInterval SLTMinimumMenuBarIconPulseDuration;
SLT_EXPORT const NSTimeInterval SLTMaximumMenuBarIconPulseDuration;
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

/// The color of the screen on the menu bar icon while it pulses.
///
/// The raw values are stored in the user defaults, so do not reorder them.
/// The contrast color is the default when nothing is stored.
typedef NS_ENUM(NSInteger, SLTMenuBarIconPulseColor) {
    /// The accent color from System Settings.
    SLTMenuBarIconPulseColorAccent = 0,
    SLTMenuBarIconPulseColorGreen = 1,
    SLTMenuBarIconPulseColorBlue = 2,
    SLTMenuBarIconPulseColorOrange = 3,
    SLTMenuBarIconPulseColorRed = 4,
    SLTMenuBarIconPulseColorPurple = 5,
    /// The color of the icon body, so only the brightness of the screen changes.
    SLTMenuBarIconPulseColorSameAsIcon = 6,
    /// The opposite of the icon body: black on a white icon and white on a dark icon.
    /// With the icon color Follow System, it is the opposite of the menu bar text color.
    SLTMenuBarIconPulseColorContrast = 7,
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

/// Returns YES if the menu bar icon should not pulse while the sleep wake timer is active.
@property (nonatomic, getter = slt_isMenuBarIconPulseDisabled) BOOL slt_menuBarIconPulseDisabled;

/// The length of one pulse cycle in seconds, from the dimmest screen to the brightest and back.
///
/// The user defaults store whole milliseconds, so the Settings drop-down can bind to them.
/// A missing, non-numeric or non-positive value returns the default of 1 second.
/// Any other value is limited to the range of the minimum and maximum duration.
@property (nonatomic) NSTimeInterval slt_menuBarIconPulseDuration;

/// The color of the pulsing screen. A missing or unknown stored value returns the contrast color.
@property (nonatomic) SLTMenuBarIconPulseColor slt_menuBarIconPulseColor;

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

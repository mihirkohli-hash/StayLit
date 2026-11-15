//
//  NSUserDefaults+SLTKeys.m
//  SLTApplicationSupport
//

#import <SLTApplicationSupport/NSUserDefaults+SLTKeys.h>
#import <SLTCommon/SLTCommon.h>

// A macro to define a new user defaults convenience property for BOOL values.
// - _short_getter_name represents the name of the getter,
//                      e.g. `isSomethingEnabled` without the `slt_` prefix.
// - _property_name represents the name of the property and the setter,
//                      e.g. `somethingEnabled` without the `slt_` prefix.
// - _short_defaults_key represents a user defaults key,
//                      e.g. `SomethingEnabled` without any prefixes
//
// These values will generate the implementation for a property
// e.g. `@property (nonatomic, getter=slt_isSomethingEnabled) BOOL slt_somethingEnabled;`
// and for a user defaults key constant
// e.g. `SLT_EXPORT NSString * const SLTUserDefaultsKeySomethingEnabled;`
// which will create an actual string key in the pre-defined format
// e.g. `io.github.mihirkohli-hash.StayLit.SomethingEnabled`
#define SLT_GENERATE_BOOL_PROPERTY(_short_getter_name, _property_name, _short_defaults_key) \
NSString * const SLTUserDefaultsKey##_short_defaults_key =                                  \
    @"io.github.mihirkohli-hash.StayLit." #_short_defaults_key;                           \
                                                                                            \
- (BOOL)slt_##_short_getter_name                                                            \
{                                                                                           \
    return [self boolForKey:SLTUserDefaultsKey##_short_defaults_key];                       \
}                                                                                           \
- (void)setSlt_##_property_name:(BOOL)enabled                                               \
{                                                                                           \
    [self setBool:enabled forKey:SLTUserDefaultsKey##_short_defaults_key];                  \
}

@implementation NSUserDefaults (SLTKeys)

SLT_GENERATE_BOOL_PROPERTY(isActivatedOnLaunch,
                           activateOnLaunch,
                           ActivateOnLaunch);

SLT_GENERATE_BOOL_PROPERTY(shouldAllowDisplaySleep,
                           allowDisplaySleep,
                           AllowDisplaySleep);

SLT_GENERATE_BOOL_PROPERTY(isKeepAwakeOnLidCloseEnabled,
                           keepAwakeOnLidCloseEnabled,
                           KeepAwakeOnLidCloseEnabled);

SLT_GENERATE_BOOL_PROPERTY(isMenuBarIconPulseDisabled,
                           menuBarIconPulseDisabled,
                           MenuBarIconPulseDisabled);

SLT_GENERATE_BOOL_PROPERTY(isMenuBarIconHighlightDisabled,
                           menuBarIconHighlightDisabled,
                           MenuBarIconHighlightDisabled);

SLT_GENERATE_BOOL_PROPERTY(arePreReleaseUpdatesEnabled,
                           preReleaseUpdatesEnabled,
                           PreReleaseUpdatesEnabled);

SLT_GENERATE_BOOL_PROPERTY(isQuitOnTimerExpirationEnabled,
                           quitOnTimerExpirationEnabled,
                           IsQuitOnTimerExpirationEnabled);

SLT_GENERATE_BOOL_PROPERTY(isActivateOnExternalDisplayConnectedEnabled,
                           activateOnExternalDisplayConnectedEnabled,
                           ActivateOnExternalDisplayConnectedEnabled);


SLT_GENERATE_BOOL_PROPERTY(isDeactivateOnUserSwitchEnabled,
                           deactivateOnUserSwitchEnabled,
                           DeactivateOnUserSwitchEnabled);

SLT_GENERATE_BOOL_PROPERTY(isBatteryCapacityThresholdEnabled,
                           batteryCapacityThresholdEnabled,
                           BatteryCapacityThresholdEnabled);

SLT_GENERATE_BOOL_PROPERTY(isLowPowerModeMonitoringEnabled,
                           lowPowerModeMonitoringEnabled,
                           LowPowerModeMonitoringEnabled);

#pragma mark - Menu Bar Icon Color

NSString * const SLTUserDefaultsKeyMenuBarIconColor = @"io.github.mihirkohli-hash.StayLit.MenuBarIconColor";

- (SLTMenuBarIconColor)slt_menuBarIconColor
{
    Auto storedValue = [self integerForKey:SLTUserDefaultsKeyMenuBarIconColor];
    switch(storedValue)
    {
        case SLTMenuBarIconColorDark:
        case SLTMenuBarIconColorFollowSystem:
            return (SLTMenuBarIconColor)storedValue;
        default:
            return SLTMenuBarIconColorWhite;
    }
}

- (void)setSlt_menuBarIconColor:(SLTMenuBarIconColor)menuBarIconColor
{
    [self setInteger:menuBarIconColor forKey:SLTUserDefaultsKeyMenuBarIconColor];
}

#pragma mark - Menu Bar Icon Pulse Duration

NSString * const SLTUserDefaultsKeyMenuBarIconPulseDurationMilliseconds = @"io.github.mihirkohli-hash.StayLit.MenuBarIconPulseDurationMilliseconds";
const NSTimeInterval SLTDefaultMenuBarIconPulseDuration = 1.0;
const NSTimeInterval SLTMinimumMenuBarIconPulseDuration = 0.25;
const NSTimeInterval SLTMaximumMenuBarIconPulseDuration = 10.0;

- (NSTimeInterval)slt_menuBarIconPulseDuration
{
    // A string or a missing key is not a duration. A zero or negative one would
    // make the pulse timer fire without pause, so those fall back to the default as well.
    Auto storedValue = [self objectForKey:SLTUserDefaultsKeyMenuBarIconPulseDurationMilliseconds];
    if(![storedValue isKindOfClass:NSNumber.class] || [storedValue doubleValue] <= 0)
    {
        return SLTDefaultMenuBarIconPulseDuration;
    }

    Auto seconds = [storedValue doubleValue] / 1000.0;
    return MIN(MAX(seconds, SLTMinimumMenuBarIconPulseDuration), SLTMaximumMenuBarIconPulseDuration);
}

- (void)setSlt_menuBarIconPulseDuration:(NSTimeInterval)duration
{
    [self setInteger:(NSInteger)llround(duration * 1000.0) forKey:SLTUserDefaultsKeyMenuBarIconPulseDurationMilliseconds];
}

#pragma mark - Battery Capacity Threshold

NSString * const SLTUserDefaultsKeyBatteryCapacityThreshold = @"io.github.mihirkohli-hash.StayLit.BatteryCapacityThreshold";

- (CGFloat)slt_batteryCapacityThreshold
{
    CGFloat threshold = [self floatForKey:SLTUserDefaultsKeyBatteryCapacityThreshold];
    return MAX(10.0f , threshold);
}

- (void)setSlt_batteryCapacityThreshold:(CGFloat)batteryCapacityThreshold
{
    [self setFloat:(float)batteryCapacityThreshold forKey:SLTUserDefaultsKeyBatteryCapacityThreshold];
}

@end

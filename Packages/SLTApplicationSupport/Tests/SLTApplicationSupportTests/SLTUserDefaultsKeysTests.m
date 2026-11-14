//
//  SLTUserDefaultsKeysTests.m
//  SLTApplicationSupport
//
//

#import <XCTest/XCTest.h>
#import <SLTCommon/SLTCommon.h>
#import <SLTApplicationSupport/SLTApplicationSupport.h>
#import "../../Sources/SLTApplicationSupport/SLTApplicationSupportLog.h"

#define SLT_GENERATE_BOOL_TEST(_short_getter_name, _property_name, _defaults_key)           \
- (void)testProperty_##_property_name                                                       \
{                                                                                           \
    Auto defaults = self.defaults;                                                          \
    Auto key = _defaults_key;                                                               \
                                                                                            \
    defaults.slt_##_property_name = YES;                                                    \
    XCTAssertTrue([defaults slt_##_short_getter_name]);                                     \
    XCTAssertTrue([defaults boolForKey:key]);                                               \
                                                                                            \
    defaults.slt_##_property_name = NO;                                                     \
    XCTAssertFalse([defaults slt_##_short_getter_name]);                                    \
    XCTAssertFalse([defaults boolForKey:key]);                                              \
                                                                                            \
    [defaults setBool:YES forKey:key];                                                      \
    XCTAssertTrue([defaults slt_##_short_getter_name]);                                     \
    os_log(SLTApplicationSupportLog(), "Tested User Defaults Key '%{public}@'.", key);      \
}

@interface SLTUserDefaultsKeysTests : XCTestCase
@property (nonatomic) NSUserDefaults *defaults;
@end

@implementation SLTUserDefaultsKeysTests

- (void)setUp
{
    [super setUp];
    
    self.defaults = [[NSUserDefaults alloc] initWithSuiteName:NSStringFromClass([self class])];

    // The suite lives on disk, and the test plan runs tests in random order. A value stored by
    // another test or an earlier run must not decide what a "default" test sees.
    [self.defaults removeObjectForKey:SLTUserDefaultsKeyMenuBarIconColor];
    [self.defaults removeObjectForKey:SLTUserDefaultsKeyMenuBarIconPulseDurationMilliseconds];
    [self.defaults removeObjectForKey:SLTUserDefaultsKeyMenuBarIconPulseColor];
}

SLT_GENERATE_BOOL_TEST(isActivatedOnLaunch,
                       activateOnLaunch,
                       SLTUserDefaultsKeyActivateOnLaunch);

SLT_GENERATE_BOOL_TEST(shouldAllowDisplaySleep,
                       allowDisplaySleep,
                       SLTUserDefaultsKeyAllowDisplaySleep);

SLT_GENERATE_BOOL_TEST(isKeepAwakeOnLidCloseEnabled,
                       keepAwakeOnLidCloseEnabled,
                       SLTUserDefaultsKeyKeepAwakeOnLidCloseEnabled);

SLT_GENERATE_BOOL_TEST(isMenuBarIconPulseDisabled,
                       menuBarIconPulseDisabled,
                       SLTUserDefaultsKeyMenuBarIconPulseDisabled);

SLT_GENERATE_BOOL_TEST(isMenuBarIconHighlightDisabled,
                       menuBarIconHighlightDisabled,
                       SLTUserDefaultsKeyMenuBarIconHighlightDisabled);

SLT_GENERATE_BOOL_TEST(arePreReleaseUpdatesEnabled,
                       preReleaseUpdatesEnabled,
                       SLTUserDefaultsKeyPreReleaseUpdatesEnabled);

SLT_GENERATE_BOOL_TEST(isQuitOnTimerExpirationEnabled,
                       quitOnTimerExpirationEnabled,
                       SLTUserDefaultsKeyIsQuitOnTimerExpirationEnabled);

SLT_GENERATE_BOOL_TEST(isActivateOnExternalDisplayConnectedEnabled,
                       activateOnExternalDisplayConnectedEnabled,
                       SLTUserDefaultsKeyActivateOnExternalDisplayConnectedEnabled);

SLT_GENERATE_BOOL_TEST(isDeactivateOnUserSwitchEnabled,
                       deactivateOnUserSwitchEnabled,
                       SLTUserDefaultsKeyDeactivateOnUserSwitchEnabled);

SLT_GENERATE_BOOL_TEST(isBatteryCapacityThresholdEnabled,
                       batteryCapacityThresholdEnabled,
                       SLTUserDefaultsKeyBatteryCapacityThresholdEnabled);

SLT_GENERATE_BOOL_TEST(isLowPowerModeMonitoringEnabled,
                       lowPowerModeMonitoringEnabled,
                       SLTUserDefaultsKeyLowPowerModeMonitoringEnabled);

- (void)testMenuBarIconColorDefaultsToWhite
{
    XCTAssertEqual(self.defaults.slt_menuBarIconColor, SLTMenuBarIconColorWhite);
}

- (void)testMenuBarIconColorRoundTrip
{
    Auto defaults = self.defaults;
    Auto key = SLTUserDefaultsKeyMenuBarIconColor;

    defaults.slt_menuBarIconColor = SLTMenuBarIconColorDark;
    XCTAssertEqual(defaults.slt_menuBarIconColor, SLTMenuBarIconColorDark);
    XCTAssertEqual([defaults integerForKey:key], 1);

    defaults.slt_menuBarIconColor = SLTMenuBarIconColorFollowSystem;
    XCTAssertEqual(defaults.slt_menuBarIconColor, SLTMenuBarIconColorFollowSystem);
    XCTAssertEqual([defaults integerForKey:key], 2);

    defaults.slt_menuBarIconColor = SLTMenuBarIconColorWhite;
    XCTAssertEqual(defaults.slt_menuBarIconColor, SLTMenuBarIconColorWhite);
    XCTAssertEqual([defaults integerForKey:key], 0);
}

- (void)testMenuBarIconColorFallsBackToWhiteForUnknownValues
{
    Auto defaults = self.defaults;
    Auto key = SLTUserDefaultsKeyMenuBarIconColor;

    for(NSNumber *value in @[@(-1), @3, @99, @(NSIntegerMax)])
    {
        [defaults setInteger:value.integerValue forKey:key];
        XCTAssertEqual(defaults.slt_menuBarIconColor, SLTMenuBarIconColorWhite, @"%@ should fall back to white", value);
    }

    [defaults setObject:@"dark" forKey:key];
    XCTAssertEqual(defaults.slt_menuBarIconColor, SLTMenuBarIconColorWhite, @"A string is not a valid value");
    [defaults removeObjectForKey:key];
    XCTAssertEqual(defaults.slt_menuBarIconColor, SLTMenuBarIconColorWhite);
}

- (void)testMenuBarIconPulseColorDefaultsToTheAccentColor
{
    XCTAssertEqual(self.defaults.slt_menuBarIconPulseColor, SLTMenuBarIconPulseColorAccent);
}

- (void)testMenuBarIconPulseColorRoundTripForEveryChoice
{
    Auto defaults = self.defaults;
    Auto choices = @[@(SLTMenuBarIconPulseColorAccent), @(SLTMenuBarIconPulseColorGreen), @(SLTMenuBarIconPulseColorBlue),
                     @(SLTMenuBarIconPulseColorOrange), @(SLTMenuBarIconPulseColorRed), @(SLTMenuBarIconPulseColorPurple),
                     @(SLTMenuBarIconPulseColorSameAsIcon)];
    for(NSNumber *choice in choices)
    {
        defaults.slt_menuBarIconPulseColor = (SLTMenuBarIconPulseColor)choice.integerValue;
        XCTAssertEqual(defaults.slt_menuBarIconPulseColor, (SLTMenuBarIconPulseColor)choice.integerValue);
        XCTAssertEqual([defaults integerForKey:SLTUserDefaultsKeyMenuBarIconPulseColor], choice.integerValue, @"The Settings drop-down binds to the raw value.");
    }
    XCTAssertEqual(choices.count, 7u);
}

- (void)testMenuBarIconPulseColorFallsBackToTheAccentColorForUnknownValues
{
    Auto defaults = self.defaults;
    Auto key = SLTUserDefaultsKeyMenuBarIconPulseColor;

    for(NSNumber *value in @[@(-1), @7, @99, @(NSIntegerMax), @(NSIntegerMin)])
    {
        [defaults setInteger:value.integerValue forKey:key];
        XCTAssertEqual(defaults.slt_menuBarIconPulseColor, SLTMenuBarIconPulseColorAccent, @"%@ should fall back to the accent color", value);
    }
    [defaults setObject:@"green" forKey:key];
    XCTAssertEqual(defaults.slt_menuBarIconPulseColor, SLTMenuBarIconPulseColorAccent, @"A string is not a valid value");
    [defaults removeObjectForKey:key];
    XCTAssertEqual(defaults.slt_menuBarIconPulseColor, SLTMenuBarIconPulseColorAccent);
}

- (void)testMenuBarIconPulseDurationDefaultsToOneSecond
{
    XCTAssertEqual(self.defaults.slt_menuBarIconPulseDuration, 1.0);
    XCTAssertEqual(SLTDefaultMenuBarIconPulseDuration, 1.0);
}

- (void)testMenuBarIconPulseDurationRoundTripStoresMilliseconds
{
    Auto defaults = self.defaults;
    Auto key = SLTUserDefaultsKeyMenuBarIconPulseDurationMilliseconds;

    for(NSNumber *seconds in @[@0.5, @1.0, @2.0, @3.0, @5.0])
    {
        defaults.slt_menuBarIconPulseDuration = seconds.doubleValue;
        XCTAssertEqual(defaults.slt_menuBarIconPulseDuration, seconds.doubleValue);
        XCTAssertEqual([defaults integerForKey:key], (NSInteger)(seconds.doubleValue * 1000), @"The Settings drop-down binds to whole milliseconds.");
    }
}

- (void)testMenuBarIconPulseDurationIsLimitedToTheSupportedRange
{
    Auto defaults = self.defaults;
    Auto key = SLTUserDefaultsKeyMenuBarIconPulseDurationMilliseconds;

    [defaults setInteger:10 forKey:key];
    XCTAssertEqual(defaults.slt_menuBarIconPulseDuration, SLTMinimumMenuBarIconPulseDuration, @"A very short pulse would wake the app too often.");
    [defaults setInteger:999999 forKey:key];
    XCTAssertEqual(defaults.slt_menuBarIconPulseDuration, SLTMaximumMenuBarIconPulseDuration);
    [defaults setInteger:250 forKey:key];
    XCTAssertEqual(defaults.slt_menuBarIconPulseDuration, 0.25, @"The limits themselves are allowed.");
    [defaults setInteger:10000 forKey:key];
    XCTAssertEqual(defaults.slt_menuBarIconPulseDuration, 10.0);
}

- (void)testMenuBarIconPulseDurationFallsBackToTheDefaultForUnusableValues
{
    Auto defaults = self.defaults;
    Auto key = SLTUserDefaultsKeyMenuBarIconPulseDurationMilliseconds;

    for(id value in @[@0, @(-1), @(-5000), @"fast", @[@1], @{@"a": @1}, [NSData data]])
    {
        [defaults setObject:value forKey:key];
        XCTAssertEqual(defaults.slt_menuBarIconPulseDuration, 1.0, @"%@ must fall back to 1 second", value);
    }
    [defaults removeObjectForKey:key];
    XCTAssertEqual(defaults.slt_menuBarIconPulseDuration, 1.0);
}

- (void)testBatteryCapacityThreshold
{
    Auto defaults = self.defaults;
    Auto key = SLTUserDefaultsKeyBatteryCapacityThreshold;
    
    defaults.slt_batteryCapacityThreshold = 90.0f;
    XCTAssertEqual([defaults slt_batteryCapacityThreshold], 90.0f);
    XCTAssertEqual([defaults floatForKey:key], 90.0f);
    
    [defaults setFloat:50.0f forKey:key];
    XCTAssertEqual([defaults slt_batteryCapacityThreshold], 50.0f);
    
    // Below 10%
    defaults.slt_batteryCapacityThreshold = 0.1f;
    XCTAssertEqual([defaults slt_batteryCapacityThreshold], 10.0f);
    XCTAssertEqual([defaults floatForKey:key], 0.1f); // TODO: Maybe the setter should catch this?
    
    [defaults setFloat:0.2f forKey:key];
    XCTAssertEqual([defaults slt_batteryCapacityThreshold], 10.0f);
    
    // Over 100%
    defaults.slt_batteryCapacityThreshold = 512.0f; // TODO: Maybe this should be invalid?
    XCTAssertEqual([defaults slt_batteryCapacityThreshold], 512.0f);
    XCTAssertEqual([defaults floatForKey:key], 512.0f);
}

@end

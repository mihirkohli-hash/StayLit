//
//  SLTBatterySettingsViewController.m
//  StayLit
//

#import "SLTBatterySettingsViewController.h"
#import <SLTCommon/SLTCommon.h>
#import "SLTLocalizedStrings.h"
#import "SLTBatteryCapacityThreshold.h"

@interface SLTBatterySettingsViewController ()
@end

@implementation SLTBatterySettingsViewController

+ (NSImage *)tabViewItemImage
{
    return [NSImage imageWithSystemSymbolName:@"battery.100" accessibilityDescription:nil];
}

+ (NSString *)preferredTitle
{
    return SLT_SETTINGS_L10N_BATTERY;
}

- (BOOL)resizesView
{
    return YES;
}

#pragma mark - Device

- (SLTDevice *)device
{
    return SLTDevice.currentDevice;
}

#pragma mark - Battery Settings Did Change

- (void)batterySettingsDidChange:(id)sender
{
    Auto center = NSNotificationCenter.defaultCenter;
    [center postNotificationName:kSLTBatteryCapacityThresholdDidChangeNotification
                          object:nil];
}

@end

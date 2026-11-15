//
//  SLTBatterySettingsViewController.h
//  StayLit
//

#import <Cocoa/Cocoa.h>
#import <SLTDeviceInfo/SLTDeviceInfo.h>
#import "SLTSettingsContentViewController.h"

NS_ASSUME_NONNULL_BEGIN

/// Shows "Battery" settings.
@interface SLTBatterySettingsViewController : SLTSettingsContentViewController
/// Provides access to the battery level and
/// low power mode of the physical device.
@property (nonatomic, readonly) SLTDevice *device;

/// Is responsible for notifying the app controller about any
/// battery status settings changes.
/// @param sender The sending control
- (IBAction)batterySettingsDidChange:(nullable id)sender;

@end

NS_ASSUME_NONNULL_END

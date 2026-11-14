//
//  SLTBatteryMonitor.h
//  SLTDeviceInfo
//
//

#import <Foundation/Foundation.h>
#import <SLTCommon/SLTExport.h>

NS_ASSUME_NONNULL_BEGIN

SLT_EXPORT const CGFloat SLTBatteryCapacityUnavailable;

/// The battery state of the device.
typedef NS_ENUM(NSUInteger, SLTDeviceBatteryState)
{
    /// The battery state for the device cannot be determined.
    SLTDeviceBatteryStateUnknown = 0,
    /// The device is not plugged into power; the battery is discharging.
    SLTDeviceBatteryStateUnplugged,
    /// The device is plugged into power and the battery is less than 100% charged.
    SLTDeviceBatteryStateCharging,
    /// The device is plugged into power and the battery is less than 100% charged.
    SLTDeviceBatteryStateFull,
};

/// Monitors the status for the device's battery.
@interface SLTBatteryMonitor : NSObject

/// Returns `YES` if the current device actually has a built-in battery.
@property (nonatomic, readonly) BOOL hasBattery;

/// Returns the current battery charging level of the internal battery,
/// or `SLTBatteryCapacityUnavailable`.
@property (nonatomic, readonly) CGFloat currentCapacity;

/// The battery state for the device.
@property (nonatomic, readonly) SLTDeviceBatteryState state;

@end

NS_ASSUME_NONNULL_END

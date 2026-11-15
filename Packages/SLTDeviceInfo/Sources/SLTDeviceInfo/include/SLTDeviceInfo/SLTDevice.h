//
//  SLTDevice.h
//  SLTDeviceInfo
//

#import <Foundation/Foundation.h>
#import <SLTDeviceInfo/SLTBatteryMonitor.h>
#import <SLTDeviceInfo/SLTLowPowerModeMonitor.h>
#import <SLTCommon/SLTExport.h>

NS_ASSUME_NONNULL_BEGIN

SLT_EXPORT const NSNotificationName SLTDeviceParameterDidChangeNotification;
SLT_EXPORT NSString * const SLTDeviceParameterKey;

typedef NSString *SLTDeviceParameter;
SLT_EXPORT const SLTDeviceParameter SLTDeviceParameterBattery;
SLT_EXPORT const SLTDeviceParameter SLTDeviceParameterLowPowerMode;

/// Provides access to physical device parameters, like battery status and Low Power Mode.
@interface SLTDevice : NSObject

/// Represents the current device
@property (class, nonatomic, readonly) SLTDevice *currentDevice;

#pragma mark - Battery Monitor

/// The battery status monitor for devices that support this feature.
@property (nonatomic, readonly) SLTBatteryMonitor *batteryMonitor;

/// Starts or stops receiving changes to the device's battery status.
///
/// When set to `YES`, you can observe the `SLTDeviceParameterDidChangeNotification` with
/// the `SLTDeviceParameterKey` user info value of `SLTDeviceParameterBattery` to
/// receive notifications for each battery status change on supported devices.
/// ///
/// Defaults to `NO`.
@property(nonatomic, getter=isBatteryMonitoringEnabled) BOOL batteryMonitoringEnabled;

#pragma mark - Lower Power Mode

/// The Low Power Mode monitor for devices that support this feature.
@property (nonatomic, readonly) SLTLowPowerModeMonitor *lowPowerModeMonitor;

/// Starts or stops receiving changes to the device's Low Power Mode.
///
/// When set to `YES`, you can observe the `SLTDeviceParameterDidChangeNotification` with
/// the `SLTDeviceParameterKey` user info value of `SLTDeviceParameterLowPowerMode` to
/// receive notifications for each Low Power Mode change on supported devices.
///
/// Defaults to `NO`.
@property(nonatomic, getter=isLowPowerModeMonitoringEnabled) BOOL lowPowerModeMonitoringEnabled;

#pragma mark -

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END

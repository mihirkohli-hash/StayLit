//
//  SLTLowPowerModeMonitor.h
//  SLTDeviceInfo
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Monitors the status of the device's Low Power Mode.
@interface SLTLowPowerModeMonitor : NSObject

/// Returns `YES` if the current device supports the Low Power Mode.
@property (nonatomic, readonly) BOOL supportsLowPowerMode;

/// Returns `YES` if Low Power Mode is currently enabled.
@property (nonatomic, readonly, getter=isLowPowerModeEnabled) BOOL lowPowerModeEnabled;

@end

NS_ASSUME_NONNULL_END

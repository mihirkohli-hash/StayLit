//
//  SLTLowPowerModeMonitor+Private.h
//  SLTDeviceInfo
//

#import <Foundation/Foundation.h>
#import <SLTDeviceInfo/SLTLowPowerModeMonitor.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^SLTLowPowerModeChangeBlock)(BOOL enabled);

@interface SLTLowPowerModeMonitor ()
@property (nonatomic, getter=isRegistered) BOOL registered;

/// An optional block that will be called when the Low Power Mode status
/// changes and -registerForLowPowerModeChanges was called.
@property (copy, nonatomic, nullable) SLTLowPowerModeChangeBlock lowPowerModeChangeHandler;

/// Registers for receiving changes to the Low Power Mode.
///
/// The `lowPowerModeChangeHandler` will be called when the status changes.
- (void)registerForLowPowerModeChanges;

/// Unregisters from receiving changes to the Low Power Mode.
- (void)unregisterFromLowPowerModeChanges;

@end

NS_ASSUME_NONNULL_END

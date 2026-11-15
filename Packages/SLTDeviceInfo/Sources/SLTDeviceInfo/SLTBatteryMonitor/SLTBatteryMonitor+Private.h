//
//  SLTBatteryMonitor+Private.h
//  SLTDeviceInfo
//

#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>
#import <SLTDeviceInfo/SLTBatteryMonitor.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^SLTBatteryMonitorChangeBlock)(CGFloat capacity);

@interface SLTBatteryMonitor ()
@property (nonatomic, nullable) CFRunLoopSourceRef runLoopSource;
@property (nonatomic, readonly, getter=isRegistered) BOOL registered;

/// An optional block that will be called when the power source changes and
/// -registerForCapacityChanges was called.
@property (copy, nonatomic, nullable) SLTBatteryMonitorChangeBlock capacityChangeHandler;

/// Registers the current instance with the runloop to receive power source change notifications.
///
/// The `capacityChangeHandler` block will be called when a power source change occurs.
- (void)registerForCapacityChangesIfNeeded;

/// Unregisters the current instance from all capacity change notifications.
/// This method will automatically be called on dealloc.
- (void)unregisterFromCapacityChanges;

@end

NS_ASSUME_NONNULL_END

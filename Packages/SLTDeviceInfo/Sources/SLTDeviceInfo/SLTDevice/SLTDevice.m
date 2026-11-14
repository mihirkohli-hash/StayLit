//
//  SLTDevice.m
//  SLTDeviceInfo
//
//

#import <SLTDeviceInfo/SLTDevice.h>
#import <SLTCommon/SLTCommon.h>
#import "../SLTBatteryMonitor/SLTBatteryMonitor+Private.h"
#import "../SLTLowPowerModeMonitor/SLTLowPowerModeMonitor+Private.h"

const NSNotificationName SLTDeviceParameterDidChangeNotification = @"SLTDeviceParameterDidChangeNotification";
NSString * const SLTDeviceParameterKey = @"SLTDeviceParameterKey";
const SLTDeviceParameter SLTDeviceParameterBattery = @"SLTDeviceParameterBattery";
const SLTDeviceParameter SLTDeviceParameterLowPowerMode = @"SLTDeviceParameterLowPowerMode";

@interface SLTDevice ()
@property (nonatomic, readwrite) SLTBatteryMonitor *batteryMonitor;
@property (nonatomic, readwrite) SLTLowPowerModeMonitor *lowPowerModeMonitor;
@property (nonatomic) os_log_t log;
@end

@implementation SLTDevice

+ (instancetype)currentDevice
{
    static dispatch_once_t once;
    static SLTDevice *currentDevice;
    dispatch_once(&once, ^{
        currentDevice = [[self alloc] init];
    });
    return currentDevice;
}

#pragma mark -

- (instancetype)init
{
    self = [super init];
    if(self)
    {
        self.batteryMonitor = [SLTBatteryMonitor new];
        self.lowPowerModeMonitor = [SLTLowPowerModeMonitor new];
        self.log = SLTLogCreateWithCategory("DeviceInfo");
    }
    return self;
}

#pragma mark - Battery Monitor

- (BOOL)isBatteryMonitoringEnabled
{
    return [self.batteryMonitor isRegistered];
}

- (void)setBatteryMonitoringEnabled:(BOOL)batteryMonitoringEnabled
{
    Auto batteryMonitor = self.batteryMonitor;
    
    if(batteryMonitoringEnabled == YES)
    {
        // Do not start monitoring if the device does not support this feature
        if([batteryMonitor hasBattery] == NO) { return; }
        
        AutoWeak weakSelf = self;
        batteryMonitor.capacityChangeHandler = ^(CGFloat capacity) {
            Auto strongSelf = weakSelf;
            
            if([strongSelf isBatteryMonitoringEnabled])
            {
                [strongSelf deviceParameterDidChange:SLTDeviceParameterBattery];
            }
        };
        [batteryMonitor registerForCapacityChangesIfNeeded];
    }
    else
    {
        [batteryMonitor unregisterFromCapacityChanges];
        batteryMonitor.capacityChangeHandler = nil;
    }
    
    os_log(self.log, "Battery Monitoring: %{public}@", batteryMonitoringEnabled ? @"YES" : @"NO");
}

#pragma mark - Lower Power Mode

- (BOOL)isLowPowerModeMonitoringEnabled
{
    return [self.lowPowerModeMonitor isRegistered];
}

- (void)setLowPowerModeMonitoringEnabled:(BOOL)lowPowerModeMonitoringEnabled
{
    Auto lowPowerModeMonitor = self.lowPowerModeMonitor;
    
    if(lowPowerModeMonitoringEnabled)
    {
        // Do not start monitoring if the device does not support this feature
        if([lowPowerModeMonitor supportsLowPowerMode] == NO) { return; }
        
        AutoWeak weakSelf = self;
        lowPowerModeMonitor.lowPowerModeChangeHandler = ^(BOOL enabled) {
            Auto strongSelf = weakSelf;
            
            if([strongSelf isLowPowerModeMonitoringEnabled])
            {
                [strongSelf deviceParameterDidChange:SLTDeviceParameterLowPowerMode];
            }
        };
        [lowPowerModeMonitor registerForLowPowerModeChanges];
    }
    else
    {
        [lowPowerModeMonitor unregisterFromLowPowerModeChanges];
        lowPowerModeMonitor.lowPowerModeChangeHandler = nil;
    }
    
    os_log(self.log, "Low Power Mode Monitoring: %{public}@", lowPowerModeMonitoringEnabled ? @"YES" : @"NO");
}

#pragma mark - Notifications

- (void)deviceParameterDidChange:(SLTDeviceParameter)deviceParameter
{
    NSParameterAssert(deviceParameter);
    
    Auto center = NSNotificationCenter.defaultCenter;
    Auto userInfo = @{
        SLTDeviceParameterKey: deviceParameter
    };
    
    dispatch_async(dispatch_get_main_queue(), ^{
       [center postNotificationName:SLTDeviceParameterDidChangeNotification
                             object:self
                           userInfo:userInfo];
    });
    
    os_log(self.log, "Device parameter did change: %{public}@, %{public}@.", deviceParameter, userInfo);
}

@end

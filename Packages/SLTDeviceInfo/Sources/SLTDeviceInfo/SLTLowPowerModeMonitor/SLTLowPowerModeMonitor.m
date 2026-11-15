//
//  SLTLowPowerModeMonitor.m
//  SLTDeviceInfo
//

#import "SLTLowPowerModeMonitor+Private.h"
#import <SLTCommon/SLTCommon.h>

@implementation SLTLowPowerModeMonitor

- (void)dealloc
{
    [self unregisterFromLowPowerModeChanges];
}

- (BOOL)supportsLowPowerMode
{
    return YES;
}

- (BOOL)isLowPowerModeEnabled
{
    return [NSProcessInfo.processInfo isLowPowerModeEnabled];
}

#pragma mark - Low Power Mode Changes

- (void)registerForLowPowerModeChanges
{
    if([self isRegistered]) return;
    
    Auto center = NSNotificationCenter.defaultCenter;
    [center addObserver:self
               selector:@selector(handlePowerModeDidChange:)
                   name:NSProcessInfoPowerStateDidChangeNotification
                 object:nil];
    
    self.registered = YES;
}

- (void)unregisterFromLowPowerModeChanges
{
    if([self isRegistered] == NO) { return; }
    
    Auto center = NSNotificationCenter.defaultCenter;
    [center removeObserver:self
                      name:NSProcessInfoPowerStateDidChangeNotification
                    object:nil];
    self.registered = NO;
}

- (void)handlePowerModeDidChange:(NSNotification *)notification API_AVAILABLE(macos(12.0))
{
    Auto handler = self.lowPowerModeChangeHandler;
    BOOL powerMode = [NSProcessInfo.processInfo isLowPowerModeEnabled];
    dispatch_async(dispatch_get_main_queue(), ^{
       if(handler != nil)
       {
           handler(powerMode);
       }
    });
}

@end

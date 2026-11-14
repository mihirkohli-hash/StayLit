//
//  NSApplication+SLTLaunchAtLogin.m
//  SLTApplicationSupport
//
//

#import <SLTApplicationSupport/NSApplication+SLTLaunchAtLogin.h>
#import <ServiceManagement/ServiceManagement.h>
#import <SLTCommon/SLTCommon.h>
#import "SLTApplicationSupportLog.h"

@implementation NSApplication (SLTLaunchAtLogin)

- (BOOL)slt_isLaunchAtLoginEnabled
{
    if(@available(macOS 13.0, *))
    {
        return SLTLaunchAtLoginAppServiceIsEnabled();
    }
    else
    {
        return SLTLaunchAtLoginLoginItemIsEnabled();
    }
}

- (BOOL)slt_launchAtLoginEnabled
{
    return [self slt_isLaunchAtLoginEnabled];
}

- (void)setSlt_launchAtLoginEnabled:(BOOL)launchAtLoginEnabled
{
    [self willChangeValueForKey:@"slt_launchAtLoginEnabled"];
    
    if(@available(macOS 13.0, *))
    {
        return SLTLaunchAtLoginAppServiceSetEnabled(launchAtLoginEnabled);
    }
    else
    {
        return SLTLaunchAtLoginLoginItemSetEnabled(launchAtLoginEnabled);
    }
    
    [self didChangeValueForKey:@"slt_launchAtLoginEnabled"];
}

#pragma mark - Migration

- (void)slt_migrateLaunchAtLoginToAppServiceIfNeeded
{
    if(SLTLaunchAtLoginUserDefaultExists() == NO) { return; }
    
    if(SLTLaunchAtLoginLoginItemIsEnabled())
    {
        SLTLaunchAtLoginLoginItemSetEnabled(NO);
        SLTLaunchAtLoginAppServiceSetEnabled(YES);
    }
    
    SLTLaunchAtLoginUserDefaultReset();
}

#pragma mark - SMAppService

NS_INLINE BOOL SLTLaunchAtLoginAppServiceIsEnabled() API_AVAILABLE(macos(13.0))
{
    Auto status = SMAppService.mainAppService.status;
    if(status == SMAppServiceStatusRequiresApproval)
    {
        [SMAppService openSystemSettingsLoginItems];
    }
    
    return status == SMAppServiceStatusEnabled;
}

NS_INLINE void SLTLaunchAtLoginAppServiceSetEnabled(BOOL enabled) API_AVAILABLE(macos(13.0))
{
    Auto appService = SMAppService.mainAppService;
    
    if(enabled == YES)
    {
        NSError *error;
        [appService registerAndReturnError:&error];
        
        if(error != nil)
        {
            os_log_error(SLTApplicationSupportLog(), "Failed to register launch at login %{public}@", error.userInfo);
        }
    }
    else
    {
        NSError *error;
        [appService unregisterAndReturnError:&error];
        
        if(error != nil)
        {
            os_log_error(SLTApplicationSupportLog(), "Failed to unregister launch at login %{public}@", error.userInfo);
        }
    }
}

#pragma mark - User Default (Legacy)

static NSString * const SLTLauncherBundleIdentifier = @"io.github.mihirkohli-hash.StayLit.Launcher";
static NSString * const SLTLauncherStateUserDefaultsKey = @"io.github.mihirkohli-hash.StayLit.LaunchAtLogin";

NS_INLINE BOOL SLTLaunchAtLoginUserDefaultExists()
{
    Auto defaults = NSUserDefaults.standardUserDefaults;
    return [defaults objectForKey:SLTLauncherStateUserDefaultsKey] != nil;
}

NS_INLINE BOOL SLTLaunchAtLoginUserDefaultIsEnabled()
{
    Auto defaults = NSUserDefaults.standardUserDefaults;
    return [defaults boolForKey:SLTLauncherStateUserDefaultsKey];
}

NS_INLINE BOOL SLTLaunchAtLoginUserDefaultSetEnabled(BOOL enabled)
{
    Auto defaults = NSUserDefaults.standardUserDefaults;
    [defaults setBool:enabled forKey:SLTLauncherStateUserDefaultsKey];
}

NS_INLINE BOOL SLTLaunchAtLoginUserDefaultReset()
{
    Auto defaults = NSUserDefaults.standardUserDefaults;
    [defaults removeObjectForKey:SLTLauncherStateUserDefaultsKey];
}

#pragma mark - SMLoginItemSetEnabled (Legacy)

NS_INLINE BOOL SLTLaunchAtLoginLoginItemIsEnabled()
{
    BOOL enabled = SLTLaunchAtLoginUserDefaultIsEnabled();
    Boolean success = SMLoginItemSetEnabled((__bridge CFStringRef)SLTLauncherBundleIdentifier, (Boolean)enabled);
    if(success == false)
    {
        os_log_fault(SLTApplicationSupportLog(), "Failed to set login item to %{public}@", @(enabled));
    }
    return enabled;
}

NS_INLINE void SLTLaunchAtLoginLoginItemSetEnabled(BOOL enabled)
{
    Boolean success = SMLoginItemSetEnabled((__bridge CFStringRef)SLTLauncherBundleIdentifier, (Boolean)enabled);
    if(success == true)
    {
        SLTLaunchAtLoginUserDefaultSetEnabled(enabled);
    }
    else
    {
        os_log_fault(SLTApplicationSupportLog(), "Failed to set login item to %{public}@", @(enabled));
    }
}

@end

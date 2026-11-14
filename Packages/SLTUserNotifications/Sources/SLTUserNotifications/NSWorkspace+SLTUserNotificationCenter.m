//
//  NSWorkspace+SLTUserNotificationCenter.m
//  SLTUserNotifications
//
//

#import <SLTUserNotifications/NSWorkspace+SLTUserNotificationCenter.h>
#import <SLTCommon/SLTCommon.h>
#import <SLTUserNotifications/NSURL+SLTUserNotificationCenter.h>

@implementation NSWorkspace (SLTUserNotificationCenter)

- (void)slt_openNotificationSettingsWithCompletionHandler:(SLTOpenNotificationsCompletionHandler)completionHandler
{
    Auto prefURL = NSURL.slt_notificationSettingsURL;
    Auto config = [NSWorkspaceOpenConfiguration configuration];
    config.addsToRecentItems = NO;
    
    [self openApplicationAtURL:prefURL
                 configuration:config
             completionHandler:^(NSRunningApplication *app, NSError *error) {
        if(completionHandler != nil)
        {
            completionHandler(app, error);
        }
    }];
}

@end

//
//  NSURL+SLTUserNotificationCenter.m
//  SLTUserNotifications
//
//

#import <SLTUserNotifications/NSURL+SLTUserNotificationCenter.h>
#import <SLTCommon/SLTCommon.h>

@implementation NSURL (SLTUserNotificationCenter)

+ (NSURL *)slt_notificationSettingsURL
{
    return [self URLWithString:@"x-apple.systempreferences:com.apple.preference.notifications"];
}

@end

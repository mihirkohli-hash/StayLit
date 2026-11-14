//
//  NSURL+SLTUserNotificationCenter.h
//  SLTUserNotifications
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSURL (SLTUserNotificationCenter)
@property (class, nonatomic, readonly) NSURL *slt_notificationSettingsURL;
@end

NS_ASSUME_NONNULL_END

//
//  NSWorkspace+SLTUserNotificationCenter.h
//  SLTUserNotifications
//
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^SLTOpenNotificationsCompletionHandler)(NSRunningApplication *_Nullable,
                                                     NSError *_Nullable);

@interface NSWorkspace (SLTUserNotificationCenter)

/// Opens the notifications pane in System Settings.
/// @param completionHandler An optional completion handler, called on a private queue
- (void)slt_openNotificationSettingsWithCompletionHandler:(nullable SLTOpenNotificationsCompletionHandler)completionHandler API_AVAILABLE(macos(11.0));

@end

NS_ASSUME_NONNULL_END

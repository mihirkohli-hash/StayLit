//
//  SLTGeneralSettingsViewController.h
//  StayLit
//

#import <Cocoa/Cocoa.h>
#import <SLTUserNotifications/SLTUserNotifications.h>
#import "SLTSettingsContentViewController.h"

/// Shows "General" settings.
@interface SLTGeneralSettingsViewController : SLTSettingsContentViewController

- (IBAction)openNotificationSettings:(nullable id)sender API_AVAILABLE(macos(11.0));

@end

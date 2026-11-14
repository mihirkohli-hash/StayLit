//
//  SLTUpdateSettingsViewController.h
//  StayLit
//
//

#import <Cocoa/Cocoa.h>
#import "SLTAppUpdater.h"
#import "SLTSettingsContentViewController.h"

#if SLT_APP_UPDATER_ENABLED

NS_ASSUME_NONNULL_BEGIN

/// Shows "Update" settings and allows checking
/// for available app updates.
@interface SLTUpdateSettingsViewController : SLTSettingsContentViewController
@property (nonatomic, readonly) SLTAppUpdater *appUpdater;

- (IBAction)checkForUpdates:(id)sender;

@end

NS_ASSUME_NONNULL_END

#endif

//
//  SLTAdvancedSettingsViewController.h
//  StayLit
//
//

#import <Cocoa/Cocoa.h>
#import <SLTApplicationSupport/SLTApplicationSupport.h>
#import "SLTSettingsContentViewController.h"

/// Shows "Advanced" settings.
@interface SLTAdvancedSettingsViewController : SLTSettingsContentViewController <NSTableViewDataSource, NSTableViewDelegate>

/// A table view that lists individual settings
@property (weak, nonatomic, nullable) IBOutlet NSTableView *tableView;

/// Resets all advanced settings to their default values.
/// @param sender The sending control
- (IBAction)resetAdvancedSettings:(nullable id)sender;

@end

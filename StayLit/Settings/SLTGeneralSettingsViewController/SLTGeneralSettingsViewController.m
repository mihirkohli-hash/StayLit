//
//  SLTGeneralSettingsViewController.m
//  StayLit
//

#import "SLTGeneralSettingsViewController.h"
#import <SLTCommon/SLTCommon.h>

@interface SLTGeneralSettingsViewController ()
@property (weak, nonatomic) IBOutlet NSButton *startAtLoginCheckBoxButton;
@property (weak, nonatomic) IBOutlet NSButton *notificationSettingsButton;
@end

@implementation SLTGeneralSettingsViewController

+ (NSImage *)tabViewItemImage
{
    return [NSImage imageWithSystemSymbolName:@"gearshape" accessibilityDescription:nil];
}

+ (NSString *)preferredTitle
{
    return SLT_SETTINGS_L10N_GENERAL;
}

#pragma mark -

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Bind the start at login checkbox value to NSApplication
    [self.startAtLoginCheckBoxButton bind:@"value"
                                 toObject:NSApplication.sharedApplication
                              withKeyPath:@"slt_launchAtLoginEnabled"
                                  options:@{
                                      NSRaisesForNotApplicableKeysBindingOption: @YES,
                                      NSConditionallySetsEnabledBindingOption: @YES
                                  }
     ];
}

- (void)dealloc
{
    [self.startAtLoginCheckBoxButton unbind:@"value"];
}

- (void)openNotificationSettings:(id)sender
{
    Auto workspace = NSWorkspace.sharedWorkspace;
    [workspace slt_openNotificationSettingsWithCompletionHandler:nil];
}

@end

//
//  SLTUpdateSettingsViewController.m
//  StayLit
//

#import "SLTUpdateSettingsViewController.h"
#import <SLTCommon/SLTCommon.h>

#if SLT_APP_UPDATER_ENABLED

@implementation SLTUpdateSettingsViewController

+ (NSImage *)tabViewItemImage
{
    return [NSImage imageWithSystemSymbolName:@"network" accessibilityDescription:nil];
}

+ (NSString *)preferredTitle
{
    return SLT_SETTINGS_L10N_UPDATES;
}

- (BOOL)resizesView
{
    return NO;
}

#pragma mark -

- (SLTAppUpdater *)appUpdater
{
    return SLTAppUpdater.defaultAppUpdater;
}

- (void)checkForUpdates:(id)sender
{
    [self.appUpdater checkForUpdates:sender];
}

@end

#endif

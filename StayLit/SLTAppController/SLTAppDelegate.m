//
//  SLTAppDelegate.m
//  StayLit
//

#import "SLTAppDelegate.h"
#import <SLTCommon/SLTCommon.h>
#import "SLTAppUpdater.h"
#import "SLTSettingsWindow.h"
#import "SLTUpdateSettingsViewController.h"

@interface SLTAppDelegate ()
@property (weak, nonatomic, nullable) SLTSettingsWindow *settingsWindow;
@end

@implementation SLTAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
#if SLT_APP_UPDATER_ENABLED
    [SLTAppUpdater defaultAppUpdater];
#endif
    
    if(@available(macOS 13.0, *))
    {
        [NSApplication.sharedApplication slt_migrateLaunchAtLoginToAppServiceIfNeeded];
    }
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)hasVisibleWindows
{
    // Let's ignore all reopen requests in the first 5 seconds of the app's runtime.
    // Sometimes multiple reopen events are sent on app launch, which we don't want to handle.
    Auto launchDate = NSRunningApplication.currentApplication.launchDate;
    if(hasVisibleWindows == NO && [[launchDate dateByAddingTimeInterval:5.0f] compare:[NSDate date]] == NSOrderedAscending)
    {
        [self showSettingsWindow:sender];
    }
    return NO;
}

#pragma mark - Settings Window

- (void)showSettingsWindow:(id)sender
{
    if(@available(macOS 14.0, *))
    {
        [NSApplication.sharedApplication activate];
    }
    else
    {
        [NSApplication.sharedApplication activateIgnoringOtherApps:YES];
    }
    
    AutoVar settingsWindow = self.settingsWindow;
    if(settingsWindow == nil)
    {
        NSArray<NSTabViewItem *> *additionalTabViewItems;
#if SLT_APP_UPDATER_ENABLED
        additionalTabViewItems = @[SLTUpdateSettingsViewController.preferredTabViewItem];
#endif
        settingsWindow = [[SLTSettingsWindow alloc] initWithAdditionalTabViewItems:additionalTabViewItems];
        self.settingsWindow = settingsWindow;
    }
    [settingsWindow makeKeyAndOrderFront:sender];
}

@end

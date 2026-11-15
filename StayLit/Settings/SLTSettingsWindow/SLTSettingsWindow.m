//
//  SLTSettingsWindow.m
//  StayLit
//

#import "SLTSettingsWindow.h"
#import <SLTCommon/SLTCommon.h>
#import "SLTSettingsLocalizedStrings.h"
#import "SLTGeneralSettingsViewController.h"
#import "SLTDurationSettingsViewController.h"
#import "SLTBatterySettingsViewController.h"
#import "SLTAdvancedSettingsViewController.h"
#import "SLTAboutSettingsViewController.h"

@interface SLTSettingsWindow ()
@end

@implementation SLTSettingsWindow

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"
- (instancetype)init
{
    return [self initWithAdditionalTabViewItems:nil];
}

- (instancetype)initWithAdditionalTabViewItems:(NSArray<NSTabViewItem *> *)tabViewItems
{
    Auto mutableTabViewItems = [NSMutableArray<NSTabViewItem *> arrayWithArray:@[
        SLTGeneralSettingsViewController.preferredTabViewItem,
        SLTDurationSettingsViewController.preferredTabViewItem,
        SLTBatterySettingsViewController.preferredTabViewItem,
        SLTAdvancedSettingsViewController.preferredTabViewItem,
    ]];
    if(tabViewItems != nil)
    {
        [mutableTabViewItems addObjectsFromArray:tabViewItems];
    }
    [mutableTabViewItems addObject:SLTAboutSettingsViewController.preferredTabViewItem];
    
    Auto tabViewController = [NSTabViewController new];
    tabViewController.tabStyle = NSTabViewControllerTabStyleToolbar;
    tabViewController.transitionOptions = NSViewControllerTransitionNone;
    tabViewController.tabViewItems = [mutableTabViewItems copy];
    
    CGRect frame = CGRectMake(150.0f, 430.0f, 480.0f, 320.0f);
    NSWindowStyleMask styleMask = NSWindowStyleMaskTitled | NSWindowStyleMaskClosable;
    NSWindowCollectionBehavior behavior = NSWindowCollectionBehaviorManaged | NSWindowCollectionBehaviorParticipatesInCycle | NSWindowCollectionBehaviorFullScreenNone;
    
    self = [[self class] windowWithContentViewController:tabViewController];
    if(self)
    {
        self.styleMask = styleMask;
        self.collectionBehavior = behavior;
        self.title = SLT_SETTINGS_L10N_TITLE;
        
        [self setFrame:frame display:NO];
        self.frameAutosaveName = @"PreferencesWindow";
    }
    return self;
}
#pragma clang diagnostic pop

#pragma mark - NSResponder

- (void)keyDown:(NSEvent *)event
{
    if(event.type != NSEventTypeKeyDown) { return; }
    if((event.modifierFlags & NSEventModifierFlagCommand) == 0) { return; }
    
    if([event.characters isEqualToString:@"q"])
    {
        [NSApplication.sharedApplication terminate:self];
    }
    if([event.characters isEqualToString:@"w"])
    {
        [self close];
    }
}

@end

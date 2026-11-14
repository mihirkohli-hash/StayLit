//
//  SLTStatusItemController.m
//  SLTStatusItemUI
//
//

#import <SLTStatusItemUI/SLTStatusItemController.h>
#import <SLTCommon/SLTCommon.h>
#import <SLTStatusItemUI/SLTStatusItemImageProvider.h>
#import "SLTStatusItemUILocalizedStrings.h"

@interface SLTStatusItemController ()
@property (nonatomic, readwrite) NSStatusItem *systemStatusItem;
@property (nonatomic) SLTStatusItemAppearance currentAppearance;
@end

@implementation SLTStatusItemController

- (instancetype)init
{
    self = [super init];
    if(self)
    {
        [self configureStatusItem];

        // The icon color is a user default, so a change in Settings reaches the icon here.
        [NSNotificationCenter.defaultCenter addObserver:self
                                               selector:@selector(userDefaultsDidChange:)
                                                   name:NSUserDefaultsDidChangeNotification
                                                 object:nil];
    }
    return self;
}

- (void)dealloc
{
    [NSNotificationCenter.defaultCenter removeObserver:self name:NSUserDefaultsDidChangeNotification object:nil];
}

- (void)userDefaultsDidChange:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateButtonImage];
    });
}

#pragma mark - Configuration

- (void)configureStatusItem
{
    Auto statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    statusItem.highlightMode = ![NSUserDefaults standardUserDefaults].slt_menuBarIconHighlightDisabled;
    if([statusItem respondsToSelector:@selector(behavior)])
    {
        statusItem.behavior = NSStatusItemBehaviorTerminationOnRemoval;
    }
    if([statusItem respondsToSelector:@selector(isVisible)])
    {
        statusItem.visible = YES;
    }
    
    Auto button = statusItem.button;
    
    [button sendActionOn:NSEventMaskLeftMouseUp|NSEventMaskRightMouseUp];
    button.target = self;
    button.action = @selector(toggleStatus:);
    
#if DEBUG
    button.contentTintColor = NSColor.systemBlueColor;
    Auto log = SLTLogCreateWithCategory("StatusItemUI");
    os_log_debug(log, "Blue status bar item color is enabled for DEBUG builds.");
#endif
    
    self.systemStatusItem = statusItem;
    self.appearance = SLTStatusItemAppearanceInactive;
}

- (void)toggleStatus:(id)sender
{
    Auto delegate = self.delegate;
    Auto event = NSApplication.sharedApplication.currentEvent;
    
    if((event.modifierFlags & NSEventModifierFlagControl)   // ctrl click
       || (event.modifierFlags & NSEventModifierFlagOption) // alt click
       || (event.type == NSEventTypeRightMouseUp))          // right click
    {
        [self showMenuFromDataSource];
        return;
    }
    
    if([delegate respondsToSelector:@selector(statusItemControllerShouldPerformPrimaryAction:)])
    {
        [delegate statusItemControllerShouldPerformPrimaryAction:self];
    }
}

#pragma mark - Appearance

- (SLTStatusItemAppearance)appearance
{
    return self.currentAppearance;
}

- (void)setAppearance:(SLTStatusItemAppearance)appearance
{
    [self willChangeValueForKey:@"appearance"];

    self.currentAppearance = appearance;
    [self updateButtonImage];

    Auto button = self.systemStatusItem.button;
    if(appearance == SLTStatusItemAppearanceActive)
    {
        button.toolTip = SLT_L10N_CLICK_TO_ALLOW_SLEEP;
    }
    else
    {
        button.toolTip = SLT_L10N_CLICK_TO_PREVENT_SLEEP;
    }

    [self didChangeValueForKey:@"appearance"];
}

- (void)updateButtonImage
{
    Auto button = self.systemStatusItem.button;
    Auto imageProvider = SLTStatusItemImageProvider.currentProvider;
    Auto image = (self.currentAppearance == SLTStatusItemAppearanceActive) ? imageProvider.activeIconImage : imageProvider.inactiveIconImage;

    // The provider returns the same instance until the color changes, so most calls do nothing.
    if(button.image != image)
    {
        button.image = image;
    }
}

#pragma mark - Menu

- (void)showMenuFromDataSource
{
    Auto dataSource = self.dataSource;
    if([dataSource respondsToSelector:@selector(menuForStatusItemController:)])
    {
        Auto menu = [dataSource menuForStatusItemController:self];
        if(menu != nil)
        {
            [self.systemStatusItem popUpStatusItemMenu:menu];
        }
    }
}

@end

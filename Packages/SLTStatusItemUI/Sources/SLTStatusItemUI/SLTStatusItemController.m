//
//  SLTStatusItemController.m
//  SLTStatusItemUI
//

#import <SLTStatusItemUI/SLTStatusItemController.h>
#import <SLTCommon/SLTCommon.h>
#import <SLTStatusItemUI/SLTStatusItemImageProvider.h>
#import <QuartzCore/QuartzCore.h>
#import "SLTStatusItemController+Private.h"
#import "SLTStatusItemImageProvider/NSImage+SLTStatusItemImage.h"
#import "SLTStatusItemUILocalizedStrings.h"

NSString * const SLTStatusItemPulseAnimationKey = @"StayLitPulse";

@interface SLTStatusItemController ()
@property (nonatomic, readwrite) NSStatusItem *systemStatusItem;
@property (nonatomic) SLTStatusItemAppearance currentAppearance;
@property (nonatomic) NSUInteger pulseFrameIndex;
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

        // Nobody sees the menu bar while the displays sleep, for example with the lid closed on battery.
        // The pulse stops then, so it does not wake the Mac 20 times a second for nothing.
        Auto workspaceCenter = NSWorkspace.sharedWorkspace.notificationCenter;
        [workspaceCenter addObserver:self selector:@selector(screensDidSleep:) name:NSWorkspaceScreensDidSleepNotification object:nil];
        [workspaceCenter addObserver:self selector:@selector(screensDidWake:) name:NSWorkspaceScreensDidWakeNotification object:nil];

        // Reduce Motion is a system setting, so the pulse must follow it live.
        [NSWorkspace.sharedWorkspace.notificationCenter addObserver:self
                                                           selector:@selector(userDefaultsDidChange:)
                                                               name:NSWorkspaceAccessibilityDisplayOptionsDidChangeNotification
                                                             object:nil];
    }
    return self;
}

- (void)dealloc
{
    [self.pulseTimer invalidate];
    [NSNotificationCenter.defaultCenter removeObserver:self name:NSUserDefaultsDidChangeNotification object:nil];
    [NSWorkspace.sharedWorkspace.notificationCenter removeObserver:self name:NSWorkspaceAccessibilityDisplayOptionsDidChangeNotification object:nil];
    [NSWorkspace.sharedWorkspace.notificationCenter removeObserver:self name:NSWorkspaceScreensDidSleepNotification object:nil];
    [NSWorkspace.sharedWorkspace.notificationCenter removeObserver:self name:NSWorkspaceScreensDidWakeNotification object:nil];
}

- (void)screensDidSleep:(NSNotification *)notification
{
    self.screensAsleep = YES;
    [self updateButtonPulse];
}

- (void)screensDidWake:(NSNotification *)notification
{
    self.screensAsleep = NO;
    [self updateButtonPulse];
}

- (void)userDefaultsDidChange:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateButtonImage];
        [self updateButtonPulse];
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
    [self updateButtonPulse];

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

    // While the screen pulses, the timer sets the frames, so do not fight it.
    if(self.pulseTimer != nil)
    {
        return;
    }

    // The provider returns the same instance until the color changes, so most calls do nothing.
    if(button.image != image)
    {
        button.image = image;
    }
}

#pragma mark - Pulse

+ (BOOL)shouldPulseForAppearance:(SLTStatusItemAppearance)appearance
                   pulseDisabled:(BOOL)pulseDisabled
                    reduceMotion:(BOOL)reduceMotion
                    screensAsleep:(BOOL)screensAsleep
{
    return appearance == SLTStatusItemAppearanceActive && !pulseDisabled && !reduceMotion && !screensAsleep;
}

+ (void)setPulsing:(BOOL)pulsing forView:(NSView *)view duration:(NSTimeInterval)duration
{
    view.wantsLayer = YES;
    Auto layer = view.layer;

    if(!pulsing)
    {
        [layer removeAnimationForKey:SLTStatusItemPulseAnimationKey];
        return;
    }

    // The fade reverses by itself, so each direction takes half of the cycle.
    Auto halfCycle = duration / 2.0;
    Auto runningAnimation = [layer animationForKey:SLTStatusItemPulseAnimationKey];
    if(runningAnimation != nil && runningAnimation.duration == halfCycle)
    {
        return;
    }

    // Core Animation runs this in the window server, so the app needs no timer for it.
    Auto animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.fromValue = @1.0;
    animation.toValue = @0.35;
    animation.duration = halfCycle;
    animation.autoreverses = YES;
    animation.repeatCount = HUGE_VALF;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [layer addAnimation:animation forKey:SLTStatusItemPulseAnimationKey];
}

- (BOOL)isReduceMotionEnabled
{
    return self.reduceMotionOverride != nil ? self.reduceMotionOverride.boolValue : NSWorkspace.sharedWorkspace.accessibilityDisplayShouldReduceMotion;
}

- (void)updateButtonPulse
{
    Auto button = self.systemStatusItem.button;
    if(button == nil)
    {
        return;
    }

    Auto shouldPulse = [SLTStatusItemController shouldPulseForAppearance:self.currentAppearance
                                                           pulseDisabled:NSUserDefaults.standardUserDefaults.slt_menuBarIconPulseDisabled
                                                            reduceMotion:[self isReduceMotionEnabled]
                                                           screensAsleep:self.screensAsleep];

    Auto duration = NSUserDefaults.standardUserDefaults.slt_menuBarIconPulseDuration;

    // The built-in icon pulses its screen. A custom icon has no separate screen, so it fades as a whole.
    Auto canPulseScreen = [SLTStatusItemImageProvider.currentProvider pulseFramesForDuration:duration] != nil;
    if(shouldPulse && canPulseScreen)
    {
        [SLTStatusItemController setPulsing:NO forView:button duration:duration];
        [self startScreenPulseWithDuration:duration];
    }
    else
    {
        [self stopScreenPulse];
        [SLTStatusItemController setPulsing:shouldPulse forView:button duration:duration];
    }
}

- (void)startScreenPulseWithDuration:(NSTimeInterval)duration
{
    // One cycle shows every frame once, so a frame lasts one frame's share of the duration.
    Auto frameCount = SLTStatusItemPulseFrameCountForDuration(duration);
    Auto interval = duration / (NSTimeInterval)frameCount;

    if(self.pulseTimer != nil)
    {
        // The same step keeps running. Frames are read on every tick, so a new duration takes effect at once.
        // Only a different step needs a new timer.
        if(fabs(self.pulseTimer.timeInterval - interval) < 0.0001)
        {
            return;
        }
        [self.pulseTimer invalidate];
        self.pulseTimer = nil;
    }

    AutoWeak weakSelf = self;
    Auto timer = [NSTimer timerWithTimeInterval:interval repeats:YES block:^(NSTimer *timer) {
        [weakSelf showNextPulseFrame];
    }];
    timer.tolerance = interval * 0.25;

    // Common modes keep the pulse running while a menu is open.
    [NSRunLoop.mainRunLoop addTimer:timer forMode:NSRunLoopCommonModes];
    self.pulseTimer = timer;
    [self showNextPulseFrame];
}

- (void)stopScreenPulse
{
    if(self.pulseTimer == nil)
    {
        return;
    }

    [self.pulseTimer invalidate];
    self.pulseTimer = nil;
    self.pulseFrameIndex = 0;
    [self updateButtonImage];
}

- (void)showNextPulseFrame
{
    Auto frames = [SLTStatusItemImageProvider.currentProvider pulseFramesForDuration:NSUserDefaults.standardUserDefaults.slt_menuBarIconPulseDuration];
    if(frames.count == 0)
    {
        return;
    }

    self.systemStatusItem.button.image = frames[self.pulseFrameIndex % frames.count];
    self.pulseFrameIndex = (self.pulseFrameIndex + 1) % frames.count;
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

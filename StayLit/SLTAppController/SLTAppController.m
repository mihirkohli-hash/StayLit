//
//  SLTAppController.m
//  StayLit
//

#import "SLTAppController.h"
#import <SLTCommon/SLTCommon.h>
#import "SLTLocalizedStrings.h"
#import "SLTMainMenu.h"
#import "SLTBatteryCapacityThreshold.h"
#import "SLTActivationDurationsMenuController.h"
#import "SLTActivationUserNotification.h"

// Deprecated!
#define SLT_MINUTES(m) (m * 60.0f)
#define SLT_HOURS(h) (h * 3600.0f)

@interface SLTAppController () <SLTStatusItemControllerDataSource, SLTStatusItemControllerDelegate, SLTActivationDurationsMenuControllerDelegate, SLTSleepWakeTimerDelegate>
@property (nonatomic, readwrite) SLTSleepWakeTimer *sleepWakeTimer;
@property (nonatomic) BOOL didOfferClosedLidPermission;
@property (nonatomic, readwrite) SLTStatusItemController *statusItemController;
@property (nonatomic) SLTActivationDurationsMenuController *menuController;

@property (nonatomic) NSTimeInterval workspaceScheduledTimeInterval;

// Battery Status
@property (nonatomic, direct, getter=isBatteryOverrideEnabled) BOOL batteryOverrideEnabled;

// Menu
@property (nonatomic) NSMenu *menu;
@end

@implementation SLTAppController

#pragma mark - Life Cycle

- (instancetype)init
{
    self = [super init];
    if(self)
    {
        // The Settings drop-down binds to this key. Without a registered value it would
        // show no selection until the user picks one.
        [NSUserDefaults.standardUserDefaults registerDefaults:@{
            SLTUserDefaultsKeyMenuBarIconColor: @(SLTMenuBarIconColorWhite),
            SLTUserDefaultsKeyMenuBarIconPulseDurationMilliseconds: @((NSInteger)(SLTDefaultMenuBarIconPulseDuration * 1000))
        }];

        [self configureStatusItemController];
        [self configureSleepWakeTimer];
        [self configureEventHandler];
        [self configureUserNotificationCenter];
        [self configureMainMenu];

        Auto center = NSNotificationCenter.defaultCenter;
        [center addObserver:self
                   selector:@selector(applicationWillFinishLaunching:)
                       name:NSApplicationWillFinishLaunchingNotification
                     object:nil];
        [center addObserver:self
                   selector:@selector(applicationDidChangeScreenParameters:)
                       name:NSApplicationDidChangeScreenParametersNotification
                     object:nil];
        [center addObserver:self
                   selector:@selector(batteryCapacityThresholdDidChange:)
                       name:kSLTBatteryCapacityThresholdDidChangeNotification
                     object:nil];
        
        [self registerForWorkspaceSessionNotifications];
    }
    return self;
}

- (void)dealloc
{
    Auto center = NSNotificationCenter.defaultCenter;
    [center removeObserver:self name:NSApplicationDidFinishLaunchingNotification object:nil];
    [center removeObserver:self name:NSApplicationDidChangeScreenParametersNotification object:nil];
    [center removeObserver:self name:kSLTBatteryCapacityThresholdDidChangeNotification object:nil];
    
    [self unregisterFromWorkspaceSessionNotifications];
}

#pragma mark - Main Menu

- (void)configureMainMenu
{
    Auto menuController = [SLTActivationDurationsMenuController new];
    menuController.delegate = self;
    self.menuController = menuController;
    
    self.menu = SLTCreateMainMenuWithActivationDurationsSubMenu(menuController.menu);
}

#pragma mark - Status Item Controller

- (void)configureStatusItemController
{
    Auto statusItemController = [SLTStatusItemController new];
    statusItemController.dataSource = self;
    statusItemController.delegate = self;
    self.statusItemController = statusItemController;
}

#pragma mark - Sleep Wake Timer

- (void)configureSleepWakeTimer
{
    Auto sleepWakeTimer = [SLTSleepWakeTimer new];
    sleepWakeTimer.delegate = self;
    self.sleepWakeTimer = sleepWakeTimer;

    [SLTClosedLidSleepGuard resetIfLeftEnabledByPreviousRun];
    
    // Activate on launch if needed
    if([NSUserDefaults.standardUserDefaults slt_isActivatedOnLaunch])
    {
        [self activateTimer];
    }
}

- (void)activateTimer
{
    [self activateTimerWithTimeInterval:self.defaultTimeInterval];
}

- (void)activateTimerWithTimeInterval:(NSTimeInterval)timeInterval
{
    // Do not allow negative time intervals
    if(timeInterval < 0)
    {
        return;
    }

    Auto defaults = NSUserDefaults.standardUserDefaults;
    
    Auto timerCompletion = ^(BOOL cancelled) {
        // Post deactivation notification
        Auto notification = [[SLTActivationUserNotification alloc] initWithFireDate:nil activating:NO];
        [SLTUserNotificationCenter.sharedCenter postNotification:notification];

        // Quit on timer expiration
        if(cancelled == NO && [defaults slt_isQuitOnTimerExpirationEnabled])
        {
            [NSApplication.sharedApplication terminate:nil];
        }
    };
    [self offerClosedLidPermissionIfNeeded];
    [self.sleepWakeTimer scheduleWithTimeInterval:timeInterval completion:timerCompletion];

    // Post activation notification
    Auto fireDate = self.sleepWakeTimer.fireDate;
    Auto notification = [[SLTActivationUserNotification alloc] initWithFireDate:fireDate activating:YES];
    [SLTUserNotificationCenter.sharedCenter postNotification:notification];
}

// Keeping a closed lid awake on battery needs a one-time administrator permission.
// The offer appears once per launch, and only when the Mac runs on battery.
- (void)offerClosedLidPermissionIfNeeded
{
    if(![NSUserDefaults.standardUserDefaults slt_isKeepAwakeOnLidCloseEnabled]
       || self.didOfferClosedLidPermission
       || !SLTClosedLidSleepGuard.isSupported
       || !SLTClosedLidSleepGuard.isOnBatteryPower
       || SLTClosedLidSleepGuard.isAuthorized)
    {
        return;
    }
    self.didOfferClosedLidPermission = YES;

    Auto alert = [NSAlert new];
    alert.messageText = SLT_L10N_LID_PERMISSION_TITLE;
    alert.informativeText = SLT_L10N_LID_PERMISSION_BODY;
    [alert addButtonWithTitle:SLT_L10N_LID_PERMISSION_ALLOW];
    [alert addButtonWithTitle:SLT_L10N_LID_PERMISSION_NOT_NOW];
    if([alert runModal] != NSAlertFirstButtonReturn)
    {
        return;
    }

    NSError *error = nil;
    if(![SLTClosedLidSleepGuard installAuthorizationWithError:&error])
    {
        Auto failure = [NSAlert new];
        failure.messageText = SLT_L10N_LID_PERMISSION_FAILED_TITLE;
        failure.informativeText = error.localizedDescription;
        [failure runModal];
    }
}

- (void)terminateTimer
{
    [self disableBatteryOverride];

    if([self.sleepWakeTimer isScheduled])
    {
        [self.sleepWakeTimer invalidate];
    }
}

#pragma mark - Default Time Interval

- (NSTimeInterval)defaultTimeInterval
{
    return NSUserDefaults.standardUserDefaults.slt_defaultTimeInterval;
}

#pragma mark - Activate on Launch

- (IBAction)toggleActivateOnLaunch:(id)sender
{
    Auto defaults = NSUserDefaults.standardUserDefaults;
    defaults.slt_activateOnLaunch = ![defaults slt_isActivatedOnLaunch];
    [defaults synchronize];
}

#pragma mark - User Notification Center

- (void)configureUserNotificationCenter
{
    Auto center = SLTUserNotificationCenter.sharedCenter;
    [center requestAuthorizationIfUndetermined];
    [center clearAllDeliveredNotifications];
}

#pragma mark - Device Power Monitoring

- (void)checkAndEnableBatteryOverride
{
    Auto batteryMonitor = SLTDevice.currentDevice.batteryMonitor;
    CGFloat currentCapacity = batteryMonitor.currentCapacity;
    CGFloat threshold = NSUserDefaults.standardUserDefaults.slt_batteryCapacityThreshold;

    self.batteryOverrideEnabled = (currentCapacity <= threshold);
}

- (void)disableBatteryOverride
{
    self.batteryOverrideEnabled = NO;
}

- (void)deviceParameterDidChange:(NSNotification *)notification
{
    NSParameterAssert(notification);
    
    Auto device = (SLTDevice *)notification.object;
    Auto defaults = NSUserDefaults.standardUserDefaults;
    
    Auto userInfo = notification.userInfo;
    Auto deviceParameter = (SLTDeviceParameter)userInfo[SLTDeviceParameterKey];
    if([deviceParameter isEqualToString:SLTDeviceParameterBattery])
    {
        if([defaults slt_isBatteryCapacityThresholdEnabled] == NO) { return; }
        
        CGFloat threshold = defaults.slt_batteryCapacityThreshold;
        Auto capacity = device.batteryMonitor.currentCapacity;
        if([self.sleepWakeTimer isScheduled] && (capacity <= threshold) && ![self isBatteryOverrideEnabled])
        {
            [self terminateTimer];
        }
    }
    else if([deviceParameter isEqualToString:SLTDeviceParameterLowPowerMode])
    {
        if([defaults slt_isLowPowerModeMonitoringEnabled] == NO) { return; }
        
        if([device.lowPowerModeMonitor isLowPowerModeEnabled] && [self.sleepWakeTimer isScheduled])
        {
            [self terminateTimer];
        }
    }
}

- (void)enableDevicePowerMonitoring
{
    Auto device = SLTDevice.currentDevice;
    Auto center = NSNotificationCenter.defaultCenter;
    Auto defaults = NSUserDefaults.standardUserDefaults;
    
    // Check battery overrides and register for capacity changes.
    [self checkAndEnableBatteryOverride];
    
    [center addObserver:self
               selector:@selector(deviceParameterDidChange:)
                   name:SLTDeviceParameterDidChangeNotification
                 object:device];
    
    if([defaults slt_isBatteryCapacityThresholdEnabled])
    {
        device.batteryMonitoringEnabled = YES;
    }
    if([defaults slt_isLowPowerModeMonitoringEnabled])
    {
        device.lowPowerModeMonitoringEnabled = YES;
    }
}

- (void)disableDevicePowerMonitoring
{
    Auto device = SLTDevice.currentDevice;
    Auto center = NSNotificationCenter.defaultCenter;
    
    [center removeObserver:self
                      name:SLTDeviceParameterDidChangeNotification
                    object:device];
    
    device.batteryMonitoringEnabled = NO;
    device.lowPowerModeMonitoringEnabled = NO;
}

#pragma mark - Battery Capacity Threshold Changes

- (void)batteryCapacityThresholdDidChange:(NSNotification *)notification
{
    if([self.sleepWakeTimer isScheduled])
    {
        [self terminateTimer];
    }
}

#pragma mark - Workspace Session Handling

- (void)registerForWorkspaceSessionNotifications
{
    Auto workspaceCenter = NSWorkspace.sharedWorkspace.notificationCenter;
    [workspaceCenter addObserver:self
                        selector:@selector(workspaceSessionDidBecomeActive:)
                            name:NSWorkspaceSessionDidBecomeActiveNotification
                          object:nil];
    [workspaceCenter addObserver:self
                        selector:@selector(workspaceSessionDidResignActive:)
                            name:NSWorkspaceSessionDidResignActiveNotification
                          object:nil];
}

- (void)unregisterFromWorkspaceSessionNotifications
{
    Auto workspaceCenter = NSWorkspace.sharedWorkspace.notificationCenter;
    [workspaceCenter removeObserver:self
                               name:NSWorkspaceSessionDidBecomeActiveNotification
                             object:nil];
    [workspaceCenter removeObserver:self
                               name:NSWorkspaceSessionDidResignActiveNotification
                             object:nil];
}

- (void)workspaceSessionDidBecomeActive:(NSNotification *)notification
{
    Auto defaults = NSUserDefaults.standardUserDefaults;
    if([defaults slt_isDeactivateOnUserSwitchEnabled] && self.workspaceScheduledTimeInterval >= 0)
    {
        [self activateTimerWithTimeInterval:self.workspaceScheduledTimeInterval];
        self.workspaceScheduledTimeInterval = -1;
    }
}

- (void)workspaceSessionDidResignActive:(NSNotification *)notification
{
    Auto defaults = NSUserDefaults.standardUserDefaults;
    if([defaults slt_isDeactivateOnUserSwitchEnabled] && [self.sleepWakeTimer isScheduled])
    {
        self.workspaceScheduledTimeInterval = self.sleepWakeTimer.scheduledTimeInterval;
        [self terminateTimer];
    }
}

#pragma mark - Event Handling

- (void)applicationWillFinishLaunching:(NSNotification *)notification
{
    [SLTEventHandler.defaultHandler registerAsDefaultEventHandler];
}

- (void)configureEventHandler
{
    Auto eventHandler = SLTEventHandler.defaultHandler;
    
    AutoWeak weakSelf = self;
    [eventHandler registerActionNamed:@"activate" block:^(SLTEvent *event) {
        [weakSelf handleActivateActionForEvent:event];
    }];
    
    [eventHandler registerActionNamed:@"deactivate" block:^(SLTEvent *event) {
        Auto strongSelf = weakSelf;
        [strongSelf terminateTimer];
        strongSelf.statusItemController.appearance = SLTStatusItemAppearanceInactive;
    }];
    
    [eventHandler registerActionNamed:@"toggle" block:^(SLTEvent *event) {
        Auto strongSelf = weakSelf;
        [strongSelf statusItemControllerShouldPerformPrimaryAction:strongSelf.statusItemController];
    }];
}

- (void)handleActivateActionForEvent:(SLTEvent *)event
{
    Auto parameters = event.arguments;
    NSString *seconds = parameters[@"seconds"];
    NSString *minutes = parameters[@"minutes"];
    NSString *hours = parameters[@"hours"];

    [self terminateTimer];
    
    Auto statusItemController = self.statusItemController;

    // Activate indefinitely if there are no parameters
    if(parameters == nil || parameters.count == 0)
    {
        [self activateTimer];
        statusItemController.appearance = SLTStatusItemAppearanceActive;
    }
    else if(seconds != nil)
    {
        [self activateTimerWithTimeInterval:(NSTimeInterval)ceil(seconds.doubleValue)];
        statusItemController.appearance = SLTStatusItemAppearanceActive;
    }
    else if(minutes != nil)
    {
        [self activateTimerWithTimeInterval:(NSTimeInterval)SLT_MINUTES(ceil(minutes.doubleValue))];
        statusItemController.appearance = SLTStatusItemAppearanceActive;
    }
    else if(hours != nil)
    {
        [self activateTimerWithTimeInterval:(NSTimeInterval)SLT_HOURS(ceil(hours.doubleValue))];
        statusItemController.appearance = SLTStatusItemAppearanceActive;
    }
    else
    {
        statusItemController.appearance = SLTStatusItemAppearanceInactive;
    }
}

#pragma mark - Internal / External Screen Parameter Changes

- (void)applicationDidChangeScreenParameters:(NSNotification *)notification
{
    if([NSUserDefaults.standardUserDefaults slt_isActivateOnExternalDisplayConnectedEnabled] == NO)
    {
        return;
    }
    
    NSUInteger numberOfExternalScreens = SLTDisplayParametersGetNumberOfExternalDisplays();
    Auto sleepWakeTimer = self.sleepWakeTimer;
    
    if(numberOfExternalScreens == 0)
    {
        // Only the main screen is connected, deactivate!
        if([sleepWakeTimer isScheduled])
        {
            [self terminateTimer];
        }
    }
    else
    {
        // The main screen and at least one external screen, activate!
        if([sleepWakeTimer isScheduled] == NO)
        {
            [self activateTimer];
        }
    }
}

#pragma mark - SLTStatusItemControllerDataSource

- (NSMenu *)menuForStatusItemController:(SLTStatusItemController *)controller
{
    return self.menu;
}

#pragma mark - SLTStatusItemControllerDelegate

- (void)statusItemControllerShouldPerformPrimaryAction:(SLTStatusItemController *)controller
{
    if([self.sleepWakeTimer isScheduled])
    {
        [self terminateTimer];
    }
    else
    {
        [self activateTimer];
    }
}

#pragma mark - SLTActivationDurationsMenuControllerDelegate

- (SLTActivationDuration *)currentActivationDuration
{
    Auto sleepWakeTimer = self.sleepWakeTimer;
    if(![sleepWakeTimer isScheduled])
    {
        return nil;
    }

    NSTimeInterval seconds = sleepWakeTimer.scheduledTimeInterval;
    return [[SLTActivationDuration alloc] initWithSeconds:seconds];
}

- (void)activationDurationsMenuController:(SLTActivationDurationsMenuController *)controller didSelectActivationDuration:(SLTActivationDuration *)activationDuration
{
    [self terminateTimer];

    AutoWeak weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSTimeInterval seconds = activationDuration.seconds;
        [weakSelf activateTimerWithTimeInterval:seconds];
    });
}

- (NSDate *)fireDateForMenuController:(SLTActivationDurationsMenuController *)controller
{
    return self.sleepWakeTimer.fireDate;
}

#pragma mark - SLTSleepWakeTimerDelegate

- (void)sleepWakeTimer:(SLTSleepWakeTimer *)sleepWakeTimer willActivateWithTimeInterval:(NSTimeInterval)timeInterval
{
    // Update the status item
    self.statusItemController.appearance = SLTStatusItemAppearanceActive;
    
    [self enableDevicePowerMonitoring];
}

- (void)sleepWakeTimerDidDeactivate:(SLTSleepWakeTimer *)sleepWakeTimer
{
    // Update the status item
    self.statusItemController.appearance = SLTStatusItemAppearanceInactive;
    
    [self disableDevicePowerMonitoring];
}

@end

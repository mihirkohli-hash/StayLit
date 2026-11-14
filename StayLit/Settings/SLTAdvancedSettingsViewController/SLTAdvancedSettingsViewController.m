//
//  SLTAdvancedSettingsViewController.m
//  StayLit
//
//

#import "SLTAdvancedSettingsViewController.h"
#import <SLTCommon/SLTCommon.h>
#import "SLTLocalizedStrings.h"
#import "SLTUserDefaultsSetting.h"
#import "SLTBatteryCapacityThreshold.h"

@interface SLTAdvancedSettingsViewController ()
@property (nonatomic) NSArray<SLTUserDefaultsSetting *> *settings;
@property (nonatomic, readwrite) BOOL batteryStatusAvailable;
@property (weak, nonatomic) IBOutlet NSUserDefaultsController *defaultsController;
@end

@implementation SLTAdvancedSettingsViewController

+ (NSImage *)tabViewItemImage
{
    return [NSImage imageWithSystemSymbolName:@"gearshape.2" accessibilityDescription:nil];
}

+ (NSString *)preferredTitle
{
    return SLT_SETTINGS_L10N_ADVANCED;
}

- (BOOL)resizesView
{
    return NO;
}

#pragma mark -

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self configureAdvancedSettings];
}

#pragma mark - Configuration

- (void)configureAdvancedSettings
{
    Auto settings = [NSMutableArray<SLTUserDefaultsSetting *> new];
    
    [settings addObject:[[SLTUserDefaultsSetting alloc] initWithTitle:SLT_L10N_QUIT_ON_TIMER_EXPIRATION key:SLTUserDefaultsKeyIsQuitOnTimerExpirationEnabled]];
    [settings addObject:[[SLTUserDefaultsSetting alloc] initWithTitle:SLT_L10N_ALLOW_DISPLAY_SLEEP key:SLTUserDefaultsKeyAllowDisplaySleep]];
    [settings addObject:[[SLTUserDefaultsSetting alloc] initWithTitle:SLT_L10N_KEEP_AWAKE_ON_LID_CLOSE key:SLTUserDefaultsKeyKeepAwakeOnLidCloseEnabled]];
    [settings addObject:[[SLTUserDefaultsSetting alloc] initWithTitle:SLT_L10N_ACTIVATE_ON_EXTERNAL_DISPLAY key:SLTUserDefaultsKeyActivateOnExternalDisplayConnectedEnabled]];
    [settings addObject:[[SLTUserDefaultsSetting alloc] initWithTitle:SLT_L10N_DEACTIVATE_ON_USER_SWITCH key:SLTUserDefaultsKeyDeactivateOnUserSwitchEnabled]];
    
    self.settings = [settings copy];
}

#pragma mark - Reset Advanced Settings

- (IBAction)resetAdvancedSettings:(id)sender
{
    for(SLTUserDefaultsSetting *setting in self.settings)
    {
        [setting reset];
    }
    [NSUserDefaults.standardUserDefaults synchronize];
    [self.tableView reloadData];
}

#pragma mark - Table View Delegate & Data Source

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return (NSInteger)self.settings.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    return self.settings[(NSUInteger)row];
}

@end

//
//  SLTLocalizedStrings.c
//  StayLit
//

#import <Foundation/Foundation.h>

#pragma mark - Generic

#define SLT_L10N_OK NSLocalizedString(@"OK", @"OK")
#define SLT_L10N_CANCEL NSLocalizedString(@"Cancel", @"Cancel")
#define SLT_L10N_DEFAULT NSLocalizedString(@"Default", @"Default")

#pragma mark - Main Menu

#define SLT_L10N_ACTIVATE_FOR_DURATION NSLocalizedString(@"Activate for Duration", @"Activate for Duration")
#define SLT_L10N_SETTINGS_ELLIPSIS NSLocalizedString(@"Settings…", @"Settings…")
#define SLT_L10N_QUIT NSLocalizedString(@"Quit", @"Quit")

#pragma mark -

#define SLT_L10N_IS_DEFAULT_SUFFIX NSLocalizedString(@"(Default)", @"(Default)")

#define SLT_L10N_DURATION_ALREADY_ADDED NSLocalizedString(@"This duration has already been added.", @"This duration has already been added.")

#define SLT_L10N_DURATION_INVALID_INPUT NSLocalizedString(@"The entered duration is invalid. Please try again.", @"The entered duration is invalid. Please try again.")

#define SLT_L10N_INDEFINITELY NSLocalizedString(@"Indefinitely", @"Indefinitely")

#define SLT_L10N_VERSION NSLocalizedString(@"Version", @"Version")

#pragma mark - Notifications

#define SLT_L10N_PREVENTING_SLEEP_INDEFINITELY_TITLE NSLocalizedString(@"Preventing Sleep", @"Preventing Sleep")

#define SLT_L10N_PREVENTING_SLEEP_INDEFINITELY_BODY_TEXT NSLocalizedString(@"You can still manually enable sleep mode for your Mac.", @"You can still manually enable sleep mode for your Mac.")

#define SLT_L10N_FORMAT_PREVENTING_SLEEP_FOR_TIME_TITLE NSLocalizedString(@"Preventing Sleep for %@", @"Preventing Sleep for %@")
#define SLT_L10N_PREVENTING_SLEEP_FOR_TIME_TITLE(_str) [NSString stringWithFormat:SLT_L10N_FORMAT_PREVENTING_SLEEP_FOR_TIME_TITLE, (NSString *)(_str)]

#define SLT_L10N_PREVENTING_SLEEP_FOR_TIME_BODY_TEXT NSLocalizedString(@"Afterwards your Mac will automatically go to sleep again when unused.", @"Afterwards your Mac will automatically go to sleep again when unused.")

#define SLT_L10N_ALLOWING_SLEEP_TITLE NSLocalizedString(@"Allowing Sleep", @"Allowing Sleep")

#define SLT_L10N_ALLOWING_SLEEP_BODY_TEXT NSLocalizedString(@"Your Mac will automatically go to sleep when unused.", @"Your Mac will automatically go to sleep when unused.")

#pragma mark - Settings

#define SLT_L10N_QUIT_ON_TIMER_EXPIRATION NSLocalizedString(@"Quit when activation duration is over", @"Quit when activation duration is over")
#define SLT_L10N_ALLOW_DISPLAY_SLEEP NSLocalizedString(@"Allow the display to sleep", @"Allow the display to sleep")
#define SLT_L10N_KEEP_AWAKE_ON_LID_CLOSE NSLocalizedString(@"Stay awake when the lid is closed", @"Stay awake when the lid is closed")
#define SLT_L10N_LID_PERMISSION_TITLE NSLocalizedString(@"Keep your Mac awake on battery?", @"Keep your Mac awake on battery?")
#define SLT_L10N_LID_PERMISSION_BODY NSLocalizedString(@"StayLit can keep your Mac awake with the lid closed, also on battery. It asks for your administrator password once, to allow only the two commands that turn this setting on and off. A closed Mac can get hot and drain its battery, so do not leave it in a bag.", @"StayLit can keep your Mac awake with the lid closed, also on battery. It asks for your administrator password once, to allow only the two commands that turn this setting on and off. A closed Mac can get hot and drain its battery, so do not leave it in a bag.")
#define SLT_L10N_LID_PERMISSION_ALLOW NSLocalizedString(@"Allow…", @"Allow…")
#define SLT_L10N_LID_PERMISSION_NOT_NOW NSLocalizedString(@"Not Now", @"Not Now")
#define SLT_L10N_LID_PERMISSION_FAILED_TITLE NSLocalizedString(@"The permission was not installed", @"The permission was not installed")
#define SLT_L10N_DISABLE_ICON_PULSE NSLocalizedString(@"Do not pulse the menu bar icon while active", @"Do not pulse the menu bar icon while active")
#define SLT_L10N_ACTIVATE_ON_EXTERNAL_DISPLAY NSLocalizedString(@"Activate when an external display is connected", @"Activate when an external display is connected")
#define SLT_L10N_DEACTIVATE_ON_USER_SWITCH NSLocalizedString(@"Deactivate when switched to another user account", @"Deactivate when switched to another user account")
#define SLT_L10N_DURATIONS_ALERT_REALLY_RESET_TITLE NSLocalizedString(@"Reset Activation Durations", @"Reset Activation Durations")
#define SLT_L10N_DURATIONS_ALERT_REALLY_RESET_MESSAGE NSLocalizedString(@"Do you really want to reset the activation durations to the default values?", @"Do you really want to reset the activation durations to the default values?")

#define SLT_L10N_SET_DEFAULT_ACTIVATION_DURATION(_str) [NSString stringWithFormat:NSLocalizedString(@"Set Default: %@", @"Set Default: %@"), (NSString *)(_str)]

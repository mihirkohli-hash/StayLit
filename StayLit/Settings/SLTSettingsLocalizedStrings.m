//
//  SLTSettingsLocalizedStrings.m
//  StayLit
//
//

#import <Foundation/Foundation.h>

#define SLT_SETTINGS_LOCALIZED_STRING(__key, __comment) \
    NSLocalizedStringFromTableInBundle( \
    __key, \
    @"SLTSettings", \
    NSBundle.mainBundle, \
    __comment)

#define SLT_SETTINGS_L10N_TITLE SLT_SETTINGS_LOCALIZED_STRING(@"StayLit – Settings", @"StayLit – Settings")

#define SLT_SETTINGS_L10N_GENERAL SLT_SETTINGS_LOCALIZED_STRING(@"General", @"General")
#define SLT_SETTINGS_L10N_ACTIVATION_DURATION SLT_SETTINGS_LOCALIZED_STRING(@"Activation Duration", @"Activation Duration")
#define SLT_SETTINGS_L10N_BATTERY SLT_SETTINGS_LOCALIZED_STRING(@"Battery", @"Battery")
#define SLT_SETTINGS_L10N_ADVANCED SLT_SETTINGS_LOCALIZED_STRING(@"Advanced", @"Advanced")
#define SLT_SETTINGS_L10N_UPDATES SLT_SETTINGS_LOCALIZED_STRING(@"Updates", @"Updates")
#define SLT_SETTINGS_L10N_ABOUT SLT_SETTINGS_LOCALIZED_STRING(@"About", @"About")

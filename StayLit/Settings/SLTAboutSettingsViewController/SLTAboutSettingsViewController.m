//
//  SLTAboutSettingsViewController.m
//  StayLit
//

#import "SLTAboutSettingsViewController.h"
#import "SLTLocalizedStrings.h"

@interface SLTAboutSettingsViewController ()
@end

@implementation SLTAboutSettingsViewController

+ (NSImage *)tabViewItemImage
{
    return [NSImage imageWithSystemSymbolName:@"info.circle" accessibilityDescription:nil];
}

+ (NSString *)preferredTitle
{
    return SLT_SETTINGS_L10N_ABOUT;
}

#pragma mark - Bindings

- (NSString *)versionText
{
    return [NSString localizedStringWithFormat:@"%@ %@",
            SLT_L10N_VERSION,
            NSBundle.mainBundle.slt_fullVersionString];
}

- (NSString *)copyrightText
{
    return NSBundle.mainBundle.slt_localizedCopyrightString;
}

- (id)creditsFileURL
{
    return [NSBundle.mainBundle URLForResource:@"Credits" withExtension:@"rtf"];
}

- (BOOL)isEditable
{
    return NO;
}

@end

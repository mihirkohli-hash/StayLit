//
//  SLTActivationDuration+SLTLocalizedTitle.m
//  StayLit
//
//

#import "SLTActivationDuration+SLTLocalizedTitle.h"
#import <SLTCommon/SLTCommon.h>
#import "SLTLocalizedStrings.h"

@implementation SLTActivationDuration (SLTLocalizedTitle)

- (NSString *)localizedTitle
{
    NSTimeInterval interval = self.seconds;
    
    if(interval == 0)
    {
        return SLT_L10N_INDEFINITELY;
    }
    
    Auto formatter = [self sharedDateComponentsFormatter];
    return [formatter stringFromTimeInterval:interval];
}

#pragma mark - Localized Formatter

- (NSDateComponentsFormatter *)sharedDateComponentsFormatter
{
    static dispatch_once_t once;
    static NSDateComponentsFormatter *sharedFormatter;
    dispatch_once(&once, ^{
        sharedFormatter = [NSDateComponentsFormatter new];
        sharedFormatter.unitsStyle = NSDateComponentsFormatterUnitsStyleFull;
    });
    return sharedFormatter;
}

@end

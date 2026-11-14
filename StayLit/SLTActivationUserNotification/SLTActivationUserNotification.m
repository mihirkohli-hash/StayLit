//
//  SLTActivationUserNotification.m
//  StayLit
//
//

#import "SLTActivationUserNotification.h"
#import <SLTCommon/SLTCommon.h>
#import "SLTLocalizedStrings.h"

NSString * const SLTActivationUserNotificationIdentifier = @"SLTActivationIdentifier";

@interface SLTActivationUserNotification ()
@property (nonatomic, nullable, readwrite) NSDate *fireDate;
@property (nonatomic, getter=isActivating, readwrite) BOOL activating;
@end

@implementation SLTActivationUserNotification

- (instancetype)initWithFireDate:(NSDate *)fireDate activating:(BOOL)activating
{
    self = [super init];
    if(self)
    {
        self.identifier = SLTActivationUserNotificationIdentifier;
        
        self.fireDate = fireDate;
        self.activating = activating;
        
        if(activating == YES)
        {
            if(fireDate != nil)
            {
                Auto time = fireDate.slt_localizedRemainingTimeWithoutPhrase;
                Auto text = SLT_L10N_PREVENTING_SLEEP_FOR_TIME_TITLE(time);
                [self setLocalizedTitleWithKey:text arguments:nil];
                [self setLocalizedBodyTextWithKey:SLT_L10N_PREVENTING_SLEEP_FOR_TIME_BODY_TEXT
                                        arguments:nil];
            }
            else
            {
                [self setLocalizedTitleWithKey:SLT_L10N_PREVENTING_SLEEP_INDEFINITELY_TITLE
                                     arguments:nil];
                [self setLocalizedBodyTextWithKey:SLT_L10N_PREVENTING_SLEEP_INDEFINITELY_BODY_TEXT
                                        arguments:nil];
            }
        }
        else
        {
            [self setLocalizedTitleWithKey:SLT_L10N_ALLOWING_SLEEP_TITLE arguments:nil];
            [self setLocalizedBodyTextWithKey:SLT_L10N_ALLOWING_SLEEP_BODY_TEXT arguments:nil];
        }
    }
    return self;
}

@end

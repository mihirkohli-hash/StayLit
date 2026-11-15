//
//  NSDate+RemainingTime.m
//  SLTUserNotifications
//

#import <SLTUserNotifications/NSDate+RemainingTime.h>
#import <SLTCommon/SLTCommon.h>

@implementation NSDate (RemainingTime)

- (NSDateComponentsFormatter *)dateComponentsFormatter
{
    static NSDateComponentsFormatter *dateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [NSDateComponentsFormatter new];
        dateFormatter.allowedUnits = NSCalendarUnitSecond | NSCalendarUnitMinute | NSCalendarUnitHour;
        dateFormatter.unitsStyle = NSDateComponentsFormatterUnitsStyleShort;
        dateFormatter.includesTimeRemainingPhrase = YES;
    });
    
    return dateFormatter;
}

- (NSString *)slt_localizedRemainingTime
{
    Auto startDate = [NSDate dateWithTimeIntervalSinceNow:-1];
    return [[self dateComponentsFormatter] stringFromDate:startDate toDate:self];
}

- (NSString *)slt_localizedRemainingTimeWithoutPhrase
{
    Auto formatter = [self dateComponentsFormatter];
    formatter.includesTimeRemainingPhrase = NO;
    Auto startDate = [NSDate dateWithTimeIntervalSinceNow:-1];
    Auto remainingTimeString = [formatter stringFromDate:startDate toDate:self];
    formatter.includesTimeRemainingPhrase = YES;
    
    return remainingTimeString;
}

@end

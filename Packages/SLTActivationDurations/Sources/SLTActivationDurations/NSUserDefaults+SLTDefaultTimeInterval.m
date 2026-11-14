//
//  NSUserDefaults+SLTDefaultTimeInterval.m
//  SLTActivationDurations
//
//

#import <SLTActivationDurations/NSUserDefaults+SLTDefaultTimeInterval.h>
#import <SLTCommon/SLTCommon.h>

NSString * const SLTUserDefaultsKeyDefaultTimeInterval = @"io.github.mihirkohli-hash.StayLit.TimeInterval";

@implementation NSUserDefaults (SLTDefaultTimeInterval)
@dynamic slt_defaultTimeInterval;

- (NSTimeInterval)slt_defaultTimeInterval
{
    return (NSTimeInterval)[self integerForKey:SLTUserDefaultsKeyDefaultTimeInterval];
}

- (void)setSlt_defaultTimeInterval:(NSTimeInterval)defaultTimeInterval
{
    [self setInteger:(NSInteger)defaultTimeInterval
              forKey:SLTUserDefaultsKeyDefaultTimeInterval];  // decimal places will be cut-off
}

@end

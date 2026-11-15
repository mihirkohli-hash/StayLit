//
//  SLTActivationDuration.mm
//  SLTActivationDurations
//

#import <SLTActivationDurations/SLTActivationDuration.h>
#import <SLTCommon/SLTCommon.h>
#import "SLTActivationDurationsLog.h"
#include <chrono>

NSTimeInterval const SLTActivationDurationIndefinite = 0.0f;

@interface SLTActivationDuration ()
@property (nonatomic, readwrite) NSTimeInterval seconds;
@end

@implementation SLTActivationDuration

+ (NSArray<SLTActivationDuration *> *)defaultActivationDurations
{
    using namespace std::chrono_literals;
    return @[
             [[SLTActivationDuration alloc] initWithDuration:5min],
             [[SLTActivationDuration alloc] initWithDuration:10min],
             [[SLTActivationDuration alloc] initWithDuration:15min],
             [[SLTActivationDuration alloc] initWithDuration:30min],
             [[SLTActivationDuration alloc] initWithDuration:1h],
             [[SLTActivationDuration alloc] initWithDuration:2h],
             [[SLTActivationDuration alloc] initWithDuration:5h]
             ];
}

+ (SLTActivationDuration *)indefiniteActivationDuration
{
    return [[SLTActivationDuration alloc] initWithSeconds:SLTActivationDurationIndefinite];
}

- (instancetype)initWithSeconds:(NSTimeInterval)seconds
{
    self = [super init];
    if(self)
    {
        self.seconds = seconds;
    }
    return self;
}

- (instancetype)initWithHours:(NSInteger)hours minutes:(NSInteger)minutes seconds:(NSInteger)seconds
{
    using namespace std::chrono_literals;
    
    auto hoursValue = std::chrono::hours { hours };
    
    auto minutesValue = std::chrono::minutes { minutes };
    if(minutesValue > 1h)
    {
        os_log_fault(SLTActivationDurationsLog(), "Attempted to add a duration with a minutes component value greater than an hour.");
        return nil;
    }
    
    auto secondsValue = std::chrono::seconds { seconds };
    if(secondsValue > 1min)
    {
        os_log_fault(SLTActivationDurationsLog(), "Attempted to add a duration with a seconds component value greater than a minute.");
        return nil;
    }
    
    std::chrono::seconds totalValue = hoursValue + minutesValue + secondsValue;
    if(totalValue == 0s)
    {
        os_log_fault(SLTActivationDurationsLog(), "Attempted to add a 0 duration.");
        return nil;
    }
    
    return [self initWithDuration:totalValue];
}

- (instancetype)initWithDuration:(std::chrono::duration<NSTimeInterval>)duration
{
    return [self initWithSeconds:duration.count()];
}

- (NSString *)description
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    NSString *title;
    if([self respondsToSelector:@selector(localizedTitle)])
    {
        title = [self performSelector:@selector(localizedTitle)];
    }
    else
    {
        title = @(self.seconds).stringValue;
    }
    return [NSString stringWithFormat:@"%@ (%@)", super.description, title];
#pragma clang diagnostic pop
}

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding
{
    return YES;
}

#pragma mark - NSCoding

#define kCodingKeySeconds @"SLTSeconds"

- (instancetype)initWithCoder:(NSCoder *)decoder
{
    NSTimeInterval seconds = [decoder decodeDoubleForKey:kCodingKeySeconds];
    return [self initWithSeconds:seconds];
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeDouble:self.seconds forKey:kCodingKeySeconds];
}

#pragma mark - Hashable & Equatable

- (NSUInteger)hash
{
    return (NSUInteger)self.seconds;
}

- (BOOL)isEqual:(id)object
{
    if(object == nil) { return NO; }
    if(object == self) { return YES; }
    if([object isKindOfClass:[self class]])
    {
        return [self isEqualToActivationDuration:(decltype(self))object];
    }
    
    return NO;
}

- (BOOL)isEqualToActivationDuration:(SLTActivationDuration *)other
{
    NSParameterAssert(other);
    
    return self.seconds == other.seconds;
}

@end

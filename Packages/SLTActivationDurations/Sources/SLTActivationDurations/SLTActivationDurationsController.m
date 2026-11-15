//
//  SLTActivationDurationsController.m
//  SLTActivationDurations
//

#import <SLTActivationDurations/SLTActivationDurationsController.h>
#import <SLTCommon/SLTCommon.h>
#import <SLTActivationDurations/NSUserDefaults+SLTDefaultTimeInterval.h>
#import "SLTActivationDurationsLog.h"

#define SLT_USES_SIMPLE_USER_DEFAULTS_VALUES 1

NSNotificationName const SLTActivationDurationsDidChangeNotification = @"SLTActivationDurationsDidChangeNotification";

static NSString * const SLTDefaultsKeyDurations = @"io.github.mihirkohli-hash.StayLit.Durations";

@interface SLTActivationDurationsController ()
@property (nonatomic, readwrite) NSUserDefaults *userDefaults;
@property (nonatomic) NSMutableArray<SLTActivationDuration *> *storedActivationDurations;
@end

@implementation SLTActivationDurationsController

+ (instancetype)sharedController
{
    static dispatch_once_t once;
    static SLTActivationDurationsController *shared;
    dispatch_once(&once, ^{
        Auto defaults = NSUserDefaults.standardUserDefaults;
        shared = [[self alloc] initWithUserDefaults:defaults];
    });
    return shared;
}

- (instancetype)initWithUserDefaults:(NSUserDefaults *)userDefaults
{
    NSParameterAssert(userDefaults);
    
    self = [super init];
    if(self)
    {
        self.userDefaults = userDefaults;
        
        [self loadFromUserDefaults];
    }
    return self;
}

- (void)resetActivationDurations
{
    [self restoreDefaultDurations];
    
    // Reset the default duration if it got removed
    if(![self.storedActivationDurations containsObject:self.defaultActivationDuration])
    {
        [self setDefaultActivationDuration:SLTActivationDuration.indefiniteActivationDuration
                          notifyListensers:NO];
    }
    
    [self didChange];
}

- (void)restoreDefaultDurations
{
    self.storedActivationDurations = [SLTActivationDuration.defaultActivationDurations mutableCopy];
}

- (NSArray<SLTActivationDuration *> *)activationDurations
{
    Auto durations = [NSMutableArray arrayWithArray:self.storedActivationDurations];
    [durations insertObject:SLTActivationDuration.indefiniteActivationDuration atIndex:0];
    
    Auto sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"seconds" ascending:YES];
    return [durations sortedArrayUsingDescriptors:@[sortDescriptor]];
}

- (BOOL)addActivationDuration:(SLTActivationDuration *)activationDuration
{
    NSParameterAssert(activationDuration);
    
    if([self.storedActivationDurations containsObject:activationDuration])
    {
        return NO;
    }
    [self.storedActivationDurations addObject:activationDuration];
    [self didChange];
    
    return YES;
}

- (BOOL)removeActivationDuration:(SLTActivationDuration *)activationDuration
{
    NSParameterAssert(activationDuration);
    
    if(![self.storedActivationDurations containsObject:activationDuration])
    {
        return NO;
    }
    [self.storedActivationDurations removeObject:activationDuration];
    
    // Reset the default duration if it got removed
    if(![self.storedActivationDurations containsObject:self.defaultActivationDuration])
    {
        [self setDefaultActivationDuration:SLTActivationDuration.indefiniteActivationDuration
                          notifyListensers:NO];
    }
    
    [self didChange];
    
    return YES;
}

- (BOOL)canRemoveActivationDurationAtIndex:(NSUInteger)index
{
    Auto durations = self.activationDurations;
    if(index >= durations.count) { return NO; }
    
    Auto duration = durations[index];
    if(duration == nil) { return NO; }
    
    if(duration.seconds == SLTActivationDurationIndefinite)
    {
        return NO;
    }
    
    return YES;
}

- (BOOL)removeActivationDurationAtIndex:(NSUInteger)index
{
    if([self canRemoveActivationDurationAtIndex:index] == NO) { return NO; }
    
    Auto duration = self.activationDurations[index];
    return [self removeActivationDuration:duration];
}

- (void)setActivationDurationAsDefaultAtIndex:(NSUInteger)index
{
    Auto durations = self.activationDurations;
    if(index >= durations.count) { return; }
    
    Auto duration = durations[index];
    if(duration == nil) { return; }
    
    [self setDefaultActivationDuration:duration notifyListensers:NO];
    [self didChange];
}

- (void)didChange
{
    [self saveToUserDefaults];
    
    Auto notification = SLTActivationDurationsDidChangeNotification;
    [NSNotificationCenter.defaultCenter postNotificationName:notification object:self];
}

#pragma mark - Default Activation Duration

- (void)setDefaultActivationDuration:(SLTActivationDuration *)duration
{
    [self setDefaultActivationDuration:duration notifyListensers:YES];
}

- (void)setDefaultActivationDuration:(SLTActivationDuration *)duration notifyListensers:(BOOL)notify
{
    NSParameterAssert(duration);
    
    NSAssert([self.activationDurations containsObject:duration], @"The passed duration must be contained in self.activationDurations.");
    
    self.userDefaults.slt_defaultTimeInterval = duration.seconds;
    [self.userDefaults synchronize];
    
    if(notify)
    {
        Auto notification = SLTActivationDurationsDidChangeNotification;
        [NSNotificationCenter.defaultCenter postNotificationName:notification object:self];
    }
}

- (SLTActivationDuration *)defaultActivationDuration
{
    NSTimeInterval seconds = self.userDefaults.slt_defaultTimeInterval;
    if(seconds == SLTActivationDurationIndefinite)
    {
        return SLTActivationDuration.indefiniteActivationDuration;
    }
    
    Auto defaultPredicate = [NSPredicate predicateWithFormat:@"seconds == %@",
                             @(seconds)
    ];
    Auto results = [self.storedActivationDurations filteredArrayUsingPredicate:defaultPredicate];
    
    return results.firstObject;
}

#pragma mark - User Defaults Handling

- (void)loadFromUserDefaults
{
    // Load without triggering didChange
#if SLT_USES_SIMPLE_USER_DEFAULTS_VALUES
    NSArray<NSNumber *> *seconds = [self.userDefaults objectForKey:SLTDefaultsKeyDurations];
    NSMutableArray<SLTActivationDuration *> *loadedDurations = [NSMutableArray new];
    if(seconds != nil && [seconds isKindOfClass:[NSArray class]])
    {
        for(NSNumber *value in seconds)
        {
            NSTimeInterval interval = (NSTimeInterval)value.integerValue;
            Auto duration = [[SLTActivationDuration alloc] initWithSeconds:interval];
            [loadedDurations addObject:duration];
        }
    }
#else
    Auto data = [self.userDefaults dataForKey:SLTDefaultsKeyDurations];
    NSArray *loadedDurations;
    if(data != nil)
    {
        NSError *error;
        Auto classes = [NSSet setWithObjects:[NSArray class], [SLTActivationDuration class], nil];
        loadedDurations = [NSKeyedUnarchiver unarchivedObjectOfClasses:classes
                                                              fromData:data
                                                                 error:&error];
        if(error != nil)
        {
            os_log_error(SLTActivationDurationsLog(), "Failed to unarchive durations %{public}@", error.userInfo);
        }
    }
#endif
    
    if(loadedDurations == nil || loadedDurations.count == 0)
    {
        [self restoreDefaultDurations];
        [self saveToUserDefaults];
    }
    else
    {
#if SLT_USES_SIMPLE_USER_DEFAULTS_VALUES
        self.storedActivationDurations = loadedDurations;
#else
        self.storedActivationDurations = [NSMutableArray arrayWithArray:loadedDurations];
#endif
        os_log(SLTActivationDurationsLog(), "Loaded durations from user defaults: %{public}@", loadedDurations);
    }
}

- (void)saveToUserDefaults
{
    NSAssert(self.storedActivationDurations != nil, @"The stored durations should never be nil.");
    
#if SLT_USES_SIMPLE_USER_DEFAULTS_VALUES
    NSArray<SLTActivationDuration *> *durations = [self.storedActivationDurations copy];
    Auto seconds = [NSMutableArray<NSNumber *> new];
    for(SLTActivationDuration *duration in durations)
    {
        [seconds addObject:@(duration.seconds)];
    }
    [self.userDefaults setObject:seconds forKey:SLTDefaultsKeyDurations];
#else
    NSError *error;
    Auto data = [NSKeyedArchiver archivedDataWithRootObject:self.storedActivationDurations
                                      requiringSecureCoding:YES
                                                      error:&error];
    if(error != nil)
    {
        os_log(SLTActivationDurationsLog(), "Failed to archive durations %{public}@", error.userInfo);
        return;
    }
    [self.userDefaults setObject:data forKey:SLTDefaultsKeyDurations];
#endif
    
    [self.userDefaults synchronize];
    
    os_log(SLTActivationDurationsLog(), "Saved durations to user defaults: %{public}@", self.storedActivationDurations);
}

@end

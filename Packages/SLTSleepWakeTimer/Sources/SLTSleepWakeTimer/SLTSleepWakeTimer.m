//
//  SLTSleepWakeTimer.m
//  StayLit
//
//

#import <SLTSleepWakeTimer/SLTSleepWakeTimer.h>
#import <SLTCommon/SLTCommon.h>
#import "SLTSleepWakeTimer+Private.h"

NSTimeInterval const SLTSleepWakeTimeIntervalIndefinite = 0;

@interface SLTSleepWakeTimer ()
@property (copy, nonatomic, readwrite) NSDate *fireDate;
@property (nonatomic, readwrite) NSTimeInterval scheduledTimeInterval;
@property (nonatomic) NSTask *caffeinateTask;
@property (nonatomic) os_log_t log;
@end

@implementation SLTSleepWakeTimer

- (instancetype)init
{
    self = [super init];
    if(self)
    {
        // Terminate all remaining tasks on app quit
        AutoWeak weakSelf = self;
        Auto center = NSNotificationCenter.defaultCenter;
        [center addObserverForName:NSApplicationWillTerminateNotification
                            object:nil
                             queue:nil
                        usingBlock:^(NSNotification *note) {
            [weakSelf invalidate];
        }];
        
        self.log = SLTLogCreateWithCategory("SleepWakeTimer");
    }
    return self;
}

- (void)dealloc
{
    [self invalidate];
}

#pragma mark - Scheduling

- (void)scheduleWithTimeInterval:(NSTimeInterval)timeInterval completion:(SLTSleepWakeTimerCompletionBlock)completion
{
    os_log(self.log, "%{public}@ will activate with time interval %{public}@.", self, @(timeInterval));
    
    Auto delegate = self.delegate;
    if([self.delegate respondsToSelector:@selector(sleepWakeTimer:willActivateWithTimeInterval:)])
    {
        [delegate sleepWakeTimer:self willActivateWithTimeInterval:timeInterval];
    }
    
    if(completion)
    {
        self.completionBlock = completion;
    }

    // Set the fireDate
    self.scheduledTimeInterval = timeInterval;
    if(timeInterval != SLTSleepWakeTimeIntervalIndefinite)
    {
        self.fireDate = [NSDate dateWithTimeIntervalSinceNow:timeInterval];
    }

    // Spawn caffeinate
    [self spawnCaffeinateTaskForTimeInterval:timeInterval];
}

- (void)invalidate
{
    self.fireDate = nil;
    self.scheduledTimeInterval = SLTSleepWakeTimeIntervalIndefinite;
    [self terminateCaffeinateTask];
}

- (BOOL)isScheduled
{
    if(self.caffeinateTask && [self.caffeinateTask isRunning])
    {
        return YES;
    }

    return NO;
}

#pragma mark - Caffeinate Task Handling

+ (NSArray<NSString *> *)caffeinateArgumentsForTimeInterval:(NSTimeInterval)timeInterval
                                                userDefaults:(NSUserDefaults *)defaults
                                           processIdentifier:(int)processIdentifier
{
    Auto arguments = [NSMutableArray<NSString *> new];
    if([defaults slt_shouldAllowDisplaySleep])
    {
        [arguments addObject:@"-i"];
    }
    else
    {
        [arguments addObject:@"-di"];
    }

    // Closing a MacBook lid forces sleep even with an idle sleep assertion.
    // Only the system sleep assertion (-s) survives that, and macOS honors it
    // on AC power only.
    if([defaults slt_isKeepAwakeOnLidCloseEnabled])
    {
        [arguments addObject:@"-s"];
    }

    if(timeInterval != SLTSleepWakeTimeIntervalIndefinite)
    {
        [arguments addObject:[NSString stringWithFormat:@"-t %.f", timeInterval]];
    }

    [arguments addObject:[NSString stringWithFormat:@"-w %i", processIdentifier]];

    return [arguments copy];
}

- (void)spawnCaffeinateTaskForTimeInterval:(NSTimeInterval)timeInterval
{
    Auto arguments = [SLTSleepWakeTimer caffeinateArgumentsForTimeInterval:timeInterval
                                                              userDefaults:NSUserDefaults.standardUserDefaults
                                                         processIdentifier:NSProcessInfo.processInfo.processIdentifier];

    [self willChangeValueForKey:@"scheduled"];
    self.caffeinateTask = [NSTask launchedTaskWithLaunchPath:@"/usr/bin/caffeinate"
                                                   arguments:arguments];

    // Termination Handler
    AutoWeak weakSelf = self;
    self.caffeinateTask.terminationHandler = ^(NSTask *task) {
        [weakSelf terminateWithForce:NO];
    };
    [self didChangeValueForKey:@"scheduled"];
}

- (void)terminateCaffeinateTask
{
    self.caffeinateTask.terminationHandler = nil;
    [self.caffeinateTask terminate];

    [self terminateWithForce:YES];
}

- (void)terminateWithForce:(BOOL)forcedTermination
{
    [self willChangeValueForKey:@"scheduled"];
    self.caffeinateTask = nil;
    self.scheduledTimeInterval = SLTSleepWakeTimeIntervalIndefinite;
    self.fireDate = nil;
    [self didChangeValueForKey:@"scheduled"];

    if(self.completionBlock)
    {
        AutoWeak weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.completionBlock(forcedTermination);
        });
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        Auto delegate = self.delegate;
        if([delegate respondsToSelector:@selector(sleepWakeTimerDidDeactivate:)])
        {
            [delegate sleepWakeTimerDidDeactivate:self];
        }
    });
    
    os_log(self.log, "%{public}@ did deactivate.", self);
}

@end

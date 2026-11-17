//
//  SLTSleepWakeTimer.m
//  StayLit
//

#import <SLTSleepWakeTimer/SLTSleepWakeTimer.h>
#import <SLTCommon/SLTCommon.h>
#import <SLTSleepWakeTimer/SLTClosedLidSleepGuard.h>
#import "SLTSleepWakeTimer+Private.h"

NSTimeInterval const SLTSleepWakeTimeIntervalIndefinite = 0;

@interface SLTSleepWakeTimer ()
@property (copy, nonatomic, readwrite) NSDate *fireDate;
@property (nonatomic, readwrite) NSTimeInterval scheduledTimeInterval;
@property (nonatomic) NSTask *caffeinateTask;
@property (nonatomic) os_log_t log;
@property (nonatomic) id terminationObserver;
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
        self.terminationObserver = [center addObserverForName:NSApplicationWillTerminateNotification
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
    [NSNotificationCenter.defaultCenter removeObserver:self.terminationObserver];

    // No callbacks here. A deallocating object cannot be referenced weakly, and nobody
    // is left to receive them.
    self.caffeinateTask.terminationHandler = nil;
    [self.caffeinateTask terminate];
}

#pragma mark - Scheduling

- (void)scheduleWithTimeInterval:(NSTimeInterval)timeInterval completion:(SLTSleepWakeTimerCompletionBlock)completion
{
    os_log(self.log, "%{public}@ will activate with time interval %{public}@.", self, @(timeInterval));

    // A second caffeinate would keep the Mac awake after the user turns StayLit off,
    // because only the newest task is tracked. The old task ends without a deactivate callback.
    Auto previousTask = self.caffeinateTask;
    if(previousTask != nil)
    {
        previousTask.terminationHandler = nil;
        [previousTask terminate];
        self.caffeinateTask = nil;
    }

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

    Auto task = [NSTask new];
    task.executableURL = [NSURL fileURLWithPath:@"/usr/bin/caffeinate"];
    task.arguments = arguments;

    // The handler is set before launch, so a short caffeinate that exits at once is not missed.
    // It runs on a background queue, so the state change moves to the main queue. The task
    // check ignores a task that a newer schedule call already replaced.
    AutoWeak weakSelf = self;
    task.terminationHandler = ^(NSTask *finishedTask) {
        dispatch_async(dispatch_get_main_queue(), ^{
            Auto strongSelf = weakSelf;
            if(strongSelf.caffeinateTask == finishedTask)
            {
                [strongSelf terminateWithForce:NO];
            }
        });
    };

    [self willChangeValueForKey:@"scheduled"];
    NSError *launchError = nil;
    if(![task launchAndReturnError:&launchError])
    {
        os_log_error(self.log, "caffeinate could not start: %{public}@", launchError);
        [self didChangeValueForKey:@"scheduled"];
        [self terminateWithForce:YES];
        return;
    }
    self.caffeinateTask = task;

    // On battery, caffeinate cannot keep a closed lid awake. The guard can, but only
    // when the user gave the one-time permission. Without it, the session still runs.
    if([NSUserDefaults.standardUserDefaults slt_isKeepAwakeOnLidCloseEnabled])
    {
        [SLTClosedLidSleepGuard beginSessionWithWatchedProcessIdentifier:NSProcessInfo.processInfo.processIdentifier
                                             caffeinateProcessIdentifier:task.processIdentifier];
    }
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

    // The block must not retain self, or the timer would live until the block runs.
    Auto completion = self.completionBlock;
    Auto delegate = self.delegate;
    AutoWeak weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if(completion)
        {
            completion(forcedTermination);
        }

        Auto strongSelf = weakSelf;
        if(strongSelf != nil && [delegate respondsToSelector:@selector(sleepWakeTimerDidDeactivate:)])
        {
            [delegate sleepWakeTimerDidDeactivate:strongSelf];
        }
    });
    
    os_log(self.log, "%{public}@ did deactivate.", self);
}

@end

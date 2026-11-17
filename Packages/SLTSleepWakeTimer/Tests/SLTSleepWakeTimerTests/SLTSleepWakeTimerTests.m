//
//  SLTSleepWakeTimerTests.m
//  SLTSleepWakeTimer
//
//  Created by Mihir Kohli on 2026.
//

#import <XCTest/XCTest.h>
#import <SLTCommon/SLTCommon.h>
#import <SLTApplicationSupport/SLTApplicationSupport.h>
#import <SLTSleepWakeTimer/SLTSleepWakeTimer.h>
#import "../../Sources/SLTSleepWakeTimer/SLTSleepWakeTimer+Private.h"

@interface SLTSleepWakeTimerTests : XCTestCase
@property (nonatomic) NSUserDefaults *defaults;
@end

@implementation SLTSleepWakeTimerTests

- (void)setUp
{
    [super setUp];

    // A fresh suite per test, so no stored setting leaks between tests.
    Auto suiteName = [NSString stringWithFormat:@"%@.%@", NSStringFromClass([self class]), NSUUID.UUID.UUIDString];
    self.defaults = [[NSUserDefaults alloc] initWithSuiteName:suiteName];
}

// The app keeps its one timer alive for its whole lifetime, and the tests mirror that.
- (SLTSleepWakeTimer *)newRetainedTimer
{
    static NSMutableArray<SLTSleepWakeTimer *> *retainedTimers;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ retainedTimers = [NSMutableArray new]; });

    Auto timer = [SLTSleepWakeTimer new];
    [retainedTimers addObject:timer];
    return timer;
}

- (NSArray<NSString *> *)argumentsForTimeInterval:(NSTimeInterval)timeInterval
{
    return [SLTSleepWakeTimer caffeinateArgumentsForTimeInterval:timeInterval
                                                    userDefaults:self.defaults
                                               processIdentifier:4242];
}

#pragma mark - Arguments

- (void)testDefaultSettingsPreventIdleAndDisplaySleepOnly
{
    Auto expected = @[@"-di", @"-w 4242"];
    XCTAssertEqualObjects([self argumentsForTimeInterval:SLTSleepWakeTimeIntervalIndefinite], expected);
}

- (void)testAllowDisplaySleepPreventsIdleSleepOnly
{
    self.defaults.slt_allowDisplaySleep = YES;

    Auto expected = @[@"-i", @"-w 4242"];
    XCTAssertEqualObjects([self argumentsForTimeInterval:SLTSleepWakeTimeIntervalIndefinite], expected);
}

- (void)testKeepAwakeOnLidCloseAddsSystemSleepAssertion
{
    self.defaults.slt_keepAwakeOnLidCloseEnabled = YES;

    Auto expected = @[@"-di", @"-s", @"-w 4242"];
    XCTAssertEqualObjects([self argumentsForTimeInterval:SLTSleepWakeTimeIntervalIndefinite], expected);
}

- (void)testKeepAwakeOnLidCloseCombinesWithAllowDisplaySleep
{
    self.defaults.slt_allowDisplaySleep = YES;
    self.defaults.slt_keepAwakeOnLidCloseEnabled = YES;

    Auto expected = @[@"-i", @"-s", @"-w 4242"];
    XCTAssertEqualObjects([self argumentsForTimeInterval:SLTSleepWakeTimeIntervalIndefinite], expected);
}

- (void)testTimedActivationKeepsOrderWithLidSetting
{
    self.defaults.slt_keepAwakeOnLidCloseEnabled = YES;

    Auto expected = @[@"-di", @"-s", @"-t 60", @"-w 4242"];
    XCTAssertEqualObjects([self argumentsForTimeInterval:60], expected);
}

- (void)testTimedActivationWithoutLidSetting
{
    Auto expected = @[@"-di", @"-t 3600", @"-w 4242"];
    XCTAssertEqualObjects([self argumentsForTimeInterval:3600], expected);
}

- (void)testFractionalTimeIntervalIsRoundedToWholeSeconds
{
    Auto expected = @[@"-di", @"-t 2", @"-w 4242"];
    XCTAssertEqualObjects([self argumentsForTimeInterval:1.6], expected);
}

- (void)testLidSettingTurnedOffAgainRemovesSystemSleepAssertion
{
    self.defaults.slt_keepAwakeOnLidCloseEnabled = YES;
    self.defaults.slt_keepAwakeOnLidCloseEnabled = NO;

    Auto expected = @[@"-di", @"-w 4242"];
    XCTAssertEqualObjects([self argumentsForTimeInterval:SLTSleepWakeTimeIntervalIndefinite], expected);
}

- (void)testRemovedLidSettingKeyFallsBackToOff
{
    self.defaults.slt_keepAwakeOnLidCloseEnabled = YES;
    [self.defaults removeObjectForKey:SLTUserDefaultsKeyKeepAwakeOnLidCloseEnabled];

    XCTAssertFalse([[self argumentsForTimeInterval:SLTSleepWakeTimeIntervalIndefinite] containsObject:@"-s"]);
}

- (void)testWatchedProcessIdentifierIsPassedThrough
{
    Auto arguments = [SLTSleepWakeTimer caffeinateArgumentsForTimeInterval:SLTSleepWakeTimeIntervalIndefinite
                                                              userDefaults:self.defaults
                                                         processIdentifier:1];
    XCTAssertEqualObjects(arguments.lastObject, @"-w 1");
}

#pragma mark - Real process lifecycle

// These tests start the real /usr/bin/caffeinate with the lid setting on,
// to prove macOS accepts the combined options.

- (void)testRealProcessStartsAndStopsWithLidSetting
{
    Auto standardDefaults = NSUserDefaults.standardUserDefaults;
    Auto previousValue = [standardDefaults objectForKey:SLTUserDefaultsKeyKeepAwakeOnLidCloseEnabled];
    standardDefaults.slt_keepAwakeOnLidCloseEnabled = YES;

    Auto timer = [self newRetainedTimer];
    Auto completed = [self expectationWithDescription:@"completion"];
    __block BOOL wasCancelled = NO;
    [timer scheduleWithTimeInterval:SLTSleepWakeTimeIntervalIndefinite completion:^(BOOL cancelled) {
        wasCancelled = cancelled;
        [completed fulfill];
    }];
    XCTAssertTrue(timer.isScheduled);
    XCTAssertNil(timer.fireDate);

    [timer invalidate];
    XCTAssertFalse(timer.isScheduled);

    [self waitForExpectationsWithTimeout:5 handler:nil];
    XCTAssertTrue(wasCancelled);

    if(previousValue) { [standardDefaults setObject:previousValue forKey:SLTUserDefaultsKeyKeepAwakeOnLidCloseEnabled]; }
    else { [standardDefaults removeObjectForKey:SLTUserDefaultsKeyKeepAwakeOnLidCloseEnabled]; }
}

- (void)testRealProcessExpiresAfterTimeIntervalWithLidSetting
{
    Auto standardDefaults = NSUserDefaults.standardUserDefaults;
    Auto previousValue = [standardDefaults objectForKey:SLTUserDefaultsKeyKeepAwakeOnLidCloseEnabled];
    standardDefaults.slt_keepAwakeOnLidCloseEnabled = YES;

    Auto timer = [self newRetainedTimer];
    Auto completed = [self expectationWithDescription:@"expired"];
    __block BOOL wasCancelled = YES;
    [timer scheduleWithTimeInterval:1 completion:^(BOOL cancelled) {
        wasCancelled = cancelled;
        [completed fulfill];
    }];
    XCTAssertTrue(timer.isScheduled);
    XCTAssertNotNil(timer.fireDate);

    [self waitForExpectationsWithTimeout:10 handler:nil];
    XCTAssertFalse(wasCancelled, @"The timer should expire on its own, not be cancelled.");
    XCTAssertFalse(timer.isScheduled);

    if(previousValue) { [standardDefaults setObject:previousValue forKey:SLTUserDefaultsKeyKeepAwakeOnLidCloseEnabled]; }
    else { [standardDefaults removeObjectForKey:SLTUserDefaultsKeyKeepAwakeOnLidCloseEnabled]; }
}

#pragma mark - Restart and release

// Only the newest task is tracked, so an earlier one that kept running would keep the
// Mac awake after the user turns StayLit off.
- (void)testSchedulingAgainEndsTheEarlierProcess
{
    Auto timer = [self newRetainedTimer];
    [timer scheduleWithTimeInterval:SLTSleepWakeTimeIntervalIndefinite completion:nil];
    NSTask *first = [timer valueForKey:@"caffeinateTask"];
    XCTAssertTrue(first.isRunning);

    [timer scheduleWithTimeInterval:SLTSleepWakeTimeIntervalIndefinite completion:nil];
    NSTask *second = [timer valueForKey:@"caffeinateTask"];
    XCTAssertNotEqual(first, second);
    XCTAssertTrue(second.isRunning);

    // terminate is asynchronous, so wait for the first process to exit.
    Auto deadline = [NSDate dateWithTimeIntervalSinceNow:5];
    while(first.isRunning && deadline.timeIntervalSinceNow > 0)
    {
        [NSThread sleepForTimeInterval:0.05];
    }
    XCTAssertFalse(first.isRunning);

    [timer invalidate];
}

// The earlier process ends without a deactivate callback, so the first completion block
// must not fire when the timer restarts.
- (void)testSchedulingAgainDoesNotReportTheEarlierProcessAsFinished
{
    Auto timer = [self newRetainedTimer];
    Auto reported = [self expectationWithDescription:@"first completion"];
    reported.inverted = YES;
    [timer scheduleWithTimeInterval:SLTSleepWakeTimeIntervalIndefinite completion:^(BOOL cancelled) {
        [reported fulfill];
    }];
    [timer scheduleWithTimeInterval:SLTSleepWakeTimeIntervalIndefinite completion:nil];

    [self waitForExpectations:@[reported] timeout:1.5];
    XCTAssertTrue(timer.isScheduled);

    [timer invalidate];
}

// Releasing a timer that runs a process must not crash. The deactivate callback that
// dealloc queues runs on the main queue after the timer is gone.
- (void)testReleasingARunningTimerDoesNotCrash
{
    @autoreleasepool
    {
        Auto timer = [SLTSleepWakeTimer new];
        [timer scheduleWithTimeInterval:SLTSleepWakeTimeIntervalIndefinite completion:nil];
    }

    Auto drained = [self expectationWithDescription:@"main queue drained"];
    dispatch_async(dispatch_get_main_queue(), ^{ [drained fulfill]; });
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

@end

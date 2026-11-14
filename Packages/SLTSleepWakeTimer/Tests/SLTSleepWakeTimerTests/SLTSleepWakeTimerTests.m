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

// The app keeps its one timer alive for its whole lifetime. Releasing a timer
// queues a main-queue callback that uses the freed object, so tests must not
// release the timers they start.
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

@end

//
//  SLTClosedLidSleepGuardTests.m
//  SLTSleepWakeTimer
//
//  Created by Mihir Kohli on 2026.
//

#import <XCTest/XCTest.h>
#import <SLTCommon/SLTCommon.h>
#import <SLTSleepWakeTimer/SLTSleepWakeTimer.h>
#import "../../Sources/SLTSleepWakeTimer/SLTClosedLidSleepGuard+Private.h"

@interface SLTClosedLidSleepGuardTests : XCTestCase
@property (nonatomic, copy) NSString *directory;
@property (nonatomic, copy) NSString *markerPath;
@property (nonatomic, copy) NSString *resetFilePath;
@end

@implementation SLTClosedLidSleepGuardTests

- (void)setUp
{
    [super setUp];

    self.directory = [NSTemporaryDirectory() stringByAppendingPathComponent:NSUUID.UUID.UUIDString];
    [NSFileManager.defaultManager createDirectoryAtPath:self.directory withIntermediateDirectories:YES attributes:nil error:nil];
    self.markerPath = [self.directory stringByAppendingPathComponent:@"marker"];
    self.resetFilePath = [self.directory stringByAppendingPathComponent:@"reset-ran"];
}

- (void)tearDown
{
    [NSFileManager.defaultManager removeItemAtPath:self.directory error:nil];
    [super tearDown];
}

#pragma mark - Sudoers rule

- (void)testSudoersRuleAllowsOnlyTheTwoPmsetCommands
{
    Auto expected = @"jane.doe ALL=(root) NOPASSWD: /usr/bin/pmset -a disablesleep 0, /usr/bin/pmset -a disablesleep 1";
    XCTAssertEqualObjects([SLTClosedLidSleepGuard sudoersRuleForUserName:@"jane.doe"], expected);
}

- (void)testSudoersRuleAcceptsCommonUserNameCharacters
{
    XCTAssertNotNil([SLTClosedLidSleepGuard sudoersRuleForUserName:@"Jane_Doe-2"]);
}

- (void)testSudoersRuleRejectsUserNamesThatCouldChangeTheRule
{
    Auto hostileNames = @[@"", @"ALL", @"a b", @"a,b", @"a:b", @"a=b", @"a'b", @"a\"b", @"a\nb", @"a;b", @"$(id)", @"`id`", @"%wheel", @"#1000", @"a\\b"];
    for(NSString *name in hostileNames)
    {
        XCTAssertNil([SLTClosedLidSleepGuard sudoersRuleForUserName:name], @"%@ must be rejected", name);
    }
}

#pragma mark - Watchdog

- (void)writeMarker:(NSString *)token
{
    [token writeToFile:self.markerPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

- (NSArray<NSString *> *)touchResetCommand
{
    return @[@"/usr/bin/touch", self.resetFilePath];
}

// Returns a running process that exits after the given seconds.
- (NSTask *)shortLivedProcessLastingSeconds:(int)seconds
{
    Auto task = [NSTask new];
    task.executableURL = [NSURL fileURLWithPath:@"/bin/sleep"];
    task.arguments = @[[NSString stringWithFormat:@"%i", seconds]];
    [task launchAndReturnError:nil];
    return task;
}

// Returns the identifier of a process that already exited.
- (int)deadProcessIdentifier
{
    Auto task = [NSTask new];
    task.executableURL = [NSURL fileURLWithPath:@"/usr/bin/true"];
    [task launchAndReturnError:nil];
    [task waitUntilExit];
    return task.processIdentifier;
}

- (NSTask *)watchdogForApp:(int)appPid caffeinate:(int)caffeinatePid token:(NSString *)token resetCommand:(NSArray<NSString *> *)command
{
    return [SLTClosedLidSleepGuard launchWatchdogForProcessIdentifier:appPid
                                          caffeinateProcessIdentifier:caffeinatePid
                                                           markerPath:self.markerPath
                                                                token:token
                                                         resetCommand:command];
}

- (void)testWatchdogResetsAfterCaffeinateExits
{
    [self writeMarker:@"session-1"];
    Auto caffeinate = [self shortLivedProcessLastingSeconds:2];
    Auto watchdog = [self watchdogForApp:NSProcessInfo.processInfo.processIdentifier
                              caffeinate:caffeinate.processIdentifier
                                   token:@"session-1"
                            resetCommand:[self touchResetCommand]];
    XCTAssertNotNil(watchdog);

    // The session is still running, so nothing may be reset yet.
    [NSThread sleepForTimeInterval:0.5];
    XCTAssertFalse([NSFileManager.defaultManager fileExistsAtPath:self.resetFilePath]);

    [watchdog waitUntilExit];
    XCTAssertEqual(watchdog.terminationStatus, 0);
    XCTAssertTrue([NSFileManager.defaultManager fileExistsAtPath:self.resetFilePath], @"The reset command should run once caffeinate is gone.");
    XCTAssertFalse([NSFileManager.defaultManager fileExistsAtPath:self.markerPath], @"A successful reset removes the marker.");
}

- (void)testWatchdogResetsWhenTheAppIsGone
{
    [self writeMarker:@"session-2"];
    Auto caffeinate = [self shortLivedProcessLastingSeconds:30];
    Auto watchdog = [self watchdogForApp:[self deadProcessIdentifier]
                              caffeinate:caffeinate.processIdentifier
                                   token:@"session-2"
                            resetCommand:[self touchResetCommand]];
    [watchdog waitUntilExit];
    [caffeinate terminate];

    XCTAssertTrue([NSFileManager.defaultManager fileExistsAtPath:self.resetFilePath], @"A crashed app must not leave the Mac awake.");
    XCTAssertFalse([NSFileManager.defaultManager fileExistsAtPath:self.markerPath]);
}

- (void)testWatchdogOfAnOlderSessionDoesNotResetANewerSession
{
    // A newer session replaced the token, so the older watchdog must stay quiet.
    [self writeMarker:@"newer-session"];
    Auto watchdog = [self watchdogForApp:NSProcessInfo.processInfo.processIdentifier
                              caffeinate:[self deadProcessIdentifier]
                                   token:@"older-session"
                            resetCommand:[self touchResetCommand]];
    [watchdog waitUntilExit];

    XCTAssertEqual(watchdog.terminationStatus, 0);
    XCTAssertFalse([NSFileManager.defaultManager fileExistsAtPath:self.resetFilePath]);
    XCTAssertEqualObjects([NSString stringWithContentsOfFile:self.markerPath encoding:NSUTF8StringEncoding error:nil], @"newer-session");
}

- (void)testFailedResetKeepsTheMarkerForTheNextLaunch
{
    [self writeMarker:@"session-3"];
    Auto watchdog = [self watchdogForApp:NSProcessInfo.processInfo.processIdentifier
                              caffeinate:[self deadProcessIdentifier]
                                   token:@"session-3"
                            resetCommand:@[@"/usr/bin/false"]];
    [watchdog waitUntilExit];

    XCTAssertNotEqual(watchdog.terminationStatus, 0);
    XCTAssertTrue([NSFileManager.defaultManager fileExistsAtPath:self.markerPath], @"The marker tells the next launch to try the reset again.");
}

- (void)testWatchdogSurvivesWhenItsLaunchingTaskObjectIsReleased
{
    [self writeMarker:@"session-4"];
    Auto caffeinate = [self shortLivedProcessLastingSeconds:2];
    @autoreleasepool {
        [self watchdogForApp:NSProcessInfo.processInfo.processIdentifier
                  caffeinate:caffeinate.processIdentifier
                       token:@"session-4"
                resetCommand:[self touchResetCommand]];
    }

    // The app does not keep the task object, so the watchdog must not depend on it.
    Auto deadline = [NSDate dateWithTimeIntervalSinceNow:8];
    while(![NSFileManager.defaultManager fileExistsAtPath:self.resetFilePath] && deadline.timeIntervalSinceNow > 0)
    {
        [NSThread sleepForTimeInterval:0.2];
    }
    XCTAssertTrue([NSFileManager.defaultManager fileExistsAtPath:self.resetFilePath]);
}

#pragma mark - Without permission

- (void)testBeginSessionFailsWithoutPermissionAndLeavesNoMarker
{
    if(SLTClosedLidSleepGuard.isAuthorized)
    {
        XCTSkip(@"This Mac already has the sudoers rule, so the session would really turn SleepDisabled on.");
    }

    Auto started = [SLTClosedLidSleepGuard beginSessionWithWatchedProcessIdentifier:NSProcessInfo.processInfo.processIdentifier
                                                        caffeinateProcessIdentifier:NSProcessInfo.processInfo.processIdentifier];
    XCTAssertFalse(started);
    XCTAssertFalse([NSFileManager.defaultManager fileExistsAtPath:SLTClosedLidSleepGuard.markerPath]);
}

@end

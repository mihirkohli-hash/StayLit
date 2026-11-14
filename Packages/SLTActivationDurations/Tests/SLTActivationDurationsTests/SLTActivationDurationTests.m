//
//  SLTActivationDurationTests.m
//  SLTActivationDurationsTests
//
//

#import <XCTest/XCTest.h>
#import <SLTCommon/SLTCommon.h>
#import <SLTActivationDurations/SLTActivationDurations.h>

@interface SLTActivationDurationTests : XCTestCase
@end

@implementation SLTActivationDurationTests

- (void)testIndefiniteActivationDuration
{
    Auto duration = SLTActivationDuration.indefiniteActivationDuration;
    XCTAssertEqual(duration.seconds, SLTActivationDurationIndefinite);
    XCTAssertEqualObjects(duration, SLTActivationDuration.indefiniteActivationDuration);
}

- (void)testSecondsInitializer
{
    NSTimeInterval expectedSeconds = 3400.0f;
    Auto duration = [[SLTActivationDuration alloc] initWithSeconds:expectedSeconds];
    XCTAssertEqual(duration.seconds, expectedSeconds);
}

- (void)testHoursMinutesSecondsInitializer
{
    NSTimeInterval expectedSeconds = 30615;
    Auto duration = [[SLTActivationDuration alloc] initWithHours:8 minutes:30 seconds:15];
    XCTAssertEqual(duration.seconds, expectedSeconds);
}

- (void)testEquatable
{
    NSTimeInterval expectedSeconds = 30615;
    XCTAssertEqualObjects([[SLTActivationDuration alloc] initWithSeconds:expectedSeconds],
                          [[SLTActivationDuration alloc] initWithSeconds:expectedSeconds]);
    XCTAssertTrue([[[SLTActivationDuration alloc] initWithSeconds:expectedSeconds]
                   isEqualToActivationDuration:[[SLTActivationDuration alloc]
                                                initWithSeconds:expectedSeconds]]);
    XCTAssertFalse([[[SLTActivationDuration alloc] initWithSeconds:expectedSeconds]
                   isEqualToActivationDuration:[[SLTActivationDuration alloc]
                                                initWithSeconds:0]]);
}

- (void)testArchiving
{
    NSTimeInterval expectedSeconds = 30615;
    Auto duration = [[SLTActivationDuration alloc] initWithSeconds:expectedSeconds];
    NSError *error;
    Auto data = [NSKeyedArchiver archivedDataWithRootObject:duration requiringSecureCoding:YES error:&error];
    XCTAssertNotNil(data);
    XCTAssertNil(error);
    
    Auto unarchivedDuration = (SLTActivationDuration *)[NSKeyedUnarchiver
                                                        unarchivedObjectOfClass:[SLTActivationDuration class]
                                                        fromData:data
                                                        error:&error];
    XCTAssertNotNil(unarchivedDuration);
    XCTAssertNil(error);
    XCTAssertEqualObjects(duration, unarchivedDuration);
}

- (void)testDefaultActivationDurations
{
    Auto durations = SLTActivationDuration.defaultActivationDurations;
    XCTAssertEqual(durations.count, 7);
    XCTAssertEqual(durations[0].seconds, 300.0f);
    XCTAssertEqual(durations[1].seconds, 600.0f);
    XCTAssertEqual(durations[2].seconds, 900.0f);
    XCTAssertEqual(durations[3].seconds, 1800.0f);
    XCTAssertEqual(durations[4].seconds, 3600.0f);
    XCTAssertEqual(durations[5].seconds, 7200.0f);
    XCTAssertEqual(durations[6].seconds, 18000.0f);
}

@end

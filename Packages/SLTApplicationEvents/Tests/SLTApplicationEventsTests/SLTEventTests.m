//
//  SLTEventTests.m
//  SLTApplicationEventsTests
//
//

#import <XCTest/XCTest.h>
#import <SLTCommon/SLTCommon.h>
#import <SLTApplicationEvents/SLTApplicationEvents.h>

@interface SLTEventTests : XCTestCase
@end

@implementation SLTEventTests

- (void)testInitializer
{
    Auto expectedName = @"EVENT_NAME";
    Auto expectedArguments = @{ @"KEY_1": @1, @"KEY_2": @YES };
    Auto event = [[SLTEvent alloc] initWithName:expectedName arguments:expectedArguments];
    XCTAssertEqualObjects(event.name, expectedName);
    XCTAssertEqualObjects(event.arguments, expectedArguments);
    
    Auto event2 = [[SLTEvent alloc] initWithName:expectedName arguments:nil];
    XCTAssertEqualObjects(event2.name, expectedName);
    XCTAssertNil(event2.arguments);
}

- (void)testEquatable
{
    Auto expectedName = @"EVENT_NAME";
    Auto expectedArguments = @{ @"KEY_1": @1, @"KEY_2": @YES };
    Auto event = [[SLTEvent alloc] initWithName:expectedName arguments:expectedArguments];
    XCTAssertEqualObjects(event, [[SLTEvent alloc] initWithName:expectedName arguments:expectedArguments]);
    
    Auto nilArgumentsEvent = [[SLTEvent alloc] initWithName:expectedName arguments:nil];
    XCTAssertNotEqualObjects(event, nilArgumentsEvent);
    
    Auto otherEvent = [[SLTEvent alloc] initWithName:@"OTHER_EVENT" arguments:@{}];
    XCTAssertNotEqualObjects(event, otherEvent);
}

- (void)testCopying
{
    Auto expectedName = @"EVENT_NAME";
    Auto expectedArguments = @{ @"KEY_1": @1, @"KEY_2": @YES };
    Auto event = [[SLTEvent alloc] initWithName:expectedName arguments:expectedArguments];
    XCTAssertEqualObjects(event, [event copy]);
    
    Auto nilArgumentsEvent = [[SLTEvent alloc] initWithName:expectedName arguments:nil];
    XCTAssertEqualObjects(nilArgumentsEvent, [nilArgumentsEvent copy]);
}

@end

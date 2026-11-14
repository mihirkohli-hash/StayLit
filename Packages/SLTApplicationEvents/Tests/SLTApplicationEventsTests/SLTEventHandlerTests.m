//
//  SLTEventHandlerTests.m
//  SLTApplicationEventsTests
//
//

#import <XCTest/XCTest.h>
#import <SLTCommon/SLTCommon.h>
#import <SLTApplicationEvents/SLTApplicationEvents.h>

@interface SLTEventHandler (Private)
@property (nonatomic) NSMapTable *eventTable;
@end

@interface SLTEventHandlerTests : XCTestCase
@property (nonatomic) SLTEventHandler *eventHandler;
@end

@implementation SLTEventHandlerTests

- (void)setUp
{
    [super setUp];
    
    self.eventHandler = [SLTEventHandler new];
}

- (void)testDefaultHandler
{
    XCTAssertEqual(SLTEventHandler.defaultHandler, SLTEventHandler.defaultHandler);
    XCTAssertEqualObjects(SLTEventHandler.defaultHandler, SLTEventHandler.defaultHandler);
    XCTAssertNotEqual(SLTEventHandler.defaultHandler, [SLTEventHandler new]);
    XCTAssertNotEqualObjects(SLTEventHandler.defaultHandler, [SLTEventHandler new]);
}

- (void)testRegisterAndRemoveAction
{
    Auto eventHandler = self.eventHandler;
    XCTAssertEqual(eventHandler.eventTable.count, 0);
    
    Auto expectedActionName = @"ACTION_NAME";
    [eventHandler registerActionNamed:expectedActionName block:^(SLTEvent *event) {}];
    XCTAssertNotNil([eventHandler.eventTable objectForKey:expectedActionName]);
    
    [eventHandler registerActionNamed:expectedActionName block:^(SLTEvent *event) {}];
    XCTAssertEqual(eventHandler.eventTable.count, 1);
    
    [eventHandler removeActionNamed:expectedActionName];
    XCTAssertEqual(eventHandler.eventTable.count, 0);
    
    [eventHandler removeActionNamed:expectedActionName];
    [eventHandler removeActionNamed:@"UNKNOWN_NAME"];
}

- (void)testHandleEvent
{
    Auto eventHandler = self.eventHandler;
    
    Auto expectedURL = [NSURL URLWithString:@"appscheme:///deactivate"];
    Auto expectedName = @"deactivate";
    
    Auto expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    
    [eventHandler registerActionNamed:expectedName block:^(SLTEvent *event) {
        XCTAssertEqualObjects(event.name, expectedName);
        XCTAssertNil(event.arguments);
        [expectation fulfill];
    }];
    [eventHandler handleEventForURL:expectedURL];
    
    [self waitForExpectations:@[expectation] timeout:5.0f];
}

- (void)testHandleEventWithArguments
{
    Auto eventHandler = self.eventHandler;
    
    Auto expectedURL = [NSURL URLWithString:@"appscheme:///activate?seconds=5"];
    Auto expectedName = @"activate";
    Auto expectedArguments = @{ @"seconds": @"5" };
    
    Auto expectation = [self expectationWithDescription:NSStringFromSelector(_cmd)];
    
    [eventHandler registerActionNamed:expectedName block:^(SLTEvent *event) {
        XCTAssertEqualObjects(event.name, expectedName);
        XCTAssertEqualObjects(event.arguments, expectedArguments);
        [expectation fulfill];
    }];
    
    [eventHandler registerActionNamed:@"deactivate" block:^(SLTEvent *event) {
        XCTFail();
    }];
    [eventHandler handleEventForURL:expectedURL];
    
    [self waitForExpectations:@[expectation] timeout:5.0f];
}

@end

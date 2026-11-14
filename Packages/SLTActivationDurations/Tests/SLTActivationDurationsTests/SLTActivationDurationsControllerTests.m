//
//  SLTActivationDurationsControllerTests.m
//  SLTActivationDurationsTests
//
//

#import <XCTest/XCTest.h>
#import <SLTCommon/SLTCommon.h>
#import <SLTActivationDurations/SLTActivationDurations.h>

@interface SLTActivationDurationsControllerTests : XCTestCase
@property (nonatomic) SLTActivationDurationsController *controller;
@end

@implementation SLTActivationDurationsControllerTests

- (void)setUp
{
    [super setUp];
    
    Auto defaults = NSUserDefaults.standardUserDefaults;
    self.controller = [[SLTActivationDurationsController alloc] initWithUserDefaults:defaults];
    [self.controller resetActivationDurations];
    self.controller.defaultActivationDuration = SLTActivationDuration.indefiniteActivationDuration;
}

- (void)testSharedController
{
    XCTAssertEqual(SLTActivationDurationsController.sharedController, SLTActivationDurationsController.sharedController);
    XCTAssertEqualObjects(SLTActivationDurationsController.sharedController, SLTActivationDurationsController.sharedController);
    XCTAssertNotEqual(SLTActivationDurationsController.sharedController, self.controller);
    XCTAssertNotEqualObjects(SLTActivationDurationsController.sharedController, self.controller);
}

- (void)testInitializer
{
    Auto controller = self.controller;
    XCTAssertNotNil(controller);
    XCTAssertEqual(controller.userDefaults, NSUserDefaults.standardUserDefaults);
    XCTAssertEqualObjects(controller.defaultActivationDuration, SLTActivationDuration.indefiniteActivationDuration);
    
    Auto expectedDurations = [NSMutableArray<SLTActivationDuration *>
                              arrayWithObject:SLTActivationDuration.indefiniteActivationDuration];
    [expectedDurations addObjectsFromArray:SLTActivationDuration.defaultActivationDurations];
    XCTAssertEqualObjects(controller.activationDurations, expectedDurations);
}

- (void)testDefaultActivationDuration
{
    Auto controller = self.controller;
    
    Auto newDefault = controller.activationDurations[2];
    controller.defaultActivationDuration = newDefault;
    XCTAssertEqualObjects(controller.defaultActivationDuration, newDefault);
}

- (void)testAddAndRemoveActivationDuration
{
    Auto controller = self.controller;
    
    Auto newDuration = [[SLTActivationDuration alloc] initWithSeconds:1986.0f];
    XCTAssertTrue([controller addActivationDuration:newDuration]);
    XCTAssertTrue([controller.activationDurations containsObject:newDuration]);
    
    Auto duplicateDuration = [[SLTActivationDuration alloc] initWithSeconds:1986.0f];
    XCTAssertFalse([controller addActivationDuration:duplicateDuration]);
    
    Auto notAddedDuration = [[SLTActivationDuration alloc] initWithSeconds:2063.0f];
    XCTAssertFalse([controller.activationDurations containsObject:notAddedDuration]);
    XCTAssertFalse([controller removeActivationDuration:notAddedDuration]);
    
    [controller addActivationDuration:notAddedDuration];
    XCTAssertTrue([controller removeActivationDuration:notAddedDuration]);
}

- (void)testRemoveActivationDurationAtIndex
{
    Auto controller = self.controller;
    
    Auto count = controller.activationDurations.count;
    for(NSInteger i = 0; i < count; i++)
    {
        if(i == 0)
        {
            // The indefinite duration cannot be removed
            XCTAssertFalse([controller removeActivationDurationAtIndex:0]);
            continue;
        }
        XCTAssertTrue([controller removeActivationDurationAtIndex:1]);
    }
    XCTAssertEqual(controller.activationDurations.count, 1);
    
    // Out of bounds
    XCTAssertFalse([controller removeActivationDurationAtIndex:2063]);
}

- (void)testSetActivationDurationAsDefaultAtIndex
{
    Auto controller = self.controller;
    XCTAssertEqualObjects(controller.defaultActivationDuration, SLTActivationDuration.indefiniteActivationDuration);
    
    Auto secondDuration = controller.activationDurations[2];
    [controller setActivationDurationAsDefaultAtIndex:2];
    XCTAssertEqualObjects(controller.defaultActivationDuration, secondDuration);
    
    // Out of bounds
    [controller setActivationDurationAsDefaultAtIndex:2063];
    XCTAssertEqualObjects(controller.defaultActivationDuration, secondDuration);
}

- (void)testResetActivationDurations
{
    Auto controller = self.controller;
    XCTAssertEqual(self.controller.activationDurations.count, 8);
    
    [controller removeActivationDurationAtIndex:1];
    [controller removeActivationDurationAtIndex:1];
    [controller removeActivationDurationAtIndex:1];
    
    Auto duration = [[SLTActivationDuration alloc] initWithSeconds:1986.0f];
    [controller addActivationDuration:duration];
    
    XCTAssertEqual(self.controller.activationDurations.count, 6);
    
    [controller resetActivationDurations];
    Auto expectedDurations = [NSMutableArray<SLTActivationDuration *>
                              arrayWithObject:SLTActivationDuration.indefiniteActivationDuration];
    [expectedDurations addObjectsFromArray:SLTActivationDuration.defaultActivationDurations];
    XCTAssertEqualObjects(controller.activationDurations, expectedDurations);
}

- (void)testDidChangeNotification
{
    Auto controller = self.controller;
    
    Auto addExpectation = [[XCTNSNotificationExpectation alloc] initWithName:SLTActivationDurationsDidChangeNotification
                                                                      object:controller];
    Auto newDuration = [[SLTActivationDuration alloc] initWithSeconds:1986.0f];
    XCTAssertTrue([controller addActivationDuration:newDuration]);
    XCTAssertTrue([controller.activationDurations containsObject:newDuration]);
    [self waitForExpectations:@[addExpectation] timeout:5.0f];
    
    Auto defaultExpectation = [[XCTNSNotificationExpectation alloc] initWithName:SLTActivationDurationsDidChangeNotification
                                                                         object:controller];
    controller.defaultActivationDuration = newDuration;
    [self waitForExpectations:@[defaultExpectation] timeout:5.0f];
    
    Auto removeExpectation = [[XCTNSNotificationExpectation alloc] initWithName:SLTActivationDurationsDidChangeNotification
                                                                         object:controller];
    [controller removeActivationDuration:newDuration];
    [self waitForExpectations:@[removeExpectation] timeout:5.0f];
    
    Auto resetExpectation = [[XCTNSNotificationExpectation alloc] initWithName:SLTActivationDurationsDidChangeNotification
                                                                         object:controller];
    [controller resetActivationDurations];
    [self waitForExpectations:@[resetExpectation] timeout:5.0f];
}

@end

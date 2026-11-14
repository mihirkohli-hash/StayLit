//
//  SLTUserDefaultsDefaultTimeIntervalTests.m
//  SLTActivationDurationsTests
//
//

#import <XCTest/XCTest.h>
#import <SLTCommon/SLTCommon.h>
#import <SLTActivationDurations/SLTActivationDurations.h>

@interface SLTUserDefaultsDefaultTimeIntervalTests : XCTestCase
@end

@implementation SLTUserDefaultsDefaultTimeIntervalTests

- (void)setUp
{
    [super setUp];
    
    Auto userDefaults = NSUserDefaults.standardUserDefaults;
    [userDefaults removeObjectForKey:SLTUserDefaultsKeyDefaultTimeInterval];
}

- (void)testDefaultTimeInterval
{
    Auto userDefaults = NSUserDefaults.standardUserDefaults;
    XCTAssertEqual(userDefaults.slt_defaultTimeInterval, 0.0f);
    
    userDefaults.slt_defaultTimeInterval = 18000.0f;
    XCTAssertEqual(userDefaults.slt_defaultTimeInterval, 18000.0f);
    
    // Test the decimal cut-off:
    userDefaults.slt_defaultTimeInterval = 432.5f;
    XCTAssertEqual(userDefaults.slt_defaultTimeInterval, 432.0f);
    
    userDefaults.slt_defaultTimeInterval = 0.0f;
    XCTAssertEqual(userDefaults.slt_defaultTimeInterval, 0.0f);
}

- (void)testDefaultTimeIntervalKeys
{
    Auto userDefaults = NSUserDefaults.standardUserDefaults;
    XCTAssertEqual(userDefaults.slt_defaultTimeInterval, 0.0f);
    XCTAssertEqual([userDefaults doubleForKey:SLTUserDefaultsKeyDefaultTimeInterval], 0.0f);
    
    userDefaults.slt_defaultTimeInterval = 18000.0f;
    XCTAssertEqual([userDefaults doubleForKey:SLTUserDefaultsKeyDefaultTimeInterval],
                   18000.0f);
    
    // Test the decimal cut-off:
    [userDefaults setObject:@432.5f forKey:SLTUserDefaultsKeyDefaultTimeInterval];
    XCTAssertEqual(userDefaults.slt_defaultTimeInterval, 432.0f);
    
    [userDefaults removeObjectForKey:SLTUserDefaultsKeyDefaultTimeInterval];
    XCTAssertEqual(userDefaults.slt_defaultTimeInterval, 0.0f);
}

@end

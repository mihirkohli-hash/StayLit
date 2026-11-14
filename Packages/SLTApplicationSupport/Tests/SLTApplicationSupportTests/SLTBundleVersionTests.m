//
//  SLTBundleVersionTests.m
//  SLTApplicationSupportTests
//
//

#import <XCTest/XCTest.h>
#import <SLTCommon/SLTCommon.h>
#import <SLTApplicationSupport/SLTApplicationSupport.h>

@interface SLTBundleVersionTests : XCTestCase
@property (nonatomic) NSBundle *bundle;
@end

@implementation SLTBundleVersionTests

- (void)setUp
{
    [super setUp];
    
    Auto parentBundle = SWIFTPM_MODULE_BUNDLE;
    Auto testBundleURL = [parentBundle URLForResource:@"TestBundle" withExtension:@"bundle"];
    self.bundle = [NSBundle bundleWithURL:testBundleURL];
}

- (void)testShortVersionString
{
    XCTAssertEqualObjects(self.bundle.slt_shortVersionString, @"1.2.3");
}

- (void)testBuildVersionString
{
    XCTAssertEqualObjects(self.bundle.slt_buildVersionString, @"1020301");
}

- (void)testFullVersionString
{
    XCTAssertEqualObjects(self.bundle.slt_fullVersionString, @"1.2.3 (1020301)");
}

- (void)testLocalizedCopyrightString
{
    XCTAssertEqualObjects(self.bundle.slt_localizedCopyrightString, @"A human-readable copyright.");
}

@end

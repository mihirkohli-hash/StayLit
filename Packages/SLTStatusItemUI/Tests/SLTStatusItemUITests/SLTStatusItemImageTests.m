//
//  SLTStatusItemImageTests.m
//  SLTStatusItemUI
//
//  Created by Mihir Kohli on 2026.
//

#import <XCTest/XCTest.h>
#import <SLTCommon/SLTCommon.h>
#import <SLTApplicationSupport/SLTApplicationSupport.h>
#import <SLTStatusItemUI/SLTStatusItemImageProvider.h>
#import "../../Sources/SLTStatusItemUI/SLTStatusItemImageProvider/NSImage+SLTStatusItemImage.h"

// How many pixels of each kind an image has once it is drawn.
typedef struct {
    NSUInteger white;       // opaque pixels with a white color
    NSUInteger black;       // opaque pixels with a black color
    NSUInteger translucent; // pixels that are neither transparent nor opaque, such as a dimmed screen
} SLTPixelCounts;

static const NSUInteger SLTRenderScale = 8;

static SLTPixelCounts SLTCountPixels(NSImage *image)
{
    Auto width = (NSInteger)(image.size.width * SLTRenderScale);
    Auto height = (NSInteger)(image.size.height * SLTRenderScale);
    Auto bitmap = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL
                                                          pixelsWide:width
                                                          pixelsHigh:height
                                                       bitsPerSample:8
                                                     samplesPerPixel:4
                                                            hasAlpha:YES
                                                            isPlanar:NO
                                                      colorSpaceName:NSDeviceRGBColorSpace
                                                         bytesPerRow:0
                                                        bitsPerPixel:0];
    [NSGraphicsContext saveGraphicsState];
    NSGraphicsContext.currentContext = [NSGraphicsContext graphicsContextWithBitmapImageRep:bitmap];
    [image drawInRect:NSMakeRect(0, 0, width, height)];
    [NSGraphicsContext restoreGraphicsState];

    SLTPixelCounts counts = {0, 0, 0};
    for(NSInteger y = 0; y < height; y++)
    {
        for(NSInteger x = 0; x < width; x++)
        {
            Auto color = [bitmap colorAtX:x y:y];
            if(color.alphaComponent > 0.98)
            {
                if(color.redComponent > 0.98 && color.greenComponent > 0.98 && color.blueComponent > 0.98) { counts.white++; }
                if(color.redComponent < 0.02 && color.greenComponent < 0.02 && color.blueComponent < 0.02) { counts.black++; }
            }
            else if(color.alphaComponent > 0.1)
            {
                counts.translucent++;
            }
        }
    }
    return counts;
}

@interface SLTStatusItemImageTests : XCTestCase
@property (nonatomic, copy, nullable) id previousColorValue;
@end

@implementation SLTStatusItemImageTests

- (void)setUp
{
    [super setUp];
    self.previousColorValue = [NSUserDefaults.standardUserDefaults objectForKey:SLTUserDefaultsKeyMenuBarIconColor];
}

- (void)tearDown
{
    if(self.previousColorValue) { [NSUserDefaults.standardUserDefaults setObject:self.previousColorValue forKey:SLTUserDefaultsKeyMenuBarIconColor]; }
    else { [NSUserDefaults.standardUserDefaults removeObjectForKey:SLTUserDefaultsKeyMenuBarIconColor]; }
    [super tearDown];
}

#pragma mark - Tinting

- (void)testWhiteIconIsNotATemplateAndHasOnlyWhitePixels
{
    Auto image = [NSImage slt_menuBarIconImageFromTemplateImage:NSImage.slt_defaultInactiveIconImage color:SLTMenuBarIconColorWhite];
    XCTAssertFalse(image.isTemplate, @"A fixed color must not be recolored by macOS.");

    Auto counts = SLTCountPixels(image);
    XCTAssertGreaterThan(counts.white, 500u);
    XCTAssertEqual(counts.black, 0u);
}

- (void)testDarkIconIsNotATemplateAndHasOnlyBlackPixels
{
    Auto image = [NSImage slt_menuBarIconImageFromTemplateImage:NSImage.slt_defaultInactiveIconImage color:SLTMenuBarIconColorDark];
    XCTAssertFalse(image.isTemplate);

    Auto counts = SLTCountPixels(image);
    XCTAssertGreaterThan(counts.black, 500u);
    XCTAssertEqual(counts.white, 0u);
}

- (void)testFollowSystemKeepsTheTemplateImage
{
    Auto templateImage = NSImage.slt_defaultActiveIconImage;
    Auto image = [NSImage slt_menuBarIconImageFromTemplateImage:templateImage color:SLTMenuBarIconColorFollowSystem];

    XCTAssertTrue(image == templateImage, @"Follow system must hand back the template image itself.");
    XCTAssertTrue(image.isTemplate);
}

- (void)testTintingKeepsTheTranslucentScreenOfTheActiveIcon
{
    // The active icon has a lit, translucent screen and the inactive icon has a dark, solid one.
    // Tinting must not flatten that difference, or the two states look the same.
    for(NSNumber *colorValue in @[@(SLTMenuBarIconColorWhite), @(SLTMenuBarIconColorDark)])
    {
        Auto color = (SLTMenuBarIconColor)colorValue.integerValue;
        Auto active = SLTCountPixels([NSImage slt_menuBarIconImageFromTemplateImage:NSImage.slt_defaultActiveIconImage color:color]);
        Auto inactive = SLTCountPixels([NSImage slt_menuBarIconImageFromTemplateImage:NSImage.slt_defaultInactiveIconImage color:color]);

        XCTAssertGreaterThan(active.translucent, 1000u, @"The lit screen should stay translucent for color %@", colorValue);
        XCTAssertGreaterThan(active.translucent, inactive.translucent * 5, @"Active and inactive must differ for color %@", colorValue);
    }
}

- (void)testTintedImageKeepsTheSizeOfTheTemplate
{
    Auto templateImage = NSImage.slt_defaultActiveIconImage;
    Auto image = [NSImage slt_menuBarIconImageFromTemplateImage:templateImage color:SLTMenuBarIconColorWhite];
    XCTAssertEqual(image.size.width, templateImage.size.width);
    XCTAssertEqual(image.size.height, templateImage.size.height);
}

#pragma mark - Provider

- (void)testProviderFollowsTheStoredColor
{
    Auto provider = SLTStatusItemImageProvider.standardProvider;

    NSUserDefaults.standardUserDefaults.slt_menuBarIconColor = SLTMenuBarIconColorWhite;
    XCTAssertFalse(provider.activeIconImage.isTemplate);
    XCTAssertGreaterThan(SLTCountPixels(provider.inactiveIconImage).white, 500u);

    NSUserDefaults.standardUserDefaults.slt_menuBarIconColor = SLTMenuBarIconColorDark;
    XCTAssertFalse(provider.activeIconImage.isTemplate);
    XCTAssertGreaterThan(SLTCountPixels(provider.inactiveIconImage).black, 500u);

    NSUserDefaults.standardUserDefaults.slt_menuBarIconColor = SLTMenuBarIconColorFollowSystem;
    XCTAssertTrue(provider.activeIconImage.isTemplate);
    XCTAssertTrue(provider.inactiveIconImage.isTemplate);
}

- (void)testProviderDefaultsToWhiteWhenNothingIsStored
{
    [NSUserDefaults.standardUserDefaults removeObjectForKey:SLTUserDefaultsKeyMenuBarIconColor];

    Auto image = SLTStatusItemImageProvider.standardProvider.inactiveIconImage;
    XCTAssertFalse(image.isTemplate);
    XCTAssertGreaterThan(SLTCountPixels(image).white, 500u);
}

- (void)testProviderReturnsTheSameInstanceUntilTheColorChanges
{
    Auto provider = SLTStatusItemImageProvider.standardProvider;

    NSUserDefaults.standardUserDefaults.slt_menuBarIconColor = SLTMenuBarIconColorWhite;
    Auto first = provider.activeIconImage;
    XCTAssertTrue(first == provider.activeIconImage, @"The status item compares images, so the instance must be stable.");

    NSUserDefaults.standardUserDefaults.slt_menuBarIconColor = SLTMenuBarIconColorDark;
    Auto second = provider.activeIconImage;
    XCTAssertTrue(first != second);

    NSUserDefaults.standardUserDefaults.slt_menuBarIconColor = SLTMenuBarIconColorWhite;
    XCTAssertTrue(first == provider.activeIconImage, @"Switching back reuses the cached white image.");
}

- (void)testProviderIgnoresAnUnknownStoredColor
{
    [NSUserDefaults.standardUserDefaults setInteger:42 forKey:SLTUserDefaultsKeyMenuBarIconColor];

    Auto image = SLTStatusItemImageProvider.standardProvider.inactiveIconImage;
    XCTAssertFalse(image.isTemplate);
    XCTAssertGreaterThan(SLTCountPixels(image).white, 500u, @"A corrupt value falls back to white.");
}

@end

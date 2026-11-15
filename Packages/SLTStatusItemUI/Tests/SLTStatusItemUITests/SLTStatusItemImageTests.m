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
    double alphaSum;        // total opacity, which grows with the brightness of the screen
    NSUInteger colored;     // opaque-enough pixels whose color is clearly not white, black or gray
    NSUInteger lightBody;   // mostly opaque light pixels, which includes the 85% opaque label color
    NSUInteger darkBody;    // mostly opaque dark pixels
    NSUInteger redHue;      // colored pixels where red is the strongest channel
    NSUInteger greenHue;    // colored pixels where green is the strongest channel
    NSUInteger blueHue;     // colored pixels where blue is the strongest channel
    double lumaSum;         // total brightness weighted by opacity, which moves when the screen color moves
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

    SLTPixelCounts counts = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
    for(NSInteger y = 0; y < height; y++)
    {
        for(NSInteger x = 0; x < width; x++)
        {
            Auto color = [bitmap colorAtX:x y:y];
            counts.alphaSum += color.alphaComponent;
            counts.lumaSum += color.alphaComponent * (0.3 * color.redComponent + 0.59 * color.greenComponent + 0.11 * color.blueComponent);
            if(color.alphaComponent > 0.5)
            {
                if(MIN(MIN(color.redComponent, color.greenComponent), color.blueComponent) > 0.9) { counts.lightBody++; }
                if(MAX(MAX(color.redComponent, color.greenComponent), color.blueComponent) < 0.1) { counts.darkBody++; }
            }
            if(color.alphaComponent > 0.3 && (MAX(MAX(color.redComponent, color.greenComponent), color.blueComponent) - MIN(MIN(color.redComponent, color.greenComponent), color.blueComponent)) > 0.25)
            {
                counts.colored++;
                if(color.redComponent > color.greenComponent && color.redComponent > color.blueComponent) { counts.redHue++; }
                else if(color.greenComponent > color.redComponent && color.greenComponent > color.blueComponent) { counts.greenHue++; }
                else if(color.blueComponent > color.redComponent && color.blueComponent > color.greenComponent) { counts.blueHue++; }
            }
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

#pragma mark - Pulse frames

- (void)testPulseFramesCoverOneFullCycle
{
    Auto frames = [NSImage slt_defaultPulseFramesForColor:SLTMenuBarIconColorWhite pulseColor:SLTMenuBarIconPulseColorAccent];
    XCTAssertEqual(frames.count, SLTStatusItemPulseFrameCount);
    XCTAssertEqual(frames.count, 16u);

    Auto iconSize = NSImage.slt_defaultActiveIconImage.size;
    for(NSImage *frame in frames)
    {
        XCTAssertFalse(frame.isTemplate, @"A colored screen cannot be a template image.");
        XCTAssertEqual(frame.size.width, iconSize.width);
        XCTAssertEqual(frame.size.height, iconSize.height);
    }
}

- (void)testPulseKeepsTheMonitorBodySteadyInEveryColor
{
    // Only the screen may change. The body is the opaque part, so its pixel count must not move.
    for(NSNumber *colorValue in @[@(SLTMenuBarIconColorWhite), @(SLTMenuBarIconColorDark)])
    {
        Auto color = (SLTMenuBarIconColor)colorValue.integerValue;
        Auto frames = [NSImage slt_defaultPulseFramesForColor:color pulseColor:SLTMenuBarIconPulseColorAccent];
        Auto first = SLTCountPixels(frames.firstObject);

        for(NSImage *frame in frames)
        {
            Auto counts = SLTCountPixels(frame);
            if(color == SLTMenuBarIconColorWhite)
            {
                XCTAssertEqual(counts.white, first.white, @"The white body must not change between frames.");
                XCTAssertEqual(counts.black, 0u);
            }
            else
            {
                XCTAssertEqual(counts.black, first.black, @"The dark body must not change between frames.");
                XCTAssertEqual(counts.white, 0u);
            }
        }
        XCTAssertGreaterThan(color == SLTMenuBarIconColorWhite ? first.white : first.black, 500u);
    }
}

- (void)testPulseFramesChangeTheScreenColorSmoothly
{
    // The screen is opaque and its color moves from the body color to the pulse color, so the
    // total brightness is the signal. Full strength is the accent color, and the weakest frame is nearly white.
    Auto frames = [NSImage slt_defaultPulseFramesForColor:SLTMenuBarIconColorWhite pulseColor:SLTMenuBarIconPulseColorAccent];
    Auto strongest = SLTCountPixels(frames[0]).lumaSum;
    Auto weakest = SLTCountPixels(frames[8]).lumaSum;
    Auto swing = fabs(weakest - strongest);
    XCTAssertGreaterThan(swing, 100.0, @"The screen must clearly change.");

    // A smooth cosine over 16 frames moves at most sin(pi/16), about 0.2, of the swing per step.
    // A jump would be about half the swing. The wrap from the last frame to the first counts too.
    for(NSUInteger index = 0; index < frames.count; index++)
    {
        Auto current = SLTCountPixels(frames[index]).lumaSum;
        Auto next = SLTCountPixels(frames[(index + 1) % frames.count]).lumaSum;
        XCTAssertLessThan(fabs(current - next), swing * 0.25, @"Frame %lu and the next one differ too much", (unsigned long)index);
    }
}

- (void)testPulseIsVisibleOnAnyMenuBarBecauseTheScreenIsOpaque
{
    // The screen is a hole in the body, so any transparency would let the bar show through and
    // hide the pulse. Only the anti-aliased edge between screen and body may be partly transparent.
    // A fading screen would have thousands of such pixels, because its whole area would be.
    for(NSNumber *pulseColor in @[@(SLTMenuBarIconPulseColorContrast), @(SLTMenuBarIconPulseColorAccent), @(SLTMenuBarIconPulseColorGreen)])
    {
        Auto frames = [NSImage slt_defaultPulseFramesForColor:SLTMenuBarIconColorWhite pulseColor:(SLTMenuBarIconPulseColor)pulseColor.integerValue];
        for(NSImage *frame in frames)
        {
            Auto counts = SLTCountPixels(frame);
            XCTAssertLessThan(counts.translucent, 1500u, @"Pulse color %@ must not fade the screen with transparency", pulseColor);
        }
    }
}

- (void)testPulsingScreenUsesTheAccentColor
{
    Auto accent = [NSColor.controlAccentColor colorUsingColorSpace:NSColorSpace.deviceRGBColorSpace];
    Auto spread = MAX(MAX(accent.redComponent, accent.greenComponent), accent.blueComponent) - MIN(MIN(accent.redComponent, accent.greenComponent), accent.blueComponent);
    if(spread < 0.3)
    {
        XCTSkip(@"The macOS accent color is graphite, which has no color to look for.");
    }

    Auto counts = SLTCountPixels([NSImage slt_defaultPulseFramesForColor:SLTMenuBarIconColorWhite pulseColor:SLTMenuBarIconPulseColorAccent][0]);
    XCTAssertGreaterThan(counts.colored, 200u, @"The screen should be drawn in the accent color.");
}

- (void)testFollowSystemBodyAdaptsToTheMenuBarAppearance
{
    Auto frames = [NSImage slt_defaultPulseFramesForColor:SLTMenuBarIconColorFollowSystem pulseColor:SLTMenuBarIconPulseColorAccent];

    __block SLTPixelCounts onDarkBar = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
    [[NSAppearance appearanceNamed:NSAppearanceNameDarkAqua] performAsCurrentDrawingAppearance:^{
        onDarkBar = SLTCountPixels(frames[0]);
    }];
    __block SLTPixelCounts onLightBar = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
    [[NSAppearance appearanceNamed:NSAppearanceNameAqua] performAsCurrentDrawingAppearance:^{
        onLightBar = SLTCountPixels(frames[0]);
    }];

    XCTAssertGreaterThan(onDarkBar.lightBody, 500u, @"On a dark menu bar the body is light.");
    XCTAssertEqual(onDarkBar.darkBody, 0u);
    XCTAssertGreaterThan(onLightBar.darkBody, 500u, @"On a light menu bar the body is dark.");
    XCTAssertEqual(onLightBar.lightBody, 0u);
}

- (void)testProviderOffersPulseFramesForTheBuiltInIconOnly
{
    [NSUserDefaults.standardUserDefaults removeObjectForKey:SLTUserDefaultsKeyMenuBarIconColor];
    XCTAssertEqual(SLTStatusItemImageProvider.standardProvider.activePulseFrames.count, SLTStatusItemPulseFrameCount);
}

- (void)testProviderCachesPulseFramesPerColor
{
    Auto provider = SLTStatusItemImageProvider.standardProvider;

    NSUserDefaults.standardUserDefaults.slt_menuBarIconColor = SLTMenuBarIconColorWhite;
    Auto white = provider.activePulseFrames;
    XCTAssertTrue(white == provider.activePulseFrames, @"The frames must not be rebuilt on every tick.");

    NSUserDefaults.standardUserDefaults.slt_menuBarIconColor = SLTMenuBarIconColorDark;
    XCTAssertTrue(white != provider.activePulseFrames);
}

#pragma mark - Pulse colors

- (SLTPixelCounts)countsOfFirstPulseFrameWithPulseColor:(SLTMenuBarIconPulseColor)pulseColor
{
    Auto frames = [NSImage slt_defaultPulseFramesForColor:SLTMenuBarIconColorWhite pulseColor:pulseColor];
    return SLTCountPixels(frames.firstObject); // the first frame is the screen at full strength
}

- (void)testGreenPulseDrawsAGreenScreen
{
    Auto counts = [self countsOfFirstPulseFrameWithPulseColor:SLTMenuBarIconPulseColorGreen];
    XCTAssertGreaterThan(counts.greenHue, 200u);
    XCTAssertEqual(counts.redHue + counts.blueHue, 0u);
}

- (void)testRedPulseDrawsARedScreen
{
    Auto counts = [self countsOfFirstPulseFrameWithPulseColor:SLTMenuBarIconPulseColorRed];
    XCTAssertGreaterThan(counts.redHue, 200u);
    XCTAssertEqual(counts.greenHue + counts.blueHue, 0u);
}

- (void)testOrangePulseDrawsAnOrangeScreen
{
    // Orange has red as its strongest channel and green as its second.
    Auto counts = [self countsOfFirstPulseFrameWithPulseColor:SLTMenuBarIconPulseColorOrange];
    XCTAssertGreaterThan(counts.redHue, 200u);
    XCTAssertEqual(counts.greenHue + counts.blueHue, 0u);
}

- (void)testBlueAndPurplePulsesDrawABluishScreen
{
    for(NSNumber *pulseColor in @[@(SLTMenuBarIconPulseColorBlue), @(SLTMenuBarIconPulseColorPurple)])
    {
        Auto counts = [self countsOfFirstPulseFrameWithPulseColor:(SLTMenuBarIconPulseColor)pulseColor.integerValue];
        XCTAssertGreaterThan(counts.blueHue, 200u, @"Pulse color %@", pulseColor);
        XCTAssertEqual(counts.greenHue, 0u);
    }
}

- (void)testSameAsIconPulseDrawsNoColorAtAll
{
    // The screen takes the color of the body, so only its brightness changes.
    Auto counts = [self countsOfFirstPulseFrameWithPulseColor:SLTMenuBarIconPulseColorSameAsIcon];
    XCTAssertEqual(counts.colored, 0u);
    XCTAssertGreaterThan(counts.white, 500u);
}

- (void)testEveryPulseColorKeepsTheBodySteadyAndTheScreenBreathing
{
    Auto firstChoice = (NSInteger)SLTMenuBarIconPulseColorAccent;
    Auto lastChoice = (NSInteger)SLTMenuBarIconPulseColorContrast;
    for(NSInteger choice = firstChoice; choice <= lastChoice; choice++)
    {
        Auto frames = [NSImage slt_defaultPulseFramesForColor:SLTMenuBarIconColorWhite pulseColor:(SLTMenuBarIconPulseColor)choice];
        XCTAssertEqual(frames.count, SLTStatusItemPulseFrameCount);

        // Frame 0 has the screen at full strength, and with "same as icon" that opaque screen would count as body.
        // Frames 4 and 8 both have a translucent screen, so their opaque white pixels are the body only.
        Auto strongest = SLTCountPixels(frames[0]);
        Auto middle = SLTCountPixels(frames[4]);
        Auto weakest = SLTCountPixels(frames[8]);
        XCTAssertEqual(middle.white, weakest.white, @"The body must not change for pulse color %ld", (long)choice);
        // "Same as icon" can only change opacity. Every other color changes the screen color.
        Auto change = fabs(strongest.alphaSum - weakest.alphaSum) + fabs(strongest.lumaSum - weakest.lumaSum);
        XCTAssertGreaterThan(change, 50.0, @"The screen must change for pulse color %ld", (long)choice);
    }
}

- (void)testProviderCachesPulseFramesPerPulseColorToo
{
    Auto provider = SLTStatusItemImageProvider.standardProvider;
    Auto defaults = NSUserDefaults.standardUserDefaults;
    Auto previous = [defaults objectForKey:SLTUserDefaultsKeyMenuBarIconPulseColor];
    defaults.slt_menuBarIconColor = SLTMenuBarIconColorWhite;

    defaults.slt_menuBarIconPulseColor = SLTMenuBarIconPulseColorGreen;
    Auto green = provider.activePulseFrames;
    XCTAssertTrue(green == provider.activePulseFrames, @"The same colors reuse the cached frames.");

    defaults.slt_menuBarIconPulseColor = SLTMenuBarIconPulseColorRed;
    XCTAssertTrue(green != provider.activePulseFrames, @"A new pulse color needs new frames.");

    defaults.slt_menuBarIconPulseColor = SLTMenuBarIconPulseColorGreen;
    XCTAssertTrue(green == provider.activePulseFrames, @"Going back finds the green frames again.");

    if(previous) { [defaults setObject:previous forKey:SLTUserDefaultsKeyMenuBarIconPulseColor]; }
    else { [defaults removeObjectForKey:SLTUserDefaultsKeyMenuBarIconPulseColor]; }
}

#pragma mark - Contrast pulse color (the default)

- (void)testContrastPulseIsBlackOnAWhiteIcon
{
    Auto frames = [NSImage slt_defaultPulseFramesForColor:SLTMenuBarIconColorWhite pulseColor:SLTMenuBarIconPulseColorContrast];
    Auto counts = SLTCountPixels(frames[0]); // the screen at full strength
    XCTAssertGreaterThan(counts.white, 500u, @"The body stays white.");
    XCTAssertGreaterThan(counts.black, 200u, @"The screen is black.");
    XCTAssertEqual(counts.colored, 0u);
}

- (void)testContrastPulseIsWhiteOnADarkIcon
{
    Auto frames = [NSImage slt_defaultPulseFramesForColor:SLTMenuBarIconColorDark pulseColor:SLTMenuBarIconPulseColorContrast];
    Auto counts = SLTCountPixels(frames[0]);
    XCTAssertGreaterThan(counts.black, 500u, @"The body stays black.");
    XCTAssertGreaterThan(counts.white, 200u, @"The screen is white.");
    XCTAssertEqual(counts.colored, 0u);
}

- (void)testContrastPulseWithFollowSystemIsTheOppositeOfTheMenuBarText
{
    Auto frames = [NSImage slt_defaultPulseFramesForColor:SLTMenuBarIconColorFollowSystem pulseColor:SLTMenuBarIconPulseColorContrast];

    __block SLTPixelCounts onDarkBar = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
    [[NSAppearance appearanceNamed:NSAppearanceNameDarkAqua] performAsCurrentDrawingAppearance:^{ onDarkBar = SLTCountPixels(frames[0]); }];
    __block SLTPixelCounts onLightBar = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
    [[NSAppearance appearanceNamed:NSAppearanceNameAqua] performAsCurrentDrawingAppearance:^{ onLightBar = SLTCountPixels(frames[0]); }];

    XCTAssertGreaterThan(onDarkBar.lightBody, 500u, @"On a dark menu bar the body is light.");
    XCTAssertGreaterThan(onDarkBar.black, 200u, @"On a dark menu bar the screen is black.");
    XCTAssertGreaterThan(onLightBar.darkBody, 500u, @"On a light menu bar the body is dark.");
    XCTAssertGreaterThan(onLightBar.white, 200u, @"On a light menu bar the screen is white.");
}

- (void)testContrastPulseKeepsTheBodyAndFadesTheScreenBetweenBlackAndWhite
{
    for(NSNumber *iconColor in @[@(SLTMenuBarIconColorWhite), @(SLTMenuBarIconColorDark)])
    {
        Auto frames = [NSImage slt_defaultPulseFramesForColor:(SLTMenuBarIconColor)iconColor.integerValue pulseColor:SLTMenuBarIconPulseColorContrast];
        Auto strongest = SLTCountPixels(frames[0]);
        Auto weakest = SLTCountPixels(frames[8]);
        XCTAssertGreaterThan(fabs(strongest.lumaSum - weakest.lumaSum), 150.0, @"The screen must fade clearly for icon color %@", iconColor);
    }
}

- (void)testTheDefaultStoredSettingsGiveTheContrastPulse
{
    Auto defaults = NSUserDefaults.standardUserDefaults;
    Auto previousPulseColor = [defaults objectForKey:SLTUserDefaultsKeyMenuBarIconPulseColor];
    Auto previousIconColor = [defaults objectForKey:SLTUserDefaultsKeyMenuBarIconColor];
    [defaults removeObjectForKey:SLTUserDefaultsKeyMenuBarIconPulseColor];
    [defaults removeObjectForKey:SLTUserDefaultsKeyMenuBarIconColor];

    // With nothing stored the icon is white, so the pulse must be black.
    Auto counts = SLTCountPixels(SLTStatusItemImageProvider.standardProvider.activePulseFrames[0]);
    XCTAssertGreaterThan(counts.white, 500u);
    XCTAssertGreaterThan(counts.black, 200u);
    XCTAssertEqual(counts.colored, 0u);

    if(previousPulseColor) { [defaults setObject:previousPulseColor forKey:SLTUserDefaultsKeyMenuBarIconPulseColor]; }
    if(previousIconColor) { [defaults setObject:previousIconColor forKey:SLTUserDefaultsKeyMenuBarIconColor]; }
}

@end

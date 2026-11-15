//
//  NSImage+SLTStatusItemImage.m
//  SLTStatusItemUI
//
//

#import "NSImage+SLTStatusItemImage.h"
#import <SLTCommon/SLTCommon.h>
#import "NSURL+SLTStatusItemImage.h"

const NSImageName SLTStatusItemActiveImageName = @"ActiveIcon";
const NSImageName SLTStatusItemInactiveImageName = @"InactiveIcon";

@implementation NSImage (SLTStatusItemImage)

#pragma mark - Default Icon Images

+ (NSImage *)slt_defaultActiveIconImage
{
    return [self desktopSymbolWithLitScreen:YES];
}

+ (NSImage *)slt_defaultInactiveIconImage
{
    return [self desktopSymbolWithLitScreen:NO];
}

// The symbol draws its screen as a translucent layer, which looks lit. A palette
// configuration with one color for both layers makes the screen the same as the
// body, which looks switched off.
+ (NSImage *)desktopSymbolWithLitScreen:(BOOL)litScreen
{
    NSImage *image = [NSImage imageWithSystemSymbolName:@"desktopcomputer" accessibilityDescription:nil];
    if(!litScreen)
    {
        Auto configuration = [NSImageSymbolConfiguration configurationWithPaletteColors:@[NSColor.blackColor, NSColor.blackColor]];
        image = [image imageWithSymbolConfiguration:configuration];
    }
    image.template = YES;
    return image;
}

#pragma mark - Pulse Frames

const NSUInteger SLTStatusItemPulseFrameCount = 16;

// The pulse has to be visible against the icon itself. The screen is a hole in the body, so it
// is drawn straight onto the menu bar. A screen that only fades in transparency would blend
// into the bar, and a color equal to the bar would then not be seen at all. So the screen
// is opaque, and its color moves between the body color and the pulse color.
static NSColor *SLTResolvedColor(NSColor *color)
{
    // Dynamic colors are resolved here, against the appearance the image is drawn with.
    return [color colorUsingColorSpace:NSColorSpace.sRGBColorSpace] ?: color;
}

// The color the screen fades towards at full strength.
static NSColor *SLTPulseTargetColor(SLTMenuBarIconPulseColor pulseColor, NSColor *bodyColor)
{
    switch(pulseColor)
    {
        // The opposite of the body: black on a white body and white on a dark one.
        case SLTMenuBarIconPulseColorContrast: return SLTResolvedColor(bodyColor.brightnessComponent > 0.5 ? NSColor.blackColor : NSColor.whiteColor);
        case SLTMenuBarIconPulseColorGreen: return SLTResolvedColor(NSColor.systemGreenColor);
        case SLTMenuBarIconPulseColorBlue: return SLTResolvedColor(NSColor.systemBlueColor);
        case SLTMenuBarIconPulseColorOrange: return SLTResolvedColor(NSColor.systemOrangeColor);
        case SLTMenuBarIconPulseColorRed: return SLTResolvedColor(NSColor.systemRedColor);
        case SLTMenuBarIconPulseColorPurple: return SLTResolvedColor(NSColor.systemPurpleColor);
        case SLTMenuBarIconPulseColorSameAsIcon: return bodyColor;
        case SLTMenuBarIconPulseColorAccent: break;
    }
    return SLTResolvedColor(NSColor.controlAccentColor);
}

+ (NSArray<NSImage *> *)slt_defaultPulseFramesForColor:(SLTMenuBarIconColor)color
                                            pulseColor:(SLTMenuBarIconPulseColor)pulseColor
{
    Auto symbolSize = [NSImage imageWithSystemSymbolName:@"desktopcomputer" accessibilityDescription:nil].size;
    Auto frames = [NSMutableArray<NSImage *> arrayWithCapacity:SLTStatusItemPulseFrameCount];

    for(NSUInteger index = 0; index < SLTStatusItemPulseFrameCount; index++)
    {
        // The pulse starts at full strength and fades to a tenth and back.
        Auto phase = 2.0 * M_PI * (double)index / (double)SLTStatusItemPulseFrameCount;
        Auto strength = (CGFloat)(0.55 + 0.45 * cos(phase));

        Auto frame = [NSImage imageWithSize:symbolSize flipped:NO drawingHandler:^BOOL(NSRect rect) {
            // Plain colors are chosen here, from the appearance this frame is drawn with.
            // The symbol renderer then has no dynamic color to resolve.
            Auto match = [NSAppearance.currentDrawingAppearance bestMatchFromAppearancesWithNames:@[NSAppearanceNameAqua, NSAppearanceNameDarkAqua]];
            Auto darkMenuBar = [match isEqualToString:NSAppearanceNameDarkAqua];

            // Follow system is white on a dark menu bar and black on a light one.
            NSColor *bodyColor = darkMenuBar ? NSColor.whiteColor : NSColor.blackColor;
            if(color == SLTMenuBarIconColorWhite) { bodyColor = NSColor.whiteColor; }
            if(color == SLTMenuBarIconColorDark) { bodyColor = NSColor.blackColor; }
            bodyColor = SLTResolvedColor(bodyColor);

            NSColor *screenColor = nil;
            if(pulseColor == SLTMenuBarIconPulseColorSameAsIcon)
            {
                // Same color as the body, so only the opacity can change.
                screenColor = [bodyColor colorWithAlphaComponent:strength];
            }
            else
            {
                screenColor = [bodyColor blendedColorWithFraction:strength ofColor:SLTPulseTargetColor(pulseColor, bodyColor)] ?: bodyColor;
            }

            Auto configuration = [NSImageSymbolConfiguration configurationWithPaletteColors:@[bodyColor, screenColor]];
            Auto symbol = [[NSImage imageWithSystemSymbolName:@"desktopcomputer" accessibilityDescription:nil] imageWithSymbolConfiguration:configuration];
            [symbol drawInRect:rect];
            return YES;
        }];
        frame.template = NO;
        [frames addObject:frame];
    }
    return [frames copy];
}

#pragma mark - Icon Color

+ (NSImage *)slt_menuBarIconImageFromTemplateImage:(NSImage *)templateImage color:(SLTMenuBarIconColor)color
{
    if(color == SLTMenuBarIconColorFollowSystem)
    {
        return templateImage;
    }

    Auto fillColor = (color == SLTMenuBarIconColorDark) ? NSColor.blackColor : NSColor.whiteColor;

    // The drawing handler runs at the resolution of the screen, so the icon stays sharp
    // on every display. Source-atop keeps the shape and the translucent parts of the
    // template image and only replaces its color.
    Auto image = [NSImage imageWithSize:templateImage.size flipped:NO drawingHandler:^BOOL(NSRect rect) {
        [templateImage drawInRect:rect];
        [fillColor set];
        NSRectFillUsingOperation(rect, NSCompositingOperationSourceAtop);
        return YES;
    }];
    image.template = NO;
    return image;
}

#pragma mark - Custom Icon Images

+ (NSImage *)slt_customActiveIconImage
{
    return [self customIconNamed:SLTStatusItemActiveImageName];
}

+ (NSImage *)slt_customInactiveIconImage
{
    return [self customIconNamed:SLTStatusItemInactiveImageName];
}

#pragma mark -

+ (NSImage *)customIconNamed:(NSImageName)imageName
{
    NSParameterAssert(imageName);
    
    Auto fileURL = [NSURL slt_iconImageFileURLWithName:imageName isRetinaIcon:NO];
    Auto image = [[NSImage alloc] initWithContentsOfURL:fileURL];
    image.template = YES;
    
    Auto retinaFileURL = [NSURL slt_iconImageFileURLWithName:imageName isRetinaIcon:YES];
    Auto retinaRep = [NSImageRep imageRepWithContentsOfURL:retinaFileURL];
    if(retinaRep != nil)
    {
        [image addRepresentation:retinaRep];
    }
    
    return image;
}

@end

BOOL SLTCustomIconImageFilesExist()
{
    return SLTCustomIconImageFileExists(SLTStatusItemActiveImageName, NO)
    && SLTCustomIconImageFileExists(SLTStatusItemActiveImageName, YES)
    && SLTCustomIconImageFileExists(SLTStatusItemInactiveImageName, NO)
    && SLTCustomIconImageFileExists(SLTStatusItemInactiveImageName, YES);
}

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

+ (NSArray<NSImage *> *)slt_defaultPulseFramesForColor:(SLTMenuBarIconColor)color
{
    Auto symbolSize = [NSImage imageWithSystemSymbolName:@"desktopcomputer" accessibilityDescription:nil].size;
    Auto frames = [NSMutableArray<NSImage *> arrayWithCapacity:SLTStatusItemPulseFrameCount];

    for(NSUInteger index = 0; index < SLTStatusItemPulseFrameCount; index++)
    {
        // The screen starts at full strength and fades to about a third and back.
        Auto phase = 2.0 * M_PI * (double)index / (double)SLTStatusItemPulseFrameCount;
        Auto screenAlpha = (CGFloat)(0.675 + 0.325 * cos(phase));

        Auto frame = [NSImage imageWithSize:symbolSize flipped:NO drawingHandler:^BOOL(NSRect rect) {
            // Follow system uses the label color, which is white on a dark menu bar and black on a light one.
            NSColor *bodyColor = NSColor.labelColor;
            if(color == SLTMenuBarIconColorWhite) { bodyColor = NSColor.whiteColor; }
            if(color == SLTMenuBarIconColorDark) { bodyColor = NSColor.blackColor; }

            Auto screenColor = [NSColor.controlAccentColor colorWithAlphaComponent:screenAlpha];
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

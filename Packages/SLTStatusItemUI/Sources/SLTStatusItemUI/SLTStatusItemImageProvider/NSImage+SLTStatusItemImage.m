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
    return [self laptopSymbolWithSolidScreen:YES];
}

+ (NSImage *)slt_defaultInactiveIconImage
{
    return [self laptopSymbolWithSolidScreen:NO];
}

// The laptop symbol draws its screen as a translucent layer, which reads as
// "off". A palette configuration with one color for both layers makes the
// screen solid, which reads as "on".
+ (NSImage *)laptopSymbolWithSolidScreen:(BOOL)solidScreen
{
    NSImage *image = [NSImage imageWithSystemSymbolName:@"laptopcomputer" accessibilityDescription:nil];
    if(solidScreen)
    {
        Auto configuration = [NSImageSymbolConfiguration configurationWithPaletteColors:@[NSColor.blackColor, NSColor.blackColor]];
        image = [image imageWithSymbolConfiguration:configuration];
    }
    image.template = YES;
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

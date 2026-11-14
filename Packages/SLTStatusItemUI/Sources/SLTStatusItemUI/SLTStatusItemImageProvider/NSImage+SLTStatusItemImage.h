//
//  NSImage+SLTStatusItemImage.h
//  SLTStatusItemUI
//
//

#import <Cocoa/Cocoa.h>
#import <SLTCommon/SLTExport.h>
#import <SLTApplicationSupport/SLTApplicationSupport.h>

NS_ASSUME_NONNULL_BEGIN

SLT_EXPORT const NSImageName SLTStatusItemActiveImageName;
SLT_EXPORT const NSImageName SLTStatusItemInactiveImageName;

BOOL SLTCustomIconImageFilesExist(void);

@interface NSImage (SLTStatusItemImage)
@property (class, copy, nonatomic, readonly) NSImage *slt_defaultActiveIconImage;
@property (class, copy, nonatomic, readonly) NSImage *slt_defaultInactiveIconImage;

@property (class, copy, nonatomic, readonly) NSImage *slt_customActiveIconImage;
@property (class, copy, nonatomic, readonly) NSImage *slt_customInactiveIconImage;

/// The number of images in one pulse cycle.
extern const NSUInteger SLTStatusItemPulseFrameCount;

/// Returns the images of one pulse cycle for the built-in icon.
///
/// The monitor body keeps the icon color. Only the screen changes: it glows in the pulse color
/// and fades between bright and dim. The images are drawn on demand, so the body, the accent
/// color and the system colors follow the menu bar appearance and System Settings.
+ (NSArray<NSImage *> *)slt_defaultPulseFramesForColor:(SLTMenuBarIconColor)color
                                            pulseColor:(SLTMenuBarIconPulseColor)pulseColor;

/// Returns the template image drawn in the requested menu bar icon color.
///
/// White and dark return a new image with a fixed color. Follow system returns the
/// template image itself, so macOS draws it white or black to match the menu bar.
+ (NSImage *)slt_menuBarIconImageFromTemplateImage:(NSImage *)templateImage color:(SLTMenuBarIconColor)color;
@end

NS_ASSUME_NONNULL_END

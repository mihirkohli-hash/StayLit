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

/// Returns the template image drawn in the requested menu bar icon color.
///
/// White and dark return a new image with a fixed color. Follow system returns the
/// template image itself, so macOS draws it white or black to match the menu bar.
+ (NSImage *)slt_menuBarIconImageFromTemplateImage:(NSImage *)templateImage color:(SLTMenuBarIconColor)color;
@end

NS_ASSUME_NONNULL_END

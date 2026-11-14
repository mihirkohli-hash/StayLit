//
//  NSImage+SLTStatusItemImage.h
//  SLTStatusItemUI
//
//

#import <Cocoa/Cocoa.h>
#import <SLTCommon/SLTExport.h>

NS_ASSUME_NONNULL_BEGIN

SLT_EXPORT const NSImageName SLTStatusItemActiveImageName;
SLT_EXPORT const NSImageName SLTStatusItemInactiveImageName;

BOOL SLTCustomIconImageFilesExist(void);

@interface NSImage (SLTStatusItemImage)
@property (class, copy, nonatomic, readonly) NSImage *slt_defaultActiveIconImage;
@property (class, copy, nonatomic, readonly) NSImage *slt_defaultInactiveIconImage;

@property (class, copy, nonatomic, readonly) NSImage *slt_customActiveIconImage;
@property (class, copy, nonatomic, readonly) NSImage *slt_customInactiveIconImage;
@end

NS_ASSUME_NONNULL_END

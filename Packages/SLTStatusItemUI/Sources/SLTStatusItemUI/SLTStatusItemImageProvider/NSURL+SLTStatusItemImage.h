//
//  NSURL+SLTStatusItemImage.h
//  SLTStatusItemUI
//
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

BOOL SLTCustomIconImageFileExists(NSImageName, BOOL isRetinaIcon);

@interface NSURL (SLTStatusItemImage)
@property (class, nonatomic, readonly) NSURL *slt_documentsDirectoryURL;

+ (NSURL *)slt_iconImageFileURLWithName:(NSImageName)imageName
                           isRetinaIcon:(BOOL)isRetinaIcon;

@end

NS_ASSUME_NONNULL_END

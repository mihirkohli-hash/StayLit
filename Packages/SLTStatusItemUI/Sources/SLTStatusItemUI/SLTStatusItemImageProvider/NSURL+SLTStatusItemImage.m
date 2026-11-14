//
//  NSURL+SLTStatusItemImage.m
//  SLTStatusItemUI
//
//

#import "NSURL+SLTStatusItemImage.h"
#import <SLTCommon/SLTCommon.h>

@implementation NSURL (SLTStatusItemImage)

+ (NSURL *)slt_documentsDirectoryURL
{
    return [NSFileManager.defaultManager URLsForDirectory:NSDocumentDirectory
                                                inDomains:NSUserDomainMask].lastObject;
}

+ (NSURL *)slt_iconImageFileURLWithName:(NSImageName)imageName isRetinaIcon:(BOOL)isRetinaIcon
{
    NSParameterAssert(imageName);
    Auto suffix = isRetinaIcon ? @"@2x" : @"";
    Auto composedName = [NSString stringWithFormat:@"%@%@.png", imageName, suffix];
    return [NSURL.slt_documentsDirectoryURL URLByAppendingPathComponent:composedName];
}

@end

BOOL SLTCustomIconImageFileExists(NSImageName imageName, BOOL isRetinaIcon)
{
    NSCParameterAssert(imageName);
    
    Auto fileManager = NSFileManager.defaultManager;
    Auto fileURL = [NSURL slt_iconImageFileURLWithName:imageName isRetinaIcon:isRetinaIcon];
    return [fileManager fileExistsAtPath:fileURL.path];
}

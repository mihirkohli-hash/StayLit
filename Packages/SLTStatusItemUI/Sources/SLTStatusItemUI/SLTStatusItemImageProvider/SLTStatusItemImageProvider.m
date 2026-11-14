//
//  SLTStatusItemImageProvider.m
//  SLTStatusItemUI
//
//

#import "SLTStatusItemImageProvider+Private.h"
#import <SLTCommon/SLTCommon.h>
#import "NSURL+SLTStatusItemImage.h"
#import "NSImage+SLTStatusItemImage.h"

@implementation SLTStatusItemImageProvider

+ (SLTStatusItemImageProvider *)currentProvider
{
    static SLTStatusItemImageProvider *provider;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        provider = self.customProvider ?: self.standardProvider;
    });
    
    return provider;
}

+ (SLTStatusItemImageProvider *)standardProvider
{
    static SLTStatusItemImageProvider *provider;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        provider = [[self alloc] initWithActiveIconName:NSImage.slt_defaultActiveIconImage
                                       inactiveIconName:NSImage.slt_defaultInactiveIconImage];
    });
    
    return provider;
}

+ (SLTStatusItemImageProvider *)customProvider
{
    static SLTStatusItemImageProvider *provider;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        if(SLTCustomIconImageFilesExist() == NO)
        {
            provider = nil;
            return;
        }
        
        provider = [[self alloc] initWithActiveIconName:NSImage.slt_customActiveIconImage
                                       inactiveIconName:NSImage.slt_customInactiveIconImage];
    });
    
    return provider;
}

#pragma mark -

- (instancetype)initWithActiveIconName:(NSImage *)activeIcon inactiveIconName:(NSImage *)inactiveIcon
{
    NSParameterAssert(activeIcon);
    NSParameterAssert(inactiveIcon);
    
    self = [super init];
    if(self)
    {
        self.baseActiveIconImage = activeIcon;
        self.baseInactiveIconImage = inactiveIcon;
        self.activeIconCache = [NSMutableDictionary new];
        self.inactiveIconCache = [NSMutableDictionary new];
    }
    return self;
}

#pragma mark - Icon Images

- (NSImage *)activeIconImage
{
    return [self coloredImageForBaseImage:self.baseActiveIconImage cache:self.activeIconCache];
}

- (NSImage *)inactiveIconImage
{
    return [self coloredImageForBaseImage:self.baseInactiveIconImage cache:self.inactiveIconCache];
}

- (NSImage *)coloredImageForBaseImage:(NSImage *)baseImage cache:(NSMutableDictionary<NSNumber *, NSImage *> *)cache
{
    Auto color = NSUserDefaults.standardUserDefaults.slt_menuBarIconColor;
    Auto cachedImage = cache[@(color)];
    if(cachedImage != nil)
    {
        return cachedImage;
    }

    Auto image = [NSImage slt_menuBarIconImageFromTemplateImage:baseImage color:color];
    cache[@(color)] = image;
    return image;
}

@end

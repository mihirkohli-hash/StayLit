//
//  SLTStatusItemImageProvider.m
//  SLTStatusItemUI
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
        provider.usesBuiltInIcons = YES;
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
        self.pulseFramesCache = [NSMutableDictionary new];
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

- (NSArray<NSImage *> *)activePulseFrames
{
    if(!self.usesBuiltInIcons)
    {
        return nil;
    }

    Auto defaults = NSUserDefaults.standardUserDefaults;
    Auto color = defaults.slt_menuBarIconColor;
    Auto pulseColor = defaults.slt_menuBarIconPulseColor;

    // The frames depend on both colors, so the cache key holds both.
    Auto cacheKey = @(color * 100 + pulseColor);
    Auto cachedFrames = self.pulseFramesCache[cacheKey];
    if(cachedFrames != nil)
    {
        return cachedFrames;
    }

    Auto frames = [NSImage slt_defaultPulseFramesForColor:color pulseColor:pulseColor];
    self.pulseFramesCache[cacheKey] = frames;
    return frames;
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

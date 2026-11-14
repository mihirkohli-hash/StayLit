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
        self.activeIconImage = activeIcon;
        self.inactiveIconImage = inactiveIcon;
    }
    return self;
}

@end

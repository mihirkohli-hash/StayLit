//
//  SLTDisplayParameters.m
//  SLTApplicationSupport
//

#import <SLTApplicationSupport/SLTDisplayParameters.h>
#import <SLTCommon/SLTCommon.h>
#import <CoreGraphics/CoreGraphics.h>

static const NSUInteger SLTDisplayCountMax = 64u;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu-folding-constant"

NSUInteger SLTDisplayParametersGetNumberOfExternalDisplays()
{
    CGDirectDisplayID displaysIDs[SLTDisplayCountMax];
    uint32_t numberOfDisplays = 0;
    CGError result = CGGetActiveDisplayList(SLTDisplayCountMax, displaysIDs, &numberOfDisplays);
    if(result != kCGErrorSuccess)
    {
        // Fall back to the NSScreen lookup
        return NSScreen.screens.count;
    }
    
    Auto displayIDs = [NSMutableSet<NSNumber *> new];
    
    for(NSUInteger i = 0; i < SLTDisplayCountMax; i++)
    {
        CGDirectDisplayID display = displaysIDs[i];
        if(display == kCGNullDirectDisplay || CGDisplayPixelsWide(display) == 0 || CGDisplayPixelsWide(display) == 1)
        {
            continue;
        }
        
        if([displayIDs containsObject:@(display)])
        {
            continue;
        }
        
        BOOL isMain = CGDisplayIsMain(display);
        if(isMain == YES)
        {
            continue;
        }
        
        [displayIDs addObject:@(display)];
    }
    
    return displayIDs.count;
}

#pragma clang diagnostic pop

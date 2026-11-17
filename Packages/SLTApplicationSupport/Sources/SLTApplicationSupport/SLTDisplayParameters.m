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
    CGDirectDisplayID displaysIDs[SLTDisplayCountMax] = {0};
    uint32_t numberOfDisplays = 0;
    CGError result = CGGetActiveDisplayList(SLTDisplayCountMax, displaysIDs, &numberOfDisplays);
    if(result != kCGErrorSuccess)
    {
        // Fall back to the NSScreen lookup. One screen is the built-in or main one.
        NSUInteger screenCount = NSScreen.screens.count;
        return screenCount > 0 ? screenCount - 1 : 0;
    }
    
    Auto displayIDs = [NSMutableSet<NSNumber *> new];
    
    for(NSUInteger i = 0; i < MIN(numberOfDisplays, SLTDisplayCountMax); i++)
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
        
        // The built-in display is not external. The main display is not always the built-in
        // one: with the lid closed, an external monitor is the main display.
        if(CGDisplayIsBuiltin(display))
        {
            continue;
        }
        
        [displayIDs addObject:@(display)];
    }
    
    return displayIDs.count;
}

#pragma clang diagnostic pop

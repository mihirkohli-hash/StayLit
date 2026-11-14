//
//  SLTEventHandler+SLTDefaultEventHandler.m
//  SLTApplicationEvents
//
//

#import <SLTApplicationEvents/SLTEventHandler+SLTDefaultEventHandler.h>
#import <ApplicationServices/ApplicationServices.h>
#import <SLTCommon/SLTCommon.h>

@implementation SLTEventHandler (SLTDefaultEventHandler)

- (void)registerAsDefaultEventHandler
{
    Auto eventManager = NSAppleEventManager.sharedAppleEventManager;
    [eventManager setEventHandler:self
                      andSelector:@selector(handleGetURLEvent:withReplyEvent:)
                    forEventClass:kInternetEventClass
                       andEventID:kAEGetURL];
}

- (void)handleGetURLEvent:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)reply
{
    Auto parameter = [event paramDescriptorForKeyword:keyDirectObject].stringValue;
    [self handleEventForURL:[NSURL URLWithString:parameter]];
}

@end

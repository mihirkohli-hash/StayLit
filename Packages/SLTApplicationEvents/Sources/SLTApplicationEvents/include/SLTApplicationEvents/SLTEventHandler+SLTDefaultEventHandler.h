//
//  SLTEventHandler+SLTDefaultEventHandler.h
//  SLTApplicationEvents
//
//

#import <Foundation/Foundation.h>
#import <SLTApplicationEvents/SLTEventHandler.h>

NS_ASSUME_NONNULL_BEGIN

@interface SLTEventHandler (SLTDefaultEventHandler)

/// Configures the event handler to be the default for the current
/// applicatiom and prepares itself for handling incoming events.
- (void)registerAsDefaultEventHandler;

@end

NS_ASSUME_NONNULL_END

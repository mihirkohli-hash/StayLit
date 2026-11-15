//
//  SLTEventHandler.h
//  SLTApplicationEvents
//

#import <Foundation/Foundation.h>
#import <SLTApplicationEvents/SLTEvent.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^SLTEventHandlerActionBlock)(SLTEvent *event);

@interface SLTEventHandler : NSObject

/// Returns the default event handler.
@property (class, nonatomic, readonly) SLTEventHandler *defaultHandler;

/// Registers a block that will be executed when an event with
/// the supplied actionName is executed.
/// @param actionName An action identifier
/// @param block A block
- (void)registerActionNamed:(NSString *)actionName
                      block:(SLTEventHandlerActionBlock)block;

/// Removes the registered action and block with the supplied actionName.
/// @param actionName An action identifier
- (void)removeActionNamed:(NSString *)actionName;

/// Call this method with a callback URL. The URL will be tokenized
/// and any action that matches the token will be executed.
/// @param URL A callback URL
- (void)handleEventForURL:(NSURL *)URL;

@end

NS_ASSUME_NONNULL_END

//
//  SLTAppController.h
//  StayLit
//
//

#import <Cocoa/Cocoa.h>
#import <SLTSleepWakeTimer/SLTSleepWakeTimer.h>
#import <SLTDeviceInfo/SLTDeviceInfo.h>
#import <SLTApplicationEvents/SLTApplicationEvents.h>
#import <SLTApplicationSupport/SLTApplicationSupport.h>
#import <SLTStatusItemUI/SLTStatusItemUI.h>

NS_ASSUME_NONNULL_BEGIN

@interface SLTAppController : NSObject

/// The associated SLTSleepWakeTimer instance of this app controller.
@property (nonatomic, readonly) SLTSleepWakeTimer *sleepWakeTimer;

/// Controls the display a action handling for the status bar item.
@property (nonatomic, readonly) SLTStatusItemController *statusItemController;

@end

NS_ASSUME_NONNULL_END

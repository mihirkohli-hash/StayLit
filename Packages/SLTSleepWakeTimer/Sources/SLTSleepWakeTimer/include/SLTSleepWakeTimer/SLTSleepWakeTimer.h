//
//  SLTSleepWakeTimer.h
//  StayLit
//
//

#import <Foundation/Foundation.h>
#import <SLTApplicationSupport/SLTApplicationSupport.h>
#import <SLTCommon/SLTExport.h>

NS_ASSUME_NONNULL_BEGIN

SLT_EXPORT NSTimeInterval const SLTSleepWakeTimeIntervalIndefinite;

typedef void (^SLTSleepWakeTimerCompletionBlock)(BOOL cancelled);

@protocol SLTSleepWakeTimerDelegate;

@interface SLTSleepWakeTimer : NSObject

/// An optional delegate.
@property (weak, nonatomic, nullable) id<SLTSleepWakeTimerDelegate> delegate;

/// Returns the completion date for the currently scheduled timer.
///
/// If the timer was scheduled for 0 seconds (Infinity), the fireDate is nil.
@property (copy, nonatomic, readonly, nullable) NSDate *fireDate;

/// The initial time interval that was set to schedule the timer.
@property (nonatomic, readonly) NSTimeInterval scheduledTimeInterval;

/// Returns YES if a task is scheduled and running.
@property (readonly, nonatomic, getter=isScheduled) BOOL scheduled;

/// An optional completion block when the task finishes at the fireDate
/// or when invalidate is called manually.
@property (copy, nonatomic, nullable) SLTSleepWakeTimerCompletionBlock completionBlock;

/// Schedule the Caffeinate Task for a given amount of seconds.
/// The optional completion block will be called after the interval.
/// If you pass 0 seconds, the task will be scheduled without a fireDate.
/// After invocation, the fireDate property is set.
/// @param timeInterval A time interval in seconds
/// @param completion An optional completion block
- (void)scheduleWithTimeInterval:(NSTimeInterval)timeInterval
                      completion:(nullable SLTSleepWakeTimerCompletionBlock)completion;

/// Invalidates the timer, cancels the Caffeinate Task and resets
/// the fireDate to nil.
- (void)invalidate;

@end

@protocol SLTSleepWakeTimerDelegate <NSObject>
@optional
/// The sleep wake timer will activate with the provided time interval.
/// @param sleepWakeTimer The delegating sleep wake timer
/// @param timeInterval A time interval
- (void)sleepWakeTimer:(SLTSleepWakeTimer *)sleepWakeTimer willActivateWithTimeInterval:(NSTimeInterval)timeInterval;

/// The sleep wake timer did deactivate.
/// @param sleepWakeTimer The delegating sleep wake timer
- (void)sleepWakeTimerDidDeactivate:(SLTSleepWakeTimer *)sleepWakeTimer;
@end

NS_ASSUME_NONNULL_END

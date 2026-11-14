//
//  SLTSleepWakeTimer+Private.h
//  StayLit
//
//  Created by Mihir Kohli on 2026.
//

#import <SLTSleepWakeTimer/SLTSleepWakeTimer.h>

NS_ASSUME_NONNULL_BEGIN

@interface SLTSleepWakeTimer ()

/// Returns the arguments for the `caffeinate` process.
///
/// This is separate from the task launch so tests can check the arguments
/// without starting a process.
/// @param timeInterval A time interval in seconds, or `SLTSleepWakeTimeIntervalIndefinite`
/// @param defaults The user defaults that hold the sleep settings
/// @param processIdentifier The process that `caffeinate` watches and exits with
+ (NSArray<NSString *> *)caffeinateArgumentsForTimeInterval:(NSTimeInterval)timeInterval
                                               userDefaults:(NSUserDefaults *)defaults
                                          processIdentifier:(int)processIdentifier;

@end

NS_ASSUME_NONNULL_END

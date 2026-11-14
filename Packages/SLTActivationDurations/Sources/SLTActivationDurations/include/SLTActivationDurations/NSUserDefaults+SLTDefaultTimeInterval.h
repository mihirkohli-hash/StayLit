//
//  NSUserDefaults+SLTDefaultTimeInterval.h
//  SLTActivationDurations
//
//

#import <Foundation/Foundation.h>
#import <SLTCommon/SLTExport.h>

NS_ASSUME_NONNULL_BEGIN

SLT_EXPORT NSString * const SLTUserDefaultsKeyDefaultTimeInterval;

@interface NSUserDefaults (SLTDefaultTimeInterval)

/// Returns the default time interval for the sleep wake timer.
/// @warning When setting a value with decimal places, these will
///          be cut off.
@property (nonatomic) NSTimeInterval slt_defaultTimeInterval;

@end

NS_ASSUME_NONNULL_END

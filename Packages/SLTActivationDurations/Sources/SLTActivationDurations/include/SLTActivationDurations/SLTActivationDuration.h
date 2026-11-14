//
//  SLTActivationDuration.h
//  SLTActivationDurations
//
//

#import <Foundation/Foundation.h>
#import <SLTCommon/SLTExport.h>

NS_ASSUME_NONNULL_BEGIN

/// An indefinite activation duration (represents a time interval of 0.0).
SLT_EXPORT NSTimeInterval const SLTActivationDurationIndefinite;

/// The object representation of a sleep wake timer activation duration.
@interface SLTActivationDuration : NSObject <NSSecureCoding>

/// Returns a default set of activation durations.
@property (class, nonatomic, readonly) NSArray<SLTActivationDuration *> *defaultActivationDurations;

/// Returns an activation duration for an indefinite amount of time.
@property (class, nonatomic, readonly) SLTActivationDuration *indefiniteActivationDuration;

/// An activation duration. 0 seconds represent SLTActivationDurationIndefinite.
@property (nonatomic, readonly) NSTimeInterval seconds;

- (instancetype)init NS_UNAVAILABLE;

/// The designated initializer for the activation duration.
/// @param seconds Some seconds.
- (instancetype)initWithSeconds:(NSTimeInterval)seconds NS_DESIGNATED_INITIALIZER;

/// Convenience initializer to create a new activation duration
/// from the provided components.
/// @param hours Hours component
/// @param minutes Minutes component
/// @param seconds Seconds component
- (nullable instancetype)initWithHours:(NSInteger)hours
                               minutes:(NSInteger)minutes
                               seconds:(NSInteger)seconds;

/// Returns YES if other matches the stored seconds of the receiver.
/// @param other Another activation duration to compare to
/// @returns YES if other is equal to the receiver
- (BOOL)isEqualToActivationDuration:(SLTActivationDuration *)other;

@end

NS_ASSUME_NONNULL_END

//
//  SLTActivationDurationsController.h
//  SLTActivationDurations
//
//

#import <Foundation/Foundation.h>
#import <SLTActivationDurations/SLTActivationDuration.h>
#import <SLTCommon/SLTExport.h>

NS_ASSUME_NONNULL_BEGIN

SLT_EXPORT NSNotificationName const SLTActivationDurationsDidChangeNotification;

/// Manages adding and removing of activation durations, persistence and
/// provides the ability to mark an activation duration as default duration.
@interface SLTActivationDurationsController : NSObject

/// The shared instance
@property (class, nonatomic, readonly) SLTActivationDurationsController *sharedController;

/// The underlying user defaults for storing activation durations
@property (nonatomic, readonly) NSUserDefaults *userDefaults;

/// An activation duration that is marked as default duration
@property (nonatomic, nullable) SLTActivationDuration *defaultActivationDuration;

/// Returns all available and sorted activation durations.
/// This also includes the indefinite activation duration.
@property (copy, nonatomic, readonly) NSArray<SLTActivationDuration *> *activationDurations;

- (instancetype)init NS_UNAVAILABLE;

/// The designated initializer.
/// Please use the `sharedController` instead.
/// @param userDefaults A user defaults instance
- (instancetype)initWithUserDefaults:(NSUserDefaults *)userDefaults NS_DESIGNATED_INITIALIZER;

#pragma mark - Add & Remove

/// Adds an activation duration.
/// @param activationDuration An activation durations
- (BOOL)addActivationDuration:(SLTActivationDuration *)activationDuration;

/// Removes an activation duration if it was added before.
/// @param activationDuration An activation duration
- (BOOL)removeActivationDuration:(SLTActivationDuration *)activationDuration;

#pragma mark - Index Access

/// Returns YES if the activation duration at the provided index
/// can be removed.
/// @param index An index
/// @returns YES if the activation duration can be removed
- (BOOL)canRemoveActivationDurationAtIndex:(NSUInteger)index;

/// Removes an activation duration at the provided index.
/// @param index An index
/// @returns NO if there is no activation duration at the provided index
- (BOOL)removeActivationDurationAtIndex:(NSUInteger)index;

/// Marks an activation duration as default duration.
/// @param index An index
- (void)setActivationDurationAsDefaultAtIndex:(NSUInteger)index;

#pragma mark - Reset

/// Resets all activation durations to the default durations.
- (void)resetActivationDurations;

@end

NS_ASSUME_NONNULL_END

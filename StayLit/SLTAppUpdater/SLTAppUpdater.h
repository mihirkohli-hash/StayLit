//
//  SLTAppUpdater.h
//  StayLit
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#ifndef SLT_APP_UPDATER_ENABLED
  #define SLT_APP_UPDATER_ENABLED 0
#endif

#if SLT_APP_UPDATER_ENABLED

@class SPUUpdater;

/// Checks for app updates and is a wrapper around
/// the Sparkle framework.
@interface SLTAppUpdater : NSObject
/// The shared updater instance, prefer this over individual instances
@property (class, nonatomic, readonly) SLTAppUpdater *defaultAppUpdater;

/// Convenience access to the underlying Sparkle updater.
@property (nonatomic, readonly, nullable) SPUUpdater *updater;

/// Start checking for app updates.
/// @param sender A sender
- (void)checkForUpdates:(id)sender;

@end

#endif

NS_ASSUME_NONNULL_END

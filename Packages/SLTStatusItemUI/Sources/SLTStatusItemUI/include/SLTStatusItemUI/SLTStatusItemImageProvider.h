//
//  SLTStatusItemImageProvider.h
//  SLTStatusItemUI
//
//

#import <Foundation/Foundation.h>
#import <AppKit/NSImage.h>

NS_ASSUME_NONNULL_BEGIN

/// Provides active and inactive icon images for the status item.
@interface SLTStatusItemImageProvider : NSObject

/// Returns a status item icon provider for either the default
/// or custom icon images.
///
/// @note This class method will always return the same instance
///       during the lifetime of the app.
@property (class, nonatomic, readonly) SLTStatusItemImageProvider *currentProvider;

/// Returns a menu bar icon provider for the built-in icon images.
/// @note The built-in icons are the `desktopcomputer` SF Symbol with a lit
///       screen when active and a dark screen when inactive.
@property (class, nonatomic, readonly) SLTStatusItemImageProvider *standardProvider;

/// Returns a status item icon provider for the custom active/inactive
/// icon images from the application container.
@property (class, nonatomic, readonly, nullable) SLTStatusItemImageProvider *customProvider;

/// An icon image representing the active state.
@property (nonatomic, readonly) NSImage *activeIconImage;

/// An icon image representing the inactive state.
@property (nonatomic, readonly) NSImage *inactiveIconImage;

/// The images of one pulse cycle for the active state, or nil if the icon cannot pulse.
///
/// Only the built-in icon has a separate screen. A custom icon has no frames, and
/// the status item fades the whole icon instead.
@property (nonatomic, readonly, nullable) NSArray<NSImage *> *activePulseFrames;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END

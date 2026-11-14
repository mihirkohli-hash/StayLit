//
//  SLTStatusItemImageProvider+Private.h
//  SLTStatusItemUI
//
//

#import <Foundation/Foundation.h>
#import <SLTStatusItemUI/SLTStatusItemImageProvider.h>

NS_ASSUME_NONNULL_BEGIN

@interface SLTStatusItemImageProvider ()
@property (nonatomic) NSImage *baseActiveIconImage;
@property (nonatomic) NSImage *baseInactiveIconImage;

// Colored variants by color, so the same image instance is returned until the color changes.
@property (nonatomic) NSMutableDictionary<NSNumber *, NSImage *> *activeIconCache;
@property (nonatomic) NSMutableDictionary<NSNumber *, NSImage *> *inactiveIconCache;
@property (nonatomic) NSMutableDictionary<NSNumber *, NSArray<NSImage *> *> *pulseFramesCache;

/// YES for the built-in icon, which has a separate screen that can pulse.
@property (nonatomic) BOOL usesBuiltInIcons;

/// The designated initializer for an image provider.
/// @param activeIcon An NSImage representing the active state, a nil value sets the default icon.
/// @param inactiveIcon An NSImage representing the inactive state, a nil value sets the default icon.
- (instancetype)initWithActiveIconName:(NSImage *)activeIcon
                      inactiveIconName:(NSImage *)inactiveIcon NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END

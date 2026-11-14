//
//  SLTStatusItemImageProvider+Private.h
//  SLTStatusItemUI
//
//

#import <Foundation/Foundation.h>
#import <SLTStatusItemUI/SLTStatusItemImageProvider.h>

NS_ASSUME_NONNULL_BEGIN

@interface SLTStatusItemImageProvider ()
@property (nonatomic, readwrite) NSImage *activeIconImage;
@property (nonatomic, readwrite) NSImage *inactiveIconImage;

/// The designated initializer for an image provider.
/// @param activeIcon An NSImage representing the active state, a nil value sets the default icon.
/// @param inactiveIcon An NSImage representing the inactive state, a nil value sets the default icon.
- (instancetype)initWithActiveIconName:(NSImage *)activeIcon
                      inactiveIconName:(NSImage *)inactiveIcon NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END

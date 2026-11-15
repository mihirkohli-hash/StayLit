//
//  SLTStatusItemController.h
//  SLTStatusItemUI
//

#import <Cocoa/Cocoa.h>
#import <SLTApplicationSupport/SLTApplicationSupport.h>

NS_ASSUME_NONNULL_BEGIN

/// The appearance of the status item icon image.
typedef NS_ENUM(NSUInteger, SLTStatusItemAppearance)
{
    /// Represents the inactive state of the status bar item
    SLTStatusItemAppearanceInactive = 0,
    /// Represents the active state of the status bar item
    SLTStatusItemAppearanceActive
};

@protocol SLTStatusItemControllerDataSource;
@protocol SLTStatusItemControllerDelegate;

/// Manages the display and interaction with the menu bar status item.
@interface SLTStatusItemController : NSObject

/// The underlying system status bar item.
@property (nonatomic, readonly) NSStatusItem *systemStatusItem;

/// Controls the activate/inactive appearance of the status item image.
@property (nonatomic) SLTStatusItemAppearance appearance;

/// A delegate for receiving click events.
@property (weak, nonatomic, nullable) id<SLTStatusItemControllerDataSource> dataSource;

/// A delegate for receiving click events.
@property (weak, nonatomic, nullable) id<SLTStatusItemControllerDelegate> delegate;

/// The designated initializer.
- (instancetype)init NS_DESIGNATED_INITIALIZER;

@end

@protocol SLTStatusItemControllerDataSource <NSObject>
@optional
/// The menu that is displayed when the status item is clicked.
- (nullable NSMenu *)menuForStatusItemController:(SLTStatusItemController *)controller;
@end

@protocol SLTStatusItemControllerDelegate <NSObject>
@optional
/// Notifies the delegate that the primary click action was invoked.
/// @param controller The delegating status item controller
- (void)statusItemControllerShouldPerformPrimaryAction:(SLTStatusItemController *)controller;
@end

NS_ASSUME_NONNULL_END

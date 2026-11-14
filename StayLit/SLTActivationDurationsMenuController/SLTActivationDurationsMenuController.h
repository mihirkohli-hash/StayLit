//
//  SLTActivationDurationsMenuController.h
//  StayLit
//
//

#import <Cocoa/Cocoa.h>
#import <SLTUserNotifications/SLTUserNotifications.h>
#import <SLTActivationDurations/SLTActivationDurations.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SLTActivationDurationsMenuControllerDelegate;

/**
 Manages the primary activation durations menu.
 */
@interface SLTActivationDurationsMenuController : NSObject <NSMenuDelegate>

/**
 The model controller that provides the list of activation durations.
 */
@property (nonatomic) SLTActivationDurationsController *activationDurationsController;

/**
 The delegate for receiving user selection events.
 */
@property (weak, nonatomic, nullable) id<SLTActivationDurationsMenuControllerDelegate> delegate;

/**
 The managed activation durations menu.
 
 @note This menu can be attached to another menu item as submenu.
 */
@property (nonatomic, readonly) NSMenu *menu;

/**
 Tells the delegate that the user selected a duration
 by clicking on a menu item.

 @param sender The clicked menu item
 */
- (void)selectActivationDuration:(nullable NSMenuItem *)sender;

@end

/**
 A menu controller delegate that provides status values of
 the sleep wake timer and notifies about user selection.
 */
@protocol SLTActivationDurationsMenuControllerDelegate <NSObject>
@optional

/**
 Returns the currently selected activation duration.

 @return An activation duration or nil of none is active
 */
- (nullable SLTActivationDuration *)currentActivationDuration;

/**
 Returns the fire date of the currently selected activation duration.

 @param controller The delegating menu controller
 @return A fire date or nil of none is active
 */
- (nullable NSDate *)fireDateForMenuController:(SLTActivationDurationsMenuController *)controller;

/**
 Tells the receiver that the user selected an activation duration from the menu.

 @param controller The delegating menu controller
 @param activationDuration The user-selected activation duration
 */
- (void)activationDurationsMenuController:(SLTActivationDurationsMenuController *)controller
              didSelectActivationDuration:(SLTActivationDuration *)activationDuration;
@end

NS_ASSUME_NONNULL_END

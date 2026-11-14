//
//  SLTMainMenu.h
//  StayLit
//
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

/// Creates a main menu with common commands like Quit, Settings… and the
/// activation durations sub menu.
/// @param activationDurationsSubMenu An activation durations sub menu
NSMenu *SLTCreateMainMenuWithActivationDurationsSubMenu(NSMenu *activationDurationsSubMenu);

NS_ASSUME_NONNULL_END

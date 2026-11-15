//
//  SLTMainMenu.m
//  StayLit
//

#import "SLTMainMenu.h"
#import <SLTCommon/SLTCommon.h>
#import "SLTLocalizedStrings.h"
#import "SLTAppDelegate.h"

NSMenu *SLTCreateMainMenuWithActivationDurationsSubMenu(NSMenu *activationDurationsSubMenu)
{
    NSCParameterAssert(activationDurationsSubMenu);
    
    Auto mainMenu = [[NSMenu alloc] initWithTitle:@""];
    
    Auto activateForDuration = [[NSMenuItem alloc] initWithTitle:SLT_L10N_ACTIVATE_FOR_DURATION
                                                          action:nil
                                                   keyEquivalent:@""];
    if(@available(macOS 26.0, *))
    {
        activateForDuration.image = [NSImage imageWithSystemSymbolName:@"timer" accessibilityDescription:nil];
    }
    activateForDuration.submenu = activationDurationsSubMenu;
    [mainMenu addItem:activateForDuration];
    
    [mainMenu addItem:NSMenuItem.separatorItem];
    
    Auto settings = [[NSMenuItem alloc] initWithTitle:SLT_L10N_SETTINGS_ELLIPSIS
                                               action:@selector(showSettingsWindow:)
                                        keyEquivalent:@","];
    if(@available(macOS 26.0, *))
    {
        settings.image = [NSImage imageWithSystemSymbolName:@"gear" accessibilityDescription:nil];
    }
    [mainMenu addItem:settings];
    
    [mainMenu addItem:NSMenuItem.separatorItem];
    
    Auto quit = [[NSMenuItem alloc] initWithTitle:SLT_L10N_QUIT
                                           action:@selector(terminate:)
                                    keyEquivalent:@"q"];
    [mainMenu addItem:quit];
    
    return mainMenu;
}

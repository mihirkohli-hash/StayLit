//
//  SLTActivationDurationsMenuController.m
//  StayLit
//

#import "SLTActivationDurationsMenuController.h"
#import <SLTCommon/SLTCommon.h>
#import "SLTLocalizedStrings.h"
#import "SLTActivationDuration+SLTLocalizedTitle.h"

static const NSInteger SLTMenuItemRemainingTimeTag = 666;
static const CGFloat SLTMenuItemDefaultFontSize = 14.0f;

@interface SLTActivationDurationsMenuController ()
@property (nonatomic, readwrite) NSMenu *menu;
@end

@implementation SLTActivationDurationsMenuController

- (instancetype)init
{
    self = [super init];
    if(self)
    {
        self.activationDurationsController = SLTActivationDurationsController.sharedController;
        self.menu = [[NSMenu alloc] initWithTitle:SLT_L10N_ACTIVATE_FOR_DURATION];
        self.menu.delegate = self;
    }
    return self;
}

- (void)selectActivationDuration:(nullable NSMenuItem *)sender
{
    Auto delegate = self.delegate;
    if([delegate respondsToSelector:@selector(activationDurationsMenuController:didSelectActivationDuration:)])
    {
        NSTimeInterval seconds = (NSTimeInterval)sender.tag;
        Auto duration = [[SLTActivationDuration alloc] initWithSeconds:seconds];
        [delegate activationDurationsMenuController:self didSelectActivationDuration:duration];
    }
}

- (void)setDefaultActivationDuration:(nullable NSMenuItem *)sender
{
    NSTimeInterval seconds = (NSTimeInterval)sender.tag;
    
    Auto controller = self.activationDurationsController;
    Auto durations = controller.activationDurations;
    
    Auto predicate = [NSPredicate predicateWithFormat:@"seconds == %@", @(seconds)];
    Auto results = [durations filteredArrayUsingPredicate:predicate];
    
    self.activationDurationsController.defaultActivationDuration = results.firstObject;
}

#pragma mark -

- (NSAttributedString *)attributedStringForMenuItemTitle:(NSString *)title isDefault:(BOOL)isDefault
{
    Auto attributed = [NSMutableAttributedString new];
    
    Auto font = [NSFont monospacedDigitSystemFontOfSize:SLTMenuItemDefaultFontSize
                                                 weight:NSFontWeightRegular];
    
    Auto attributes = @{ NSFontAttributeName: font };
    Auto attributedTitle = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ ", title]
                                                           attributes:attributes];
    [attributed appendAttributedString:attributedTitle];
    
    if(isDefault)
    {
        Auto defaultAttributes = @{
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: [self defaultAttributeTextColor]
        };
        Auto attributedDefault = [[NSAttributedString alloc] initWithString:SLT_L10N_IS_DEFAULT_SUFFIX
                                                                 attributes:defaultAttributes];
        [attributed appendAttributedString:attributedDefault];
    }
    
    return [attributed copy];
}

- (NSColor *)defaultAttributeTextColor
{
    return NSColor.secondaryLabelColor;
}

- (nullable NSMenuItem *)menuItemForRemainingTime
{
    Auto delegate = self.delegate;
    if(![delegate respondsToSelector:@selector(fireDateForMenuController:)]) { return nil; }
    
    Auto fireDate = [delegate fireDateForMenuController:self];
    if(fireDate == nil) { return nil; }
    
    Auto menuItem = [[NSMenuItem alloc] initWithTitle:fireDate.slt_localizedRemainingTime
                                               action:nil
                                        keyEquivalent:@""];
    menuItem.tag = SLTMenuItemRemainingTimeTag;
    return menuItem;
}

// TODO: Use this for live updates of the menu item
- (void)updateRemainingTime:(id)sender
{
    Auto delegate = self.delegate;
    if(![delegate respondsToSelector:@selector(fireDateForMenuController:)]) { return; }
    
    Auto fireDate = [delegate fireDateForMenuController:self];
    if(fireDate == nil) { return; }
    
    Auto menuItem = self.menu.itemArray.firstObject;
    if(menuItem != nil && menuItem.tag == SLTMenuItemRemainingTimeTag)
    {
        menuItem.title = fireDate.slt_localizedRemainingTime;
    }
}

#pragma mark - NSMenuDelegate

- (void)menuNeedsUpdate:(NSMenu *)menu
{
    [menu removeAllItems];
    
    Auto controller = self.activationDurationsController;
    
    Auto remainingTimeMenuItem = [self menuItemForRemainingTime];
    if(remainingTimeMenuItem != nil)
    {
        [menu addItem:remainingTimeMenuItem];
        [menu addItem:NSMenuItem.separatorItem];
    }
    
    for(SLTActivationDuration *duration in controller.activationDurations)
    {
        Auto menuItem = [menu addItemWithTitle:duration.localizedTitle
                                        action:@selector(selectActivationDuration:)
                                 keyEquivalent:@""];
        menuItem.target = self;
        menuItem.tag = (NSInteger)duration.seconds;
        
        // Alternate state
        Auto alternateTitle = SLT_L10N_SET_DEFAULT_ACTIVATION_DURATION(duration.localizedTitle);
        Auto alternateMenuItem = [menu addItemWithTitle:alternateTitle
                                                 action:@selector(setDefaultActivationDuration:)
                                          keyEquivalent:@""];
        alternateMenuItem.target = self;
        alternateMenuItem.alternate = YES;
        alternateMenuItem.keyEquivalentModifierMask = NSEventModifierFlagOption;
        alternateMenuItem.tag = (NSInteger)duration.seconds;
        
        // Is Default
        BOOL isDefault = [controller.defaultActivationDuration isEqualToActivationDuration:duration];
        menuItem.attributedTitle = [self attributedStringForMenuItemTitle:menuItem.title isDefault:isDefault];
        
        // Is Scheduled
        Auto delegate = self.delegate;
        if([delegate respondsToSelector:@selector(currentActivationDuration)])
        {
            Auto current = [delegate currentActivationDuration];
            if(current != nil && ([current isEqualToActivationDuration:duration]))
            {
                menuItem.state = NSControlStateValueOn;
                alternateMenuItem.state = NSControlStateValueOn;
            }
        }
    }
}

@end

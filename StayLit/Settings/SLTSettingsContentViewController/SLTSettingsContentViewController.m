//
//  SLTSettingsContentViewController.m
//  StayLit
//
//

#import "SLTSettingsContentViewController.h"
#import <SLTCommon/SLTCommon.h>

@interface SLTSettingsContentViewController ()
@end

@implementation SLTSettingsContentViewController

+ (NSTabViewItem *)preferredTabViewItem
{
    NSViewController *controller = [[self alloc] init];
    
    Auto item = [NSTabViewItem tabViewItemWithViewController:controller];
    item.image = self.tabViewItemImage;
    return item;
}

+ (NSImage *)tabViewItemImage
{
    return nil;
}

+ (NSString *)preferredTitle
{
    return nil;
}

- (BOOL)resizesView
{
    return YES;
}

#pragma mark - Life Cycle

- (instancetype)init
{
    Auto nibName = NSStringFromClass([self class]);
    self = [super initWithNibName:nibName bundle:nil];
    if(self)
    {
        self.title = [[self class] preferredTitle];
    }
    return self;
}

- (void)viewWillAppear
{
    [super viewWillAppear];
    
    if([self resizesView])
    {
        self.preferredContentSize = self.view.fittingSize;
    }
}

@end

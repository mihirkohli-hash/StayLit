//
//  SLTDurationCell.m
//  StayLit
//

#import "SLTDurationCell.h"
#import <SLTCommon/SLTCommon.h>
#import "SLTLocalizedStrings.h"

@implementation SLTDurationCell

+ (NSUserInterfaceItemIdentifier)identifier
{
    return (NSUserInterfaceItemIdentifier)NSStringFromClass(self);
}

+ (void)registerInTableView:(NSTableView *)tableView
{
    NSParameterAssert(tableView);
    
    Auto identifier = [self identifier];
    Auto bundle = [NSBundle bundleForClass:self];
    Auto nib = [[NSNib alloc] initWithNibNamed:identifier bundle:bundle];
    [tableView registerNib:nib forIdentifier:identifier];
}

+ (instancetype)dequeueFromTableView:(NSTableView *)tableView owner:(id)owner
{
    NSParameterAssert(tableView);
    
    return [tableView makeViewWithIdentifier:[self identifier] owner:owner];
}

#pragma mark - Life Cycle

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.defaultLabel.stringValue = SLT_L10N_DEFAULT;
}

#pragma mark - Default Duration

- (void)setIsDefaultDuration:(BOOL)isDefaultDuration
{
    self.defaultLabel.hidden = !isDefaultDuration;
    
    CGFloat size = self.textLabel.font.pointSize;
    NSFontWeight weight = isDefaultDuration ? NSFontWeightSemibold : NSFontWeightRegular;
    self.textLabel.font = [NSFont monospacedDigitSystemFontOfSize:size weight:weight];
}

- (BOOL)isDefaultDuration
{
    return ![self.defaultLabel isHidden];
}

@end

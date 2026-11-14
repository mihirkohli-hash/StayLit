//
//  SLTDurationCell.h
//  StayLit
//
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface SLTDurationCell : NSTableCellView
@property (weak, nonatomic) IBOutlet NSTextField *textLabel;
@property (weak, nonatomic) IBOutlet NSTextField *defaultLabel;
@property (nonatomic) BOOL isDefaultDuration;

+ (void)registerInTableView:(NSTableView *)tableView;
+ (instancetype)dequeueFromTableView:(NSTableView *)tableView
                               owner:(nullable id)owner;

@end

NS_ASSUME_NONNULL_END

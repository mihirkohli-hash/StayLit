//
//  SLTAddDurationViewController.h
//  StayLit
//

#import <Cocoa/Cocoa.h>
#import <SLTActivationDurations/SLTActivationDurations.h>

NS_ASSUME_NONNULL_BEGIN

/// Allows adding Activation Durations using `SLTActivationDurationsController`.
@interface SLTAddDurationViewController : NSViewController <NSTextFieldDelegate>
@property (nonatomic, readonly) SLTActivationDurationsController *activationDurationsController;
@property (weak, nonatomic) IBOutlet NSTextField *hoursTextField;
@property (weak, nonatomic) IBOutlet NSTextField *minutesTextField;
@property (weak, nonatomic) IBOutlet NSTextField *secondsTextField;
@property (weak, nonatomic) IBOutlet NSTextField *warningLabel;
@property (weak, nonatomic) IBOutlet NSButton *addButton;

/// The designated initializer
/// @param controller The activation durations controller
- (instancetype)initWithActivationDurationsController:(SLTActivationDurationsController *)controller;

- (IBAction)addDuration:(nullable id)sender;

@end

NS_ASSUME_NONNULL_END

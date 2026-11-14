//
//  SLTAddDurationViewController.m
//  StayLit
//
//

#import "SLTAddDurationViewController.h"
#import <SLTCommon/SLTCommon.h>
#import "SLTLocalizedStrings.h"

static const NSInteger SLTMaximumHours = 999;
static const NSInteger SLTMaximumMinutes = 59;
static const NSInteger SLTMaximumSeconds = 59;

typedef NS_ENUM(NSUInteger, SLTValidationReason)
{
    SLTValidationReasonSuccess = 0,
    SLTValidationReasonInvalid,
    SLTValidationReasonAlreadyAdded
};

@interface SLTAddDurationViewController ()
@property (nonatomic, readwrite) SLTActivationDurationsController *activationDurationsController;

@property (nonatomic) NSNumber *hours;
@property (nonatomic) NSNumber *minutes;
@property (nonatomic) NSNumber *seconds;

@property (nonatomic, nullable) NSString *errorMessage;
@end

@implementation SLTAddDurationViewController

- (instancetype)initWithActivationDurationsController:(SLTActivationDurationsController *)controller
{
    NSParameterAssert(controller);
    
    Auto nibName = NSStringFromClass([self class]);
    self = [super initWithNibName:nibName bundle:nil];
    if(self)
    {
        self.activationDurationsController = controller;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self resetValues];
}

- (void)addDuration:(id)sender
{
    [self setInputsEnabled:NO];
    
    SLTValidationReason validationResult = [self validateInputs];
    switch(validationResult)
    {
        case SLTValidationReasonInvalid:
            self.errorMessage = SLT_L10N_DURATION_INVALID_INPUT;
            [self setInputsEnabled:YES];
            break;
        case SLTValidationReasonAlreadyAdded:
            self.errorMessage = SLT_L10N_DURATION_ALREADY_ADDED;
            [self setInputsEnabled:YES];
            break;
        default:
            [self dismissController:sender];
            break;
    }
}

- (SLTValidationReason)validateInputs
{
    if(self.hours.integerValue > SLTMaximumHours)
    {
        self.hours = @(SLTMaximumHours);
        return SLTValidationReasonInvalid;
    }
    if(self.hours == nil) { self.hours = @0; }
    
    if(self.minutes.integerValue > SLTMaximumMinutes)
    {
        self.minutes = @(SLTMaximumMinutes);
        return SLTValidationReasonInvalid;
    }
    if(self.minutes == nil) { self.minutes = @0; }
    
    if(self.seconds.integerValue > SLTMaximumSeconds)
    {
        self.seconds = @(SLTMaximumSeconds);
        return SLTValidationReasonInvalid;
    }
    if(self.seconds == nil) { self.seconds = @0; }
    
    Auto duration = [[SLTActivationDuration alloc] initWithHours:self.hours.integerValue
                                                         minutes:self.minutes.integerValue
                                                         seconds:self.seconds.integerValue];
    if(duration == nil)
    {
        return SLTValidationReasonInvalid;
    }
    
    BOOL didAdd = [self.activationDurationsController addActivationDuration:duration];
    if(didAdd == NO)
    {
        return SLTValidationReasonAlreadyAdded;
    }
    
    return SLTValidationReasonSuccess;
}

- (void)setInputsEnabled:(BOOL)enabled
{
    if(enabled == NO)
    {
        [self.hoursTextField resignFirstResponder];
        [self.minutesTextField resignFirstResponder];
        [self.secondsTextField resignFirstResponder];
    }
    
    self.hoursTextField.editable = enabled;
    self.minutesTextField.editable = enabled;
    self.secondsTextField.editable = enabled;
}

- (void)resetValues
{
    self.hours = @1;
    self.minutes = @0;
    self.seconds = @0;
}

#pragma mark - NSTextFieldDelegate

- (BOOL)control:(NSControl *)control textShouldBeginEditing:(NSText *)fieldEditor
{
    // Reset the error message when the user starts typing again
    self.errorMessage = nil;
    
    return YES;
}

@end

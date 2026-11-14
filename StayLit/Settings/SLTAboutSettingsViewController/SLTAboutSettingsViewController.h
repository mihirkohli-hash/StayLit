//
//  SLTAboutSettingsViewController.h
//  StayLit
//
//

#import <Cocoa/Cocoa.h>
#import <SLTApplicationSupport/SLTApplicationSupport.h>
#import "SLTSettingsContentViewController.h"

NS_ASSUME_NONNULL_BEGIN

/// Shows an "About" screen with version and copyright information.
@interface SLTAboutSettingsViewController : SLTSettingsContentViewController
@property (copy, nonatomic, readonly) NSString *versionText;
@property (copy, nonatomic, readonly) NSString *copyrightText;

@end

NS_ASSUME_NONNULL_END

//
//  SLTActivationDuration+SLTLocalizedTitle.h
//  StayLit
//
//

#import <Foundation/Foundation.h>
#import <SLTActivationDurations/SLTActivationDurations.h>

NS_ASSUME_NONNULL_BEGIN

@interface SLTActivationDuration (SLTLocalizedTitle)

/// A localized title text.
@property (nonatomic, readonly) NSString *localizedTitle;

@end

NS_ASSUME_NONNULL_END

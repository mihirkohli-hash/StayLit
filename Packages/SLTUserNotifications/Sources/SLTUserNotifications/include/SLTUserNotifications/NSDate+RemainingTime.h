//
//  NSDate+RemainingTime.h
//  SLTUserNotifications
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDate (RemainingTime)
@property (nonatomic, readonly) NSString *slt_localizedRemainingTime;
@property (nonatomic, readonly) NSString *slt_localizedRemainingTimeWithoutPhrase;
@end

NS_ASSUME_NONNULL_END

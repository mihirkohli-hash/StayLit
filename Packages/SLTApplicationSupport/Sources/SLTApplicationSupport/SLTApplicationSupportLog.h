//
//  SLTApplicationSupportLog.h
//  SLTApplicationSupport
//
//

#import <Foundation/Foundation.h>
#import <os/log.h>
#import <SLTCommon/SLTCommon.h>

NS_ASSUME_NONNULL_BEGIN

/// Returns the default log for the ApplicationSupport category.
SLT_EXPORT os_log_t SLTApplicationSupportLog(void);

NS_ASSUME_NONNULL_END

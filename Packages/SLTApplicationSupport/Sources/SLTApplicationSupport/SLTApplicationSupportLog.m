//
//  SLTApplicationSupportLog.m
//  SLTApplicationSupport
//
//

#import "SLTApplicationSupportLog.h"

os_log_t SLTApplicationSupportLog()
{
    static os_log_t log;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        log = SLTLogCreateWithCategory("ApplicationSupport");
    });
    return log;
}

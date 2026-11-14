//
//  SLTActivationDurationsLog.m
//  SLTActivationDurations
//
//

#import "SLTActivationDurationsLog.h"

os_log_t SLTActivationDurationsLog()
{
    static os_log_t log;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        log = SLTLogCreateWithCategory("ActivationDurations");
    });
    return log;
}

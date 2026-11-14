//
//  SLTLog.h
//  SLTCommon
//
//

#import <Foundation/Foundation.h>
#import <os/log.h>

NS_INLINE os_log_t SLTLogCreateWithCategory(const char *category)
{
    return os_log_create("io.github.mihirkohli-hash.StayLit", category);
}

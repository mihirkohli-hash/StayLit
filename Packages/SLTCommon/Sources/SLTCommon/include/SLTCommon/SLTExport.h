//
//  SLTExport.h
//  SLTCommon
//
//

#import <Foundation/Foundation.h>

#if defined(__cplusplus)
    #define SLT_EXPORT extern "C"
#else
    #define SLT_EXPORT extern
#endif

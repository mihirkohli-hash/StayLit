//
//  SLTDisplayParameters.h
//  SLTApplicationSupport
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

/// Returns the number of connected external displays.
/// This function also takes into account when screen mirroring is used.
NSUInteger SLTDisplayParametersGetNumberOfExternalDisplays(void);

NS_ASSUME_NONNULL_END

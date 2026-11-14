//
//  NSBundle+SLTVersion.h
//  SLTApplicationSupport
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSBundle (SLTVersion)

/// Returns the marketing version of this bundle, that is set
/// as the `CFBundleShortVersionString` Info.plist value.
/// e.g. 1.2.3
@property (copy, nonatomic, readonly) NSString *slt_shortVersionString;

/// Returns the build number of this bundle, that is set
/// as the `CFBundleVersion` Info.plist value.
/// e.g. 1020301
@property (copy, nonatomic, readonly) NSString *slt_buildVersionString;

/// Returns the full version string by combining the short version and build version.
/// e.g. 1.2.3 (1020301)
@property (copy, nonatomic, readonly) NSString *slt_fullVersionString;

/// Returns the `NSHumanReadableCopyright` Info.plist value for
/// the human-readable copyright.
@property (copy, nonatomic, readonly) NSString *slt_localizedCopyrightString;

@end

NS_ASSUME_NONNULL_END

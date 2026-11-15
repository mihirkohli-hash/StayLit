//
//  NSBundle+SLTVersion.m
//  SLTApplicationSupport
//

#import <SLTApplicationSupport/NSBundle+SLTVersion.h>
#import <SLTCommon/SLTCommon.h>

static NSString * const SLTShortVersionKey = @"CFBundleShortVersionString";
static NSString * const SLTBundleVersionKey = @"CFBundleVersion";
static NSString * const SLTCopyrightKey = @"NSHumanReadableCopyright";

@implementation NSBundle (SLTVersion)

- (NSString *)slt_shortVersionString
{
    return self.infoDictionary[SLTShortVersionKey];
}

- (NSString *)slt_buildVersionString
{
    return self.infoDictionary[SLTBundleVersionKey];
}

- (NSString *)slt_fullVersionString
{
    return [NSString stringWithFormat:@"%@ (%@)",
            self.slt_shortVersionString,
            self.slt_buildVersionString];
}

#pragma mark - Copyright String

- (NSString *)slt_localizedCopyrightString
{
    return self.infoDictionary[SLTCopyrightKey];
}

@end

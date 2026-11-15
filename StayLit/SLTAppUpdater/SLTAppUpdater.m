//
//  SLTAppUpdater.m
//  StayLit
//

#import "SLTAppUpdater.h"
#import <SLTCommon/SLTCommon.h>

#if SLT_APP_UPDATER_ENABLED

#import <SLTApplicationSupport/SLTApplicationSupport.h>
#import <Sparkle/Sparkle.h>

static NSString * const SLTAppUpdaterReleaseFeedURLString = @"https://mihirkohli-hash.github.io/StayLit/appcast.xml";
static NSString * const SLTAppUpdaterPreReleaseFeedURLString = @"https://mihirkohli-hash.github.io/StayLit/prerelease-appcast.xml";

@interface SLTAppUpdater () <SPUUpdaterDelegate>
@property (nonatomic) SPUStandardUpdaterController *updaterController;
@end

@implementation SLTAppUpdater

+ (SLTAppUpdater *)defaultAppUpdater
{
    static dispatch_once_t once;
    static SLTAppUpdater *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if(self)
    {
        self.updaterController = [[SPUStandardUpdaterController alloc] initWithUpdaterDelegate:self
                                                                            userDriverDelegate:nil];
    }
    return self;
}

- (SPUUpdater *)updater
{
    return self.updaterController.updater;
}

- (void)checkForUpdates:(id)sender
{
    [self.updaterController checkForUpdates:sender];
}

#pragma mark - SPUUpdaterDelegate

- (NSString *)feedURLStringForUpdater:(SPUUpdater *)updater
{
    Auto defaults = NSUserDefaults.standardUserDefaults;
    if([defaults slt_arePreReleaseUpdatesEnabled])
    {
        return SLTAppUpdaterPreReleaseFeedURLString;
    }
    else
    {
        return SLTAppUpdaterReleaseFeedURLString;
    }
}

@end

#endif

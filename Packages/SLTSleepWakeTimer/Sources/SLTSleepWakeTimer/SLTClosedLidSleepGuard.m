//
//  SLTClosedLidSleepGuard.m
//  StayLit
//
//  Created by Mihir Kohli on 2026.
//

#import <SLTSleepWakeTimer/SLTClosedLidSleepGuard.h>
#import <SLTCommon/SLTCommon.h>
#import <IOKit/ps/IOPowerSources.h>
#import "SLTClosedLidSleepGuard+Private.h"

static NSString * const SLTPmsetPath = @"/usr/bin/pmset";
static NSString * const SLTSudoPath = @"/usr/bin/sudo";
static NSString * const SLTSudoersDirectory = @"/etc/sudoers.d";

// Each element is one argument, so `sudo` matches the rule argument by argument.
static NSArray<NSString *> *SLTPmsetSleepDisabledArguments(BOOL disabled)
{
    return @[@"-a", @"disablesleep", disabled ? @"1" : @"0"];
}

// Runs a process, waits for it, and returns its exit status. Output is discarded.
// Returns -1 if the process could not start.
static int SLTRunProcess(NSString *path, NSArray<NSString *> *arguments)
{
    Auto task = [NSTask new];
    task.executableURL = [NSURL fileURLWithPath:path];
    task.arguments = arguments;
    task.standardOutput = NSFileHandle.fileHandleWithNullDevice;
    task.standardError = NSFileHandle.fileHandleWithNullDevice;
    if(![task launchAndReturnError:nil])
    {
        return -1;
    }
    [task waitUntilExit];
    return task.terminationStatus;
}

static NSArray<NSString *> *SLTSudoArgumentsForSleepDisabled(BOOL disabled)
{
    Auto arguments = [NSMutableArray arrayWithObject:@"-n"];
    [arguments addObject:SLTPmsetPath];
    [arguments addObjectsFromArray:SLTPmsetSleepDisabledArguments(disabled)];
    return [arguments copy];
}

@implementation SLTClosedLidSleepGuard

+ (os_log_t)log
{
    static os_log_t log;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ log = SLTLogCreateWithCategory("ClosedLidSleepGuard"); });
    return log;
}

#pragma mark - State

+ (BOOL)isSupported
{
    // macOS sets this variable only for sandboxed apps.
    return NSProcessInfo.processInfo.environment[@"APP_SANDBOX_CONTAINER_ID"] == nil;
}

+ (BOOL)isAuthorized
{
    // `-l` checks the rule without running the command.
    Auto arguments = [NSMutableArray arrayWithObjects:@"-n", @"-l", SLTPmsetPath, nil];
    [arguments addObjectsFromArray:SLTPmsetSleepDisabledArguments(YES)];
    return SLTRunProcess(SLTSudoPath, arguments) == 0;
}

+ (BOOL)isOnBatteryPower
{
    Auto powerSource = IOPSGetProvidingPowerSourceType(NULL);
    Auto isBattery = (powerSource != NULL) && [(__bridge NSString *)powerSource isEqualToString:@kIOPSBatteryPowerValue];
    if(powerSource) { CFRelease(powerSource); }
    return isBattery;
}

#pragma mark - Authorization

+ (NSString *)sudoersFilePathForUserName:(NSString *)userName
{
    // Each user gets their own file. A shared file would let the next user to accept the
    // prompt replace the rule of everyone before them. sudo skips files with a dot in the name.
    Auto safeName = [userName stringByReplacingOccurrencesOfString:@"." withString:@"_"];
    return [SLTSudoersDirectory stringByAppendingPathComponent:[@"staylit-" stringByAppendingString:safeName]];
}

+ (NSString *)sudoersRuleForUserName:(NSString *)userName
{
    // A sudoers rule is plain text. Only these characters are safe in a user name.
    Auto allowed = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789._-"];
    // ALL is a sudoers keyword. As a user name it would grant the rule to everyone.
    if(userName.length == 0 || [userName isEqualToString:@"ALL"] || [userName rangeOfCharacterFromSet:allowed.invertedSet].location != NSNotFound)
    {
        return nil;
    }

    Auto enable = [NSString stringWithFormat:@"%@ %@", SLTPmsetPath, [SLTPmsetSleepDisabledArguments(YES) componentsJoinedByString:@" "]];
    Auto disable = [NSString stringWithFormat:@"%@ %@", SLTPmsetPath, [SLTPmsetSleepDisabledArguments(NO) componentsJoinedByString:@" "]];
    return [NSString stringWithFormat:@"%@ ALL=(root) NOPASSWD: %@, %@", userName, disable, enable];
}

+ (BOOL)installAuthorizationWithError:(NSError **)error
{
    Auto rule = [self sudoersRuleForUserName:NSUserName()];
    if(rule == nil)
    {
        if(error)
        {
            *error = [NSError errorWithDomain:@"SLTClosedLidSleepGuard" code:1 userInfo:@{NSLocalizedDescriptionKey: @"The user name has characters that cannot be used in a sudoers rule."}];
        }
        return NO;
    }

    // visudo checks the rule before it goes live. A broken sudoers file would lock out sudo.
    Auto script = [NSString stringWithFormat:
        @"set -e; t=$(/usr/bin/mktemp); "
        @"/usr/bin/printf '%%s\\n' '%@' > \"$t\"; "
        @"/usr/sbin/visudo -cf \"$t\" > /dev/null; "
        @"/usr/sbin/chown root:wheel \"$t\"; "
        @"/bin/chmod 0440 \"$t\"; "
        @"/bin/mv \"$t\" %@", rule, [self sudoersFilePathForUserName:NSUserName()]];
    Auto escaped = [[script stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"]
                    stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    Auto source = [NSString stringWithFormat:
        @"do shell script \"%@\" with prompt \"StayLit needs your permission once to keep your Mac awake with the lid closed on battery.\" with administrator privileges", escaped];

    NSDictionary<NSString *, id> *errorInfo = nil;
    Auto result = [[[NSAppleScript alloc] initWithSource:source] executeAndReturnError:&errorInfo];
    if(result == nil)
    {
        if(error)
        {
            Auto message = errorInfo[NSAppleScriptErrorMessage] ?: @"The permission could not be installed.";
            *error = [NSError errorWithDomain:@"SLTClosedLidSleepGuard" code:2 userInfo:@{NSLocalizedDescriptionKey: message}];
        }
        return NO;
    }
    return [self isAuthorized];
}

#pragma mark - Session

+ (NSString *)markerPath
{
    Auto supportDirectory = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES).firstObject
                             stringByAppendingPathComponent:@"StayLit"];
    return [supportDirectory stringByAppendingPathComponent:@"lid-sleep-disabled"];
}

+ (BOOL)beginSessionWithWatchedProcessIdentifier:(int)watchedProcessIdentifier
                     caffeinateProcessIdentifier:(int)caffeinateProcessIdentifier
{
    Auto markerPath = self.markerPath;
    [NSFileManager.defaultManager createDirectoryAtPath:markerPath.stringByDeletingLastPathComponent
                            withIntermediateDirectories:YES attributes:nil error:nil];

    // The marker goes first. If the app dies right after, the next launch still knows to reset.
    Auto token = NSUUID.UUID.UUIDString;
    if(![token writeToFile:markerPath atomically:YES encoding:NSUTF8StringEncoding error:nil])
    {
        return NO;
    }

    if(SLTRunProcess(SLTSudoPath, SLTSudoArgumentsForSleepDisabled(YES)) != 0)
    {
        [NSFileManager.defaultManager removeItemAtPath:markerPath error:nil];
        os_log(self.log, "Could not turn SleepDisabled on. The sudoers rule is probably missing.");
        return NO;
    }

    Auto resetCommand = [@[SLTSudoPath] arrayByAddingObjectsFromArray:SLTSudoArgumentsForSleepDisabled(NO)];
    Auto watchdog = [self launchWatchdogForProcessIdentifier:watchedProcessIdentifier
                                 caffeinateProcessIdentifier:caffeinateProcessIdentifier
                                                  markerPath:markerPath
                                                       token:token
                                                resetCommand:resetCommand];
    if(watchdog == nil)
    {
        // Without a watchdog nothing would turn the setting off again.
        SLTRunProcess(SLTSudoPath, SLTSudoArgumentsForSleepDisabled(NO));
        [NSFileManager.defaultManager removeItemAtPath:markerPath error:nil];
        return NO;
    }
    os_log(self.log, "SleepDisabled is on for this session.");
    return YES;
}

+ (NSTask *)launchWatchdogForProcessIdentifier:(int)watchedProcessIdentifier
                   caffeinateProcessIdentifier:(int)caffeinateProcessIdentifier
                                    markerPath:(NSString *)markerPath
                                         token:(NSString *)token
                                  resetCommand:(NSArray<NSString *> *)resetCommand
{
    // The marker is removed only after a successful reset. A failed reset keeps it,
    // so the next launch tries again.
    Auto script =
        @"app=$1; caffeinate=$2; marker=$3; token=$4; shift 4\n"
        @"while kill -0 \"$app\" 2>/dev/null && kill -0 \"$caffeinate\" 2>/dev/null; do sleep 1; done\n"
        @"[ \"$(cat \"$marker\" 2>/dev/null)\" = \"$token\" ] || exit 0\n"
        @"\"$@\" || exit 1\n"
        @"[ \"$(cat \"$marker\" 2>/dev/null)\" = \"$token\" ] && rm -f \"$marker\"\n"
        @"exit 0\n";

    Auto arguments = [NSMutableArray arrayWithObjects:@"-c", script, @"sh",
                      [NSString stringWithFormat:@"%i", watchedProcessIdentifier],
                      [NSString stringWithFormat:@"%i", caffeinateProcessIdentifier],
                      markerPath, token, nil];
    [arguments addObjectsFromArray:resetCommand];

    Auto task = [NSTask new];
    task.executableURL = [NSURL fileURLWithPath:@"/bin/sh"];
    task.arguments = arguments;
    task.standardOutput = NSFileHandle.fileHandleWithNullDevice;
    task.standardError = NSFileHandle.fileHandleWithNullDevice;
    return [task launchAndReturnError:nil] ? task : nil;
}

+ (void)resetIfLeftEnabledByPreviousRun
{
    Auto markerPath = self.markerPath;
    if(![NSFileManager.defaultManager fileExistsAtPath:markerPath])
    {
        return;
    }

    if(SLTRunProcess(SLTSudoPath, SLTSudoArgumentsForSleepDisabled(NO)) == 0)
    {
        [NSFileManager.defaultManager removeItemAtPath:markerPath error:nil];
        os_log(self.log, "Turned SleepDisabled off after a previous run left it on.");
    }
}

@end

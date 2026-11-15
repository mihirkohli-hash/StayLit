//
//  SLTStatusItemPulseTests.m
//  SLTStatusItemUI
//
//  Created by Mihir Kohli on 2026.
//

#import <XCTest/XCTest.h>
#import <QuartzCore/QuartzCore.h>
#import <SLTCommon/SLTCommon.h>
#import <SLTApplicationSupport/SLTApplicationSupport.h>
#import <SLTStatusItemUI/SLTStatusItemController.h>
#import <SLTStatusItemUI/SLTStatusItemImageProvider.h>
#import "../../Sources/SLTStatusItemUI/SLTStatusItemController+Private.h"
#import "../../Sources/SLTStatusItemUI/SLTStatusItemImageProvider/NSImage+SLTStatusItemImage.h"

// A layer that counts how often an animation is added.
@interface SLTCountingLayer : CALayer
@property (nonatomic) NSUInteger addAnimationCount;
@end

@implementation SLTCountingLayer
- (void)addAnimation:(CAAnimation *)animation forKey:(NSString *)key
{
    self.addAnimationCount++;
    [super addAnimation:animation forKey:key];
}
@end

@interface SLTCountingLayerView : NSView
@end

@implementation SLTCountingLayerView
- (CALayer *)makeBackingLayer { return [SLTCountingLayer layer]; }
@end

@interface SLTStatusItemPulseTests : XCTestCase
@property (nonatomic, copy, nullable) id previousPulseDisabledValue;
@end

@implementation SLTStatusItemPulseTests

- (void)setUp
{
    [super setUp];
    self.previousPulseDisabledValue = [NSUserDefaults.standardUserDefaults objectForKey:SLTUserDefaultsKeyMenuBarIconPulseDisabled];
}

- (void)tearDown
{
    if(self.previousPulseDisabledValue) { [NSUserDefaults.standardUserDefaults setObject:self.previousPulseDisabledValue forKey:SLTUserDefaultsKeyMenuBarIconPulseDisabled]; }
    else { [NSUserDefaults.standardUserDefaults removeObjectForKey:SLTUserDefaultsKeyMenuBarIconPulseDisabled]; }
    [super tearDown];
}

#pragma mark - Decision

- (void)testOnlyAnActiveIconPulsesWhenNothingStopsIt
{
    XCTAssertTrue([SLTStatusItemController shouldPulseForAppearance:SLTStatusItemAppearanceActive pulseDisabled:NO reduceMotion:NO screensAsleep:NO]);
}

- (void)testInactiveIconNeverPulses
{
    for(NSNumber *disabled in @[@NO, @YES])
    {
        for(NSNumber *reduceMotion in @[@NO, @YES])
        {
            XCTAssertFalse([SLTStatusItemController shouldPulseForAppearance:SLTStatusItemAppearanceInactive
                                                               pulseDisabled:disabled.boolValue
                                                                reduceMotion:reduceMotion.boolValue
                                                               screensAsleep:NO]);
        }
    }
}

- (void)testPulseStopsWhenTheUserTurnedItOff
{
    XCTAssertFalse([SLTStatusItemController shouldPulseForAppearance:SLTStatusItemAppearanceActive pulseDisabled:YES reduceMotion:NO screensAsleep:NO]);
}

- (void)testPulseStopsWhileTheDisplaysAreAsleep
{
    // With the lid closed on battery nobody sees the menu bar, so a 20 times a second timer would only waste power.
    XCTAssertFalse([SLTStatusItemController shouldPulseForAppearance:SLTStatusItemAppearanceActive pulseDisabled:NO reduceMotion:NO screensAsleep:YES]);
    XCTAssertFalse([SLTStatusItemController shouldPulseForAppearance:SLTStatusItemAppearanceInactive pulseDisabled:NO reduceMotion:NO screensAsleep:YES]);
}

- (void)testPulseStopsWhenMacOSReducesMotion
{
    XCTAssertFalse([SLTStatusItemController shouldPulseForAppearance:SLTStatusItemAppearanceActive pulseDisabled:NO reduceMotion:YES screensAsleep:NO]);
    XCTAssertFalse([SLTStatusItemController shouldPulseForAppearance:SLTStatusItemAppearanceActive pulseDisabled:YES reduceMotion:YES screensAsleep:NO]);
}

#pragma mark - Animation

- (void)testPulsingAddsAForeverRepeatingFadeThatReverses
{
    Auto view = [SLTCountingLayerView new];
    [SLTStatusItemController setPulsing:YES forView:view duration:1.0];

    Auto animation = (CABasicAnimation *)[view.layer animationForKey:SLTStatusItemPulseAnimationKey];
    XCTAssertNotNil(animation);
    XCTAssertEqualObjects(animation.keyPath, @"opacity");
    XCTAssertEqualObjects(animation.fromValue, @1.0);
    XCTAssertEqualObjects(animation.toValue, @0.35);
    XCTAssertEqual(animation.duration, 0.5);
    XCTAssertTrue(animation.autoreverses);
    XCTAssertEqual(animation.repeatCount, HUGE_VALF, @"The pulse must run until it is stopped.");
}

- (void)testStartingTwiceKeepsTheRunningAnimation
{
    // Adding the animation again would restart the fade and make the icon jump.
    Auto view = [SLTCountingLayerView new];
    [SLTStatusItemController setPulsing:YES forView:view duration:1.0];
    [SLTStatusItemController setPulsing:YES forView:view duration:1.0];
    [SLTStatusItemController setPulsing:YES forView:view duration:1.0];

    XCTAssertEqual(((SLTCountingLayer *)view.layer).addAnimationCount, 1u);
}

- (void)testFadeTakesHalfTheDurationInEachDirection
{
    Auto view = [SLTCountingLayerView new];
    [SLTStatusItemController setPulsing:YES forView:view duration:3.0];

    Auto animation = (CABasicAnimation *)[view.layer animationForKey:SLTStatusItemPulseAnimationKey];
    XCTAssertEqual(animation.duration, 1.5, @"The fade reverses, so down plus up is one full duration.");
}

- (void)testFadeIsReplacedWhenTheDurationChangesButKeptWhenItStaysTheSame
{
    Auto view = [SLTCountingLayerView new];
    [SLTStatusItemController setPulsing:YES forView:view duration:1.0];
    [SLTStatusItemController setPulsing:YES forView:view duration:1.0];
    XCTAssertEqual(((SLTCountingLayer *)view.layer).addAnimationCount, 1u, @"The same duration must not restart the fade.");

    [SLTStatusItemController setPulsing:YES forView:view duration:2.0];
    XCTAssertEqual(((SLTCountingLayer *)view.layer).addAnimationCount, 2u);
    XCTAssertEqual([view.layer animationForKey:SLTStatusItemPulseAnimationKey].duration, 1.0);
}

- (void)testStoppingRemovesTheAnimationAndLeavesTheIconFullyVisible
{
    Auto view = [SLTCountingLayerView new];
    [SLTStatusItemController setPulsing:YES forView:view duration:1.0];
    [SLTStatusItemController setPulsing:NO forView:view duration:1.0];

    XCTAssertNil([view.layer animationForKey:SLTStatusItemPulseAnimationKey]);
    XCTAssertEqual(view.layer.opacity, 1.0f);
}

- (void)testStoppingWithoutAPulseIsHarmless
{
    Auto view = [SLTCountingLayerView new];
    [SLTStatusItemController setPulsing:NO forView:view duration:1.0];
    XCTAssertEqual(view.layer.animationKeys.count, 0u);
}

- (void)testPulsingCanStartAgainAfterAStop
{
    Auto view = [SLTCountingLayerView new];
    [SLTStatusItemController setPulsing:YES forView:view duration:1.0];
    [SLTStatusItemController setPulsing:NO forView:view duration:1.0];
    [SLTStatusItemController setPulsing:YES forView:view duration:1.0];

    XCTAssertNotNil([view.layer animationForKey:SLTStatusItemPulseAnimationKey]);
    XCTAssertEqual(((SLTCountingLayer *)view.layer).addAnimationCount, 2u);
}

#pragma mark - Wiring

// Returns how many different images the button showed while the run loop ran.
// A busy machine can run the timer much slower than 20 times a second, so tests only ask whether
// the icon moves at all (two or more images). The exact frames are checked by stepping them by hand.
- (NSUInteger)distinctImagesShownBy:(NSButton *)button over:(NSTimeInterval)duration
{
    Auto seen = [NSMutableSet<NSValue *> new];
    Auto deadline = [NSDate dateWithTimeIntervalSinceNow:duration];
    while(deadline.timeIntervalSinceNow > 0)
    {
        [seen addObject:[NSValue valueWithNonretainedObject:button.image]];
        [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.04]];
    }
    return seen.count;
}

- (void)testStatusItemPulsesItsScreenOnlyWhileActiveAndWhenNotDisabled
{
    [NSUserDefaults.standardUserDefaults removeObjectForKey:SLTUserDefaultsKeyMenuBarIconPulseDisabled];
    Auto controller = [SLTStatusItemController new];
    Auto button = controller.systemStatusItem.button;
    if(button == nil) { XCTSkip(@"No menu bar is available in this session."); }
    controller.reduceMotionOverride = @NO;

    controller.appearance = SLTStatusItemAppearanceInactive;
    XCTAssertEqual([self distinctImagesShownBy:button over:0.5], 1u, @"An inactive icon must be still.");

    controller.appearance = SLTStatusItemAppearanceActive;
    XCTAssertGreaterThanOrEqual([self distinctImagesShownBy:button over:1.0], 2u, @"An active icon cycles through the pulse frames.");
    XCTAssertNil([button.layer animationForKey:SLTStatusItemPulseAnimationKey], @"The body must not fade. Only the screen pulses.");

    // Turning the setting off must stop a pulse that is already running.
    NSUserDefaults.standardUserDefaults.slt_menuBarIconPulseDisabled = YES;
    [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.3]];
    XCTAssertEqual([self distinctImagesShownBy:button over:0.5], 1u, @"The setting stops the pulse at once.");
    XCTAssertTrue(button.image == SLTStatusItemImageProvider.currentProvider.activeIconImage, @"A stopped pulse shows the steady active icon.");

    NSUserDefaults.standardUserDefaults.slt_menuBarIconPulseDisabled = NO;
    [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.3]];
    XCTAssertGreaterThanOrEqual([self distinctImagesShownBy:button over:1.0], 2u, @"Turning it back on resumes the pulse.");

    controller.appearance = SLTStatusItemAppearanceInactive;
    XCTAssertEqual([self distinctImagesShownBy:button over:0.5], 1u, @"Deactivating stops the pulse.");
    XCTAssertTrue(button.image == SLTStatusItemImageProvider.currentProvider.inactiveIconImage, @"Deactivating shows the inactive icon.");

    [NSStatusBar.systemStatusBar removeStatusItem:controller.systemStatusItem];
}

- (void)testReduceMotionKeepsTheIconStillAndStopsARunningPulse
{
    [NSUserDefaults.standardUserDefaults removeObjectForKey:SLTUserDefaultsKeyMenuBarIconPulseDisabled];
    Auto controller = [SLTStatusItemController new];
    Auto button = controller.systemStatusItem.button;
    if(button == nil) { XCTSkip(@"No menu bar is available in this session."); }

    // With Reduce Motion on from the start, an active icon stays still.
    controller.reduceMotionOverride = @YES;
    controller.appearance = SLTStatusItemAppearanceActive;
    XCTAssertNil(controller.pulseTimer);
    XCTAssertEqual([self distinctImagesShownBy:button over:0.5], 1u, @"Reduce Motion is on.");

    // Turning it off in System Settings starts the pulse, turning it on again stops it.
    Auto center = NSWorkspace.sharedWorkspace.notificationCenter;
    controller.reduceMotionOverride = @NO;
    [center postNotificationName:NSWorkspaceAccessibilityDisplayOptionsDidChangeNotification object:NSWorkspace.sharedWorkspace];
    [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.2]]; // the controller reacts on the next turn of the run loop
    XCTAssertNotNil(controller.pulseTimer, @"The pulse starts when Reduce Motion goes off.");
    XCTAssertGreaterThanOrEqual([self distinctImagesShownBy:button over:1.0], 2u);

    controller.reduceMotionOverride = @YES;
    [center postNotificationName:NSWorkspaceAccessibilityDisplayOptionsDidChangeNotification object:NSWorkspace.sharedWorkspace];
    [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.2]];
    XCTAssertNil(controller.pulseTimer, @"The pulse stops when Reduce Motion goes on.");
    XCTAssertEqual([self distinctImagesShownBy:button over:0.5], 1u);

    controller.appearance = SLTStatusItemAppearanceInactive;
    [NSStatusBar.systemStatusBar removeStatusItem:controller.systemStatusItem];
}

- (void)testFrameTimerStepsTwentyTimesASecondAndTheCycleFollowsTheDuration
{
    Auto previous = [NSUserDefaults.standardUserDefaults objectForKey:SLTUserDefaultsKeyMenuBarIconPulseDurationMilliseconds];
    [NSUserDefaults.standardUserDefaults removeObjectForKey:SLTUserDefaultsKeyMenuBarIconPulseDisabled];
    [NSUserDefaults.standardUserDefaults removeObjectForKey:SLTUserDefaultsKeyMenuBarIconPulseDurationMilliseconds];

    Auto controller = [SLTStatusItemController new];
    Auto button = controller.systemStatusItem.button;
    if(button == nil) { XCTSkip(@"No menu bar is available in this session."); }
    controller.reduceMotionOverride = @NO;

    controller.appearance = SLTStatusItemAppearanceActive;
    XCTAssertEqualWithAccuracy(controller.pulseTimer.timeInterval, 2.0 / 40.0, 0.0001, @"The default is a two second cycle of 40 steps.");
    XCTAssertEqualWithAccuracy(controller.pulseTimer.timeInterval, 1.0 / 20.0, 0.0001, @"A step lasts a twentieth of a second.");

    // A different duration changes how many steps one cycle has, so the frames are smooth at every speed.
    for(NSNumber *seconds in @[@0.5, @1.0, @3.0, @5.0])
    {
        NSUserDefaults.standardUserDefaults.slt_menuBarIconPulseDuration = seconds.doubleValue;
        [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.2]];
        Auto count = SLTStatusItemPulseFrameCountForDuration(seconds.doubleValue);
        XCTAssertEqualWithAccuracy(controller.pulseTimer.timeInterval * (NSTimeInterval)count, seconds.doubleValue, 0.001, @"One cycle must last %@ seconds", seconds);
    }

    // The cycle repeats after exactly its frame count. This steps the frames by hand, so it does not
    // depend on how fast the timer runs on a busy machine. A 0.5 second pulse has 10 images.
    NSUserDefaults.standardUserDefaults.slt_menuBarIconPulseDuration = 0.5;
    [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.3]];
    Auto shortCycle = [NSMutableArray<NSImage *> new];
    for(int step = 0; step < 20; step++) { [controller showNextPulseFrame]; [shortCycle addObject:button.image]; }
    XCTAssertEqual([NSSet setWithArray:shortCycle].count, 10u, @"A 0.5 second pulse has 10 different images.");
    XCTAssertEqualObjects([shortCycle subarrayWithRange:NSMakeRange(0, 10)], [shortCycle subarrayWithRange:NSMakeRange(10, 10)], @"The second cycle repeats the first.");

    // A 5 second pulse has 100 images, so 100 steps show no image twice.
    NSUserDefaults.standardUserDefaults.slt_menuBarIconPulseDuration = 5.0;
    [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.3]];
    Auto longCycle = [NSMutableArray<NSImage *> new];
    for(int step = 0; step < 100; step++) { [controller showNextPulseFrame]; [longCycle addObject:button.image]; }
    XCTAssertEqual([NSSet setWithArray:longCycle].count, 100u, @"A 5 second pulse does not repeat within its cycle.");

    controller.appearance = SLTStatusItemAppearanceInactive;
    XCTAssertNil(controller.pulseTimer, @"Deactivating stops the timer, whatever the speed.");
    [NSStatusBar.systemStatusBar removeStatusItem:controller.systemStatusItem];
    if(previous) { [NSUserDefaults.standardUserDefaults setObject:previous forKey:SLTUserDefaultsKeyMenuBarIconPulseDurationMilliseconds]; }
    else { [NSUserDefaults.standardUserDefaults removeObjectForKey:SLTUserDefaultsKeyMenuBarIconPulseDurationMilliseconds]; }
}

- (void)testPulsePausesWhileTheDisplaysSleepAndResumesWhenTheyWake
{
    [NSUserDefaults.standardUserDefaults removeObjectForKey:SLTUserDefaultsKeyMenuBarIconPulseDisabled];
    Auto controller = [SLTStatusItemController new];
    Auto button = controller.systemStatusItem.button;
    if(button == nil) { XCTSkip(@"No menu bar is available in this session."); }
    controller.reduceMotionOverride = @NO;

    controller.appearance = SLTStatusItemAppearanceActive;
    XCTAssertNotNil(controller.pulseTimer);

    Auto center = NSWorkspace.sharedWorkspace.notificationCenter;
    [center postNotificationName:NSWorkspaceScreensDidSleepNotification object:NSWorkspace.sharedWorkspace];
    XCTAssertTrue(controller.screensAsleep);
    XCTAssertNil(controller.pulseTimer, @"No timer may run while nobody can see the icon.");
    XCTAssertTrue(button.image == [SLTStatusItemImageProvider.currentProvider activeIconImage], @"The steady active icon shows while paused.");

    [center postNotificationName:NSWorkspaceScreensDidWakeNotification object:NSWorkspace.sharedWorkspace];
    XCTAssertFalse(controller.screensAsleep);
    XCTAssertNotNil(controller.pulseTimer, @"The pulse starts again when the displays wake.");
    XCTAssertGreaterThanOrEqual([self distinctImagesShownBy:button over:0.8], 2u);

    controller.appearance = SLTStatusItemAppearanceInactive;
    [NSStatusBar.systemStatusBar removeStatusItem:controller.systemStatusItem];
}

- (void)testPulseSurvivesAnIconColorChangeWhileRunning
{
    Auto previousColor = [NSUserDefaults.standardUserDefaults objectForKey:SLTUserDefaultsKeyMenuBarIconColor];
    [NSUserDefaults.standardUserDefaults removeObjectForKey:SLTUserDefaultsKeyMenuBarIconPulseDisabled];
    NSUserDefaults.standardUserDefaults.slt_menuBarIconColor = SLTMenuBarIconColorWhite;

    Auto controller = [SLTStatusItemController new];
    Auto button = controller.systemStatusItem.button;
    if(button == nil) { XCTSkip(@"No menu bar is available in this session."); }
    controller.reduceMotionOverride = @NO;

    controller.appearance = SLTStatusItemAppearanceActive;
    Auto whiteFrames = [SLTStatusItemImageProvider.currentProvider pulseFramesForDuration:NSUserDefaults.standardUserDefaults.slt_menuBarIconPulseDuration];

    NSUserDefaults.standardUserDefaults.slt_menuBarIconColor = SLTMenuBarIconColorDark;
    [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.4]];

    XCTAssertGreaterThanOrEqual([self distinctImagesShownBy:button over:1.0], 2u, @"The pulse keeps running after the color changes.");
    XCTAssertFalse([whiteFrames containsObject:button.image], @"The pulse now shows frames of the new color.");

    controller.appearance = SLTStatusItemAppearanceInactive;
    [NSStatusBar.systemStatusBar removeStatusItem:controller.systemStatusItem];
    if(previousColor) { [NSUserDefaults.standardUserDefaults setObject:previousColor forKey:SLTUserDefaultsKeyMenuBarIconColor]; }
    else { [NSUserDefaults.standardUserDefaults removeObjectForKey:SLTUserDefaultsKeyMenuBarIconColor]; }
}

@end

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
#import "../../Sources/SLTStatusItemUI/SLTStatusItemController+Private.h"

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
    XCTAssertTrue([SLTStatusItemController shouldPulseForAppearance:SLTStatusItemAppearanceActive pulseDisabled:NO reduceMotion:NO]);
}

- (void)testInactiveIconNeverPulses
{
    for(NSNumber *disabled in @[@NO, @YES])
    {
        for(NSNumber *reduceMotion in @[@NO, @YES])
        {
            XCTAssertFalse([SLTStatusItemController shouldPulseForAppearance:SLTStatusItemAppearanceInactive
                                                               pulseDisabled:disabled.boolValue
                                                                reduceMotion:reduceMotion.boolValue]);
        }
    }
}

- (void)testPulseStopsWhenTheUserTurnedItOff
{
    XCTAssertFalse([SLTStatusItemController shouldPulseForAppearance:SLTStatusItemAppearanceActive pulseDisabled:YES reduceMotion:NO]);
}

- (void)testPulseStopsWhenMacOSReducesMotion
{
    XCTAssertFalse([SLTStatusItemController shouldPulseForAppearance:SLTStatusItemAppearanceActive pulseDisabled:NO reduceMotion:YES]);
    XCTAssertFalse([SLTStatusItemController shouldPulseForAppearance:SLTStatusItemAppearanceActive pulseDisabled:YES reduceMotion:YES]);
}

#pragma mark - Animation

- (void)testPulsingAddsAForeverRepeatingFadeThatReverses
{
    Auto view = [SLTCountingLayerView new];
    [SLTStatusItemController setPulsing:YES forView:view];

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
    [SLTStatusItemController setPulsing:YES forView:view];
    [SLTStatusItemController setPulsing:YES forView:view];
    [SLTStatusItemController setPulsing:YES forView:view];

    XCTAssertEqual(((SLTCountingLayer *)view.layer).addAnimationCount, 1u);
}

- (void)testStoppingRemovesTheAnimationAndLeavesTheIconFullyVisible
{
    Auto view = [SLTCountingLayerView new];
    [SLTStatusItemController setPulsing:YES forView:view];
    [SLTStatusItemController setPulsing:NO forView:view];

    XCTAssertNil([view.layer animationForKey:SLTStatusItemPulseAnimationKey]);
    XCTAssertEqual(view.layer.opacity, 1.0f);
}

- (void)testStoppingWithoutAPulseIsHarmless
{
    Auto view = [SLTCountingLayerView new];
    [SLTStatusItemController setPulsing:NO forView:view];
    XCTAssertEqual(view.layer.animationKeys.count, 0u);
}

- (void)testPulsingCanStartAgainAfterAStop
{
    Auto view = [SLTCountingLayerView new];
    [SLTStatusItemController setPulsing:YES forView:view];
    [SLTStatusItemController setPulsing:NO forView:view];
    [SLTStatusItemController setPulsing:YES forView:view];

    XCTAssertNotNil([view.layer animationForKey:SLTStatusItemPulseAnimationKey]);
    XCTAssertEqual(((SLTCountingLayer *)view.layer).addAnimationCount, 2u);
}

#pragma mark - Wiring

- (void)spinRunLoop
{
    [NSRunLoop.currentRunLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.3]];
}

- (void)testStatusItemPulsesOnlyWhileActiveAndWhenNotDisabled
{
    [NSUserDefaults.standardUserDefaults removeObjectForKey:SLTUserDefaultsKeyMenuBarIconPulseDisabled];
    Auto controller = [SLTStatusItemController new];
    Auto button = controller.systemStatusItem.button;
    if(button == nil) { XCTSkip(@"No menu bar is available in this session."); }

    // Under Reduce Motion the status item must not pulse, so only assert the full behavior without it.
    Auto reduceMotion = NSWorkspace.sharedWorkspace.accessibilityDisplayShouldReduceMotion;

    controller.appearance = SLTStatusItemAppearanceInactive;
    XCTAssertNil([button.layer animationForKey:SLTStatusItemPulseAnimationKey], @"An inactive icon must be still.");

    controller.appearance = SLTStatusItemAppearanceActive;
    if(reduceMotion)
    {
        XCTAssertNil([button.layer animationForKey:SLTStatusItemPulseAnimationKey], @"Reduce Motion is on.");
    }
    else
    {
        XCTAssertNotNil([button.layer animationForKey:SLTStatusItemPulseAnimationKey], @"An active icon pulses.");

        // Turning the setting off must stop a pulse that is already running.
        NSUserDefaults.standardUserDefaults.slt_menuBarIconPulseDisabled = YES;
        [self spinRunLoop];
        XCTAssertNil([button.layer animationForKey:SLTStatusItemPulseAnimationKey], @"The setting stops the pulse at once.");

        NSUserDefaults.standardUserDefaults.slt_menuBarIconPulseDisabled = NO;
        [self spinRunLoop];
        XCTAssertNotNil([button.layer animationForKey:SLTStatusItemPulseAnimationKey], @"Turning it back on resumes the pulse.");
    }

    controller.appearance = SLTStatusItemAppearanceInactive;
    XCTAssertNil([button.layer animationForKey:SLTStatusItemPulseAnimationKey], @"Deactivating stops the pulse.");

    [NSStatusBar.systemStatusBar removeStatusItem:controller.systemStatusItem];
}

@end

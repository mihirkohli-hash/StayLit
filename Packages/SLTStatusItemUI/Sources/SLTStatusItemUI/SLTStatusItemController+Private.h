//
//  SLTStatusItemController+Private.h
//  StayLit
//
//  Created by Mihir Kohli on 2026.
//

#import <SLTStatusItemUI/SLTStatusItemController.h>

NS_ASSUME_NONNULL_BEGIN

/// The key of the pulse animation on the status item layer.
extern NSString * const SLTStatusItemPulseAnimationKey;

@interface SLTStatusItemController ()

/// Returns YES if the icon should pulse. Only an active icon pulses, and never when the user
/// turned it off, asked macOS to reduce motion, or when the displays are asleep and nobody sees it.
+ (BOOL)shouldPulseForAppearance:(SLTStatusItemAppearance)appearance
                   pulseDisabled:(BOOL)pulseDisabled
                    reduceMotion:(BOOL)reduceMotion
                    screensAsleep:(BOOL)screensAsleep;

/// YES between the displays going to sleep and waking up, for example with the lid closed.
@property (nonatomic) BOOL screensAsleep;

/// Replaces the Reduce Motion setting of macOS. It exists for tests, which must give the same
/// result on a Mac that has Reduce Motion on and one that has it off. Leave it nil in the app.
@property (nonatomic, nullable) NSNumber *reduceMotionOverride;

/// Starts or stops the fade of a whole view. This is for custom icons, which have no separate screen.
///
/// One fade down and back up takes `duration`. Starting again with the same duration keeps the
/// running animation, because restarting it would make the icon jump. A different duration replaces it.
+ (void)setPulsing:(BOOL)pulsing forView:(NSView *)view duration:(NSTimeInterval)duration;

/// The timer that steps through the pulse frames, or nil while the screen does not pulse.
@property (nonatomic, nullable) NSTimer *pulseTimer;

@end

NS_ASSUME_NONNULL_END

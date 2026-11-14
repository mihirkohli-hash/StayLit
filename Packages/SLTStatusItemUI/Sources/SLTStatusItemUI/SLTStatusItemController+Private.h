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

/// Returns YES if the icon should pulse. Only an active icon pulses, and never
/// when the user turned it off or asked macOS to reduce motion.
+ (BOOL)shouldPulseForAppearance:(SLTStatusItemAppearance)appearance
                   pulseDisabled:(BOOL)pulseDisabled
                    reduceMotion:(BOOL)reduceMotion;

/// Starts or stops the pulse on a view. Starting twice keeps the running animation,
/// because restarting it would make the icon jump.
+ (void)setPulsing:(BOOL)pulsing forView:(NSView *)view;

@end

NS_ASSUME_NONNULL_END

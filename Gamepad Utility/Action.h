//
//  Action.h
//  Gamepad Utility
//
//  Created by Konstantin Sukharev on 16/01/15.
//  Copyright (c) 2015 P0ed. All rights reserved.
//


@import Foundation;
@class OEHIDEvent;


typedef NS_ENUM(NSInteger, ActionType) {

	ActionTypeButton,
	ActionTypeDPad,
	ActionTypeStick,
	ActionTypeTrigger
};


@interface Action : NSObject /*<NSCoding>*/

@property (nonatomic) ActionType type;

// Button actions
+ (instancetype)buttonKeyAction:(CGKeyCode)keyCode;
+ (instancetype)buttonMouseClickAction:(CGMouseButton)mouseButton;

// Stick actions
+ (instancetype)stickMouseMoveAction;
+ (instancetype)stickScrollAction;

// D-Pad actions:
+ (instancetype)dPadArrowsAction;
+ (instancetype)dPadWASDAction;

// Trigger actions:
+ (instancetype)triggerKeyAction:(CGKeyCode)keyCode;
+ (instancetype)triggerMouseClickAction:(CGMouseButton)mouseButton;
+ (instancetype)triggerLModifierAction;
+ (instancetype)triggerRModifierAction;

// Compound key action
+ (instancetype)compoundKeyAction:(NSArray *)keyCodes;

- (void)postEvent:(NSValue *)input;

@end


@interface NSNumber (Action)
- (Action *)buttonKeyAction;
- (Action *)triggerKeyAction;
- (Action *)buttonMouseClickAction;
- (Action *)triggerMouseClickAction;
@end


@interface NSArray (Action)
- (Action *)compoundKeyAction;
@end

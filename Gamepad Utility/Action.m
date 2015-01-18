//
//  Action.m
//  Gamepad Utility
//
//  Created by Konstantin Sukharev on 16/01/15.
//  Copyright (c) 2015 P0ed. All rights reserved.
//

#import "Action.h"
#import "OpenEmuSystem/OEHIDEvent.h"
#import "Event.h"
#import "NSValue+CGVector.h"
@import Carbon.HIToolbox.Events;


@interface Action ()
@property (nonatomic, copy) void (^postEventBlock)(id input);
@end


@implementation Action

#pragma mark Button actions
+ (instancetype)buttonKeyAction:(CGKeyCode)keyCode {
	
	Action *action = Action.new;
	action.type = ActionTypeButton;
	action.postEventBlock = ^(NSNumber *input) {
		[Event postKeyboardEvent:keyCode keyDown:input.boolValue];
	};
	
	return action;
}

+ (instancetype)buttonMouseClickAction:(CGMouseButton)mouseButton {
	
	Action *action = Action.new;
	action.type = ActionTypeButton;
	action.postEventBlock = ^(NSNumber *input) {
		[Event postMouseClickEvent:mouseButton buttonDown:input.boolValue];
	};
	
	return action;
}

#pragma mark Stick actions
+ (instancetype)stickMouseMoveAction {
	
	Action *action = Action.new;
	action.type = ActionTypeStick;
	action.postEventBlock = ^(NSValue *input) {
		[Event postMouseMoveEvent:input.vectorValue];
	};
	
	return action;
}

+ (instancetype)stickScrollAction {
	
	Action *action = Action.new;
	action.type = ActionTypeStick;
	action.postEventBlock = ^(NSValue *input) {
		[Event postScrollEvent:input.vectorValue];
	};
	
	return action;
}

#pragma mark D-Pad actions:
+ (instancetype)dPadActionWithMap:(NSDictionary *)map {
	
	Action *action = Action.new;
	action.type = ActionTypeDPad;
	
	action.postEventBlock = ^(NSNumber *input) {
		
		uint8_t dPadState = input.intValue & 0xFF;
		for (int i = 0; i < 8; ++i) {
			
			if (dPadState & 1 << i) {
				[Event postKeyboardEvent:[map[@((1 << i % 4))] intValue] keyDown:i > 3];
			}
		}
	};
	
	return action;
}

+ (instancetype)dPadArrowsAction {
	
	NSDictionary *map = @{@(1 << 0): @(kVK_UpArrow),
						  @(1 << 1): @(kVK_RightArrow),
						  @(1 << 2): @(kVK_DownArrow),
						  @(1 << 3): @(kVK_LeftArrow)};
	
	return [self dPadActionWithMap:map];
}

+ (instancetype)dPadWASDAction {
	
	NSDictionary *map = @{@(1 << 0): @(kVK_ANSI_W),
						  @(1 << 1): @(kVK_ANSI_D),
						  @(1 << 2): @(kVK_ANSI_S),
						  @(1 << 3): @(kVK_ANSI_A)};
	
	return [self dPadActionWithMap:map];
}

#pragma mark Trigger actions:
+ (instancetype)triggerKeyAction:(CGKeyCode)keyCode {
	Action *action = Action.new;
	return action;
}

+ (instancetype)triggerMouseClickAction:(CGMouseButton)mouseButton {
	Action *action = Action.new;
	return action;
}

+ (instancetype)triggerLModifierAction {
	Action *action = Action.new;
	return action;
}

+ (instancetype)triggerRModifierAction {
	Action *action = Action.new;
	return action;
}

#pragma mark Compound key action
+ (instancetype)compoundKeyAction:(NSArray *)keyCodes {
	Action *action = Action.new;
	return action;
}

#pragma mark -

- (void)postEvent:(NSValue *)input {
	if (_postEventBlock) _postEventBlock(input);
}

@end


#pragma mark - Literal convertibles
@implementation NSNumber (Action)

- (Action *)buttonKeyAction {
	return [Action buttonKeyAction:self.intValue];
}

- (Action *)triggerKeyAction {
	return [Action triggerKeyAction:self.intValue];
}

- (Action *)buttonMouseClickAction {
	return [Action buttonMouseClickAction:self.intValue];
}

- (Action *)triggerMouseClickAction {
	return [Action triggerMouseClickAction:self.intValue];
}

@end


@implementation NSArray (Action)

- (Action *)compoundKeyAction {
	return [Action compoundKeyAction:self];
}

@end

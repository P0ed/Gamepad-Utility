//
//  EventsController.m
//  Gamepad Utility
//
//  Created by Konstantin Sukharev on 17/01/15.
//  Copyright (c) 2015 P0ed. All rights reserved.
//

#import "EventsController.h"
#import "MapConfiguration.h"
#import "Action.h"
#import "Event.h"
#import "OpenEmuSystem/OEHIDEvent.h"
#import "NSValue+CGVector.h"
#import "Vectors.h"


@interface EventsController	()
@property (nonatomic) OEDeviceHandler *deviceHandler;
@property (nonatomic) DSModifierFlags modifierFlags;
@end


@implementation EventsController {
	
	NSTimer *_timer;
	
	CGVector _leftJoystick;
	CGVector _rightJoystick;
	CGFloat _leftTrigger;
	CGFloat _rightTrigger;
	OEHIDEventHatDirection _hatDirection;
	
	NSMutableDictionary *_events;
}

+ (instancetype)controllerForDeviceHandler:(OEDeviceHandler *)deviceHandler {
	
	return [[self alloc] initWithDeviceHandler:deviceHandler];
}

- (instancetype)initWithDeviceHandler:(OEDeviceHandler *)deviceHandler {
	
	if (self = [super init]) {
		
		_deviceHandler = deviceHandler;
		_mapConfiguration = MapConfiguration.defaultConfiguration;
	}
	return self;
}

/* f(g(OEHIDEvent) -> Action) -> Event */
- (BOOL)handleEvent:(OEHIDEvent *)event {
	
	Action *action = [_mapConfiguration actionForEvent:event modifierFlags:_modifierFlags];
	
	if (event.type == OEHIDEventTypeAxis) {
		
		if (event.axis == OEHIDEventAxisX) {
			_leftJoystick.dx = event.value;
		}
		else if (event.axis == OEHIDEventAxisY) {
			_leftJoystick.dy = event.value;
		}
		else if (event.axis == OEHIDEventAxisZ) {
			_rightJoystick.dx = event.value;
		}
		else if (event.axis == OEHIDEventAxisRz) {
			_rightJoystick.dy = event.value;
		}
	}
	else if (event.type == OEHIDEventTypeTrigger) {

		if (event.axis == OEHIDEventAxisRx) {
			_leftTrigger = event.value;
		}
		else if (event.axis == OEHIDEventAxisRy) {
			_rightTrigger = event.value;
		}
	}
	else if (event.type == OEHIDEventTypeButton) {

		[action postEvent:@(event.state)];
	}
	else if (event.type == OEHIDEventTypeHatSwitch) {

		uint8_t previous = _hatDirection & 0xF;
		uint8_t current = _hatDirection = event.hatDirection & 0xF;
		
		uint8_t down = ~(~current | previous) & 0xF;
		uint8_t up = ~(~previous | current) & 0xF;
		
		uint8_t input = down << 4 | up;
		[action postEvent:@(input)];
	}
	
	/* Timer for mouse move and scroll update */
	if (CGVectorLength(_leftJoystick) > 0 || CGVectorLength(_rightJoystick) > 0) {
		
		if (!_timer) {
			
			_timer = [NSTimer timerWithTimeInterval:1.0 / 42
											 target:self
										   selector:@selector(update:)
										   userInfo:nil
											repeats:YES];
			[NSRunLoop.currentRunLoop addTimer:_timer forMode:NSDefaultRunLoopMode];
		}
	}
	else {
		
		[_timer invalidate], _timer = nil;
	}
	
	return YES;
}

///* Modifiers */
//if (event.axis == OEHIDEventAxisRx) {
//	
//	if (event.value > kModifierThreshold) {
//		_modifiers |= ModifiersL;
//	} else {
//		_modifiers &= ~ModifiersL;
//	}
//}
//else if (event.axis == OEHIDEventAxisRy) {
//	
//	if (event.value > kModifierThreshold) {
//		_modifiers |= ModifiersR;
//	} else {
//		_modifiers &= ~ModifiersR;
//	}
//}

- (void)update:(NSTimer *)timer {
	
	if (CGVectorLength(_leftJoystick) > 0) {
		NSValue *value = [NSValue valueWithVector:_leftJoystick];
		Action *action = [_mapConfiguration actionForControl:DSStickLeft modifierFlags:_modifierFlags];
		[action postEvent:value];
	}
	if (CGVectorLength(_rightJoystick) > 0) {
		NSValue *value = [NSValue valueWithVector:_rightJoystick];
		Action *action = [_mapConfiguration actionForControl:DSStickRight modifierFlags:_modifierFlags];
		[action postEvent:value];
	}
}

@end

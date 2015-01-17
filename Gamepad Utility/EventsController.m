//
//  EventsController.m
//  Gamepad Utility
//
//  Created by Konstantin Sukharev on 17/01/15.
//  Copyright (c) 2015 P0ed. All rights reserved.
//

#import "EventsController.h"
#import "ConfigurationController.h"
#import "MapConfiguration.h"
#import "Action.h"
#import "Event.h"


@import Carbon.HIToolbox.Events;


const CGFloat kJoystickThreshold = 0.1;
const CGFloat kModifierThreshold = 0.4;
const CGFloat kMouseShiftMultiplier = 16;
const CGFloat kScrollShiftMultiplier = -20;


typedef NS_OPTIONS(NSInteger, Modifiers) {
	
	ModifiersNone = 0x0,
	ModifiersL = 0x1 << 14,
	ModifiersR = 0x1 << 15,
	ModifiersLR = ModifiersL | ModifiersR
};


@interface EventsController	()
@property (nonatomic) OEDeviceHandler *deviceHandler;
@property (nonatomic) ConfigurationController *configurationController;
@property (nonatomic) Modifiers modifiers;
@end


@implementation EventsController {
	
	NSTimer *_timer;
	
//	CGVector _leftJoystick;
//	CGVector _rightJoystick;
//	OEHIDEventHatDirection _hatDirection;
	
	NSMutableDictionary *_events;
}

+ (instancetype)controllerForDeviceHandler:(OEDeviceHandler *)deviceHandler {
	
	return [[self alloc] initWithDeviceHandler:deviceHandler];
}

- (instancetype)initWithDeviceHandler:(OEDeviceHandler *)deviceHandler {
	
	if (self = [super init]) {
		
		_deviceHandler = deviceHandler;
		_configurationController = ConfigurationController.new;
		_configurationController.nextResponder = self;
	}
	return self;
}

/* f(g(OEHIDEvent) -> Action) -> Event */
- (BOOL)handleEvent:(OEHIDEvent *)event {
	
	MapConfiguration *configuration = _configurationController.configuration;
	Action *action = [configuration actionForEvent:event];
	[action postEvent];
	
//	if (event.type == OEHIDEventTypeAxis) {
//		/* Mouse move and scroll */
//		if (event.axis == OEHIDEventAxisX) {
//			_leftJoystick.dx = event.value;
//		}
//		else if (event.axis == OEHIDEventAxisY) {
//			_leftJoystick.dy = event.value;
//		}
//		else if (event.axis == OEHIDEventAxisZ) {
//			_rightJoystick.dx = event.value;
//		}
//		else if (event.axis == OEHIDEventAxisRz) {
//			_rightJoystick.dy = event.value;
//		}
//	}
//	else if (event.type == OEHIDEventTypeTrigger) {
//		/* Modifiers */
//		if (event.axis == OEHIDEventAxisRx) {
//			
//			if (event.value > kModifierThreshold) {
//				_modifiers |= ModifiersL;
//			} else {
//				_modifiers &= ~ModifiersL;
//			}
//		}
//		else if (event.axis == OEHIDEventAxisRy) {
//			
//			if (event.value > kModifierThreshold) {
//				_modifiers |= ModifiersR;
//			} else {
//				_modifiers &= ~ModifiersR;
//			}
//		}
//	}
//	else if (event.type == OEHIDEventTypeButton) {
//		/* Buttons */
//		NSNumber *key = @(event.buttonNumber | _modifiers);
//		if (event.state) {
//			
//			MapConfiguration *configuration = [_configurationController configurationForDevice:deviceHandler];
//			Action *action = [configuration actionForButton:key.intValue];
//			
//			if (action) _events[key] = [action postEvent];
//			
//		} else {
//			[_events[key] dispose], [_events removeObjectForKey:key];
//		}
//	}
//	else if (event.type == OEHIDEventTypeHatSwitch) {
//		/* Arrows */
//		
//		if (_hatDirection & OEHIDEventHatDirectionNorth && !(event.hatDirection & OEHIDEventHatDirectionNorth)) {
//			[self postKeyboardEvent:kVK_UpArrow state:OEHIDEventStateOff];
//		}
//		if (_hatDirection & OEHIDEventHatDirectionSouth && !(event.hatDirection & OEHIDEventHatDirectionSouth)) {
//			[self postKeyboardEvent:kVK_DownArrow state:OEHIDEventStateOff];
//		}
//		if (_hatDirection & OEHIDEventHatDirectionWest && !(event.hatDirection & OEHIDEventHatDirectionWest)) {
//			[self postKeyboardEvent:kVK_LeftArrow state:OEHIDEventStateOff];
//		}
//		if (_hatDirection & OEHIDEventHatDirectionEast && !(event.hatDirection & OEHIDEventHatDirectionEast)) {
//			[self postKeyboardEvent:kVK_RightArrow state:OEHIDEventStateOff];
//		}
//		
//		_hatDirection = event.hatDirection;
//		
//		if (event.hatDirection & OEHIDEventHatDirectionNorth) {
//			[self postKeyboardEvent:kVK_UpArrow state:OEHIDEventStateOn];
//		}
//		if (event.hatDirection & OEHIDEventHatDirectionSouth) {
//			[self postKeyboardEvent:kVK_DownArrow state:OEHIDEventStateOn];
//		}
//		if (event.hatDirection & OEHIDEventHatDirectionWest) {
//			[self postKeyboardEvent:kVK_LeftArrow state:OEHIDEventStateOn];
//		}
//		if (event.hatDirection & OEHIDEventHatDirectionEast) {
//			[self postKeyboardEvent:kVK_RightArrow state:OEHIDEventStateOn];
//		}
//	}
//	
//	/* Timer for mouse move and scroll update */
//	if (CGVectorLength(_leftJoystick) > kJoystickThreshold || CGVectorLength(_rightJoystick) > kJoystickThreshold) {
//		
//		if (!_timer) {
//			
//			_timer = [NSTimer timerWithTimeInterval:1.0 / 42
//											 target:self
//										   selector:@selector(update:)
//										   userInfo:nil
//											repeats:YES];
//			[NSRunLoop.currentRunLoop addTimer:_timer forMode:NSDefaultRunLoopMode];
//		}
//	}
//	else {
//		
//		[_timer invalidate], _timer = nil;
//	}
	
	return YES;
}

//- (void)update:(NSTimer *)timer {
//	
//	if (CGVectorLength(_rightJoystick) > kJoystickThreshold) {
//		
//		if (_modifiers & ModifiersR) {
//			[self scrollContent:_rightJoystick];
//		} else {
//			[self moveMouse:_rightJoystick];
//		}
//	}
//}
//
//- (void)postKeyboardEvent:(CGKeyCode)code state:(OEHIDEventState)state {
//	
//	CGEventRef event = CGEventCreateKeyboardEvent(NULL, code, state);
//	CGEventPost(kCGHIDEventTap, event);
//	CFRelease(event);
//}
//
//- (void)moveMouse:(CGVector)vector {
//	
//	NSSize screenSize = NSScreen.mainScreen.frame.size;
//	CGPoint currentLocation = NSEvent.mouseLocation;
//	CGPoint mousePoint = CGPointMake(currentLocation.x, screenSize.height - currentLocation.y);
//	
//	CGPoint newLocation = CGPointMake(fmin(screenSize.width - 1, fmax(0, mousePoint.x + vector.dx * kMouseShiftMultiplier)),
//									  fmin(screenSize.height - 1, fmax(0, mousePoint.y + vector.dy * kMouseShiftMultiplier)));
//	
//	CGEventRef event = CGEventCreateMouseEvent(NULL,
//											   /*_clicked ? kCGEventLeftMouseDragged : */kCGEventMouseMoved,
//											   newLocation,
//											   kCGMouseButtonLeft);
//	CGEventPost(kCGHIDEventTap, event);
//	CFRelease(event);
//}
//
//- (void)scrollContent:(CGVector)vector {
//	
//	CGEventRef event = CGEventCreateScrollWheelEvent(NULL,
//													 kCGScrollEventUnitPixel,
//													 2,
//													 (int32_t)ceil(vector.dy * kScrollShiftMultiplier),
//													 (int32_t)ceil(vector.dx * kScrollShiftMultiplier));
//	CGEventPost(kCGHIDEventTap, event);
//	CFRelease(event);
//}
//
//- (void)mouseClick:(OEHIDEventState)state {
//	
//	CGPoint currentLocation = NSEvent.mouseLocation;
//	CGPoint mousePoint = CGPointMake(currentLocation.x, NSScreen.mainScreen.frame.size.height - currentLocation.y);
//	
//	CGEventRef event = CGEventCreateMouseEvent(NULL,
//											   state ? kCGEventLeftMouseDown : kCGEventLeftMouseUp,
//											   mousePoint,
//											   kCGMouseButtonLeft);
//	CGEventPost(kCGHIDEventTap, event);
//	CFRelease(event);
//}

@end

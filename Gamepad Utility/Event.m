//
//  Event.m
//  Gamepad Utility
//
//  Created by Konstantin Sukharev on 16/01/15.
//  Copyright (c) 2015 P0ed. All rights reserved.
//

#import "Event.h"
@import AppKit;


const CGFloat kMouseShiftMultiplier = 16;
const CGFloat kScrollShiftMultiplier = -20;


@implementation Event

+ (void)postKeyboardEvent:(CGKeyCode)keyCode keyDown:(BOOL)keyDown {
	
	CGEventRef event = CGEventCreateKeyboardEvent(NULL, keyCode, keyDown);
	CGEventPost(kCGHIDEventTap, event);
	CFRelease(event);
}

+ (void)postMouseClickEvent:(CGMouseButton)mouseButton buttonDown:(BOOL)buttonDown {
	
	CGEventType mouseType;
	
	if (mouseButton == 0) {
		mouseType = buttonDown ? kCGEventLeftMouseDown : kCGEventLeftMouseUp;
	}
	else if (mouseButton == 1) {
		mouseType = buttonDown ? kCGEventRightMouseDown : kCGEventRightMouseUp;
	}
	else {
		mouseType = buttonDown ? kCGEventOtherMouseDown : kCGEventOtherMouseUp;
	}
	
	CGEventRef event = CGEventCreate(NULL);
	CGPoint currentLocation = CGEventGetLocation(event);
	CFRelease(event);
	
	event = CGEventCreateMouseEvent(NULL, mouseType, currentLocation, mouseButton);
	CGEventPost(kCGHIDEventTap, event);
	CFRelease(event);
}

+ (void)postMouseMoveEvent:(CGVector)vector {
	
	int pressedButtons = (int)NSEvent.pressedMouseButtons;
	
	CGEventType mouseType;
	CGMouseButton mouseButton = ffs(pressedButtons);
	
	if (pressedButtons == 0) {
		mouseType = kCGEventMouseMoved;
	}
	else {
		if (pressedButtons & 1 << kCGMouseButtonLeft) {
			mouseType = kCGEventLeftMouseDragged;
		}
		else if (pressedButtons & 1 << kCGMouseButtonLeft) {
			mouseType = kCGEventRightMouseDragged;
		}
		else {
			mouseType = kCGEventOtherMouseDragged;
		}
	}
	
	NSSize screenSize = NSScreen.mainScreen.frame.size;
	CGEventRef event = CGEventCreate(NULL);
	CGPoint currentLocation = CGEventGetLocation(event);
	CFRelease(event);
	
	CGPoint newLocation = CGPointMake(fmin(screenSize.width - 1, fmax(0, currentLocation.x + vector.dx * kMouseShiftMultiplier)),
									  fmin(screenSize.height - 1, fmax(0, currentLocation.y + vector.dy * kMouseShiftMultiplier)));
	
	event = CGEventCreateMouseEvent(NULL, mouseType, newLocation, mouseButton);
	CGEventPost(kCGHIDEventTap, event);
	CFRelease(event);
}

+ (void)postScrollEvent:(CGVector)vector {
	
	CGEventRef event = CGEventCreateScrollWheelEvent(NULL,
													 kCGScrollEventUnitPixel,
													 2,
													 (int32_t)ceil(vector.dy * kScrollShiftMultiplier),
													 (int32_t)ceil(vector.dx * kScrollShiftMultiplier));
	CGEventPost(kCGHIDEventTap, event);
	CFRelease(event);
}

@end

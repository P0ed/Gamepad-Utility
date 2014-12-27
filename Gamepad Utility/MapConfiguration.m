//
//  MapConfiguration.m
//  Gamepad Utility
//
//  Created by Konstantin Sukharev on 26/12/14.
//  Copyright (c) 2014 P0ed. All rights reserved.
//

#import "MapConfiguration.h"
#import "OpenEmuSystem/OEHIDEvent.h"
#import "Vectors.h"

@import Carbon.HIToolbox.Events;


const CGFloat kThreshold = 0.1;
const CGFloat kMouseShiftMultiplier = 16;
const CGFloat kScrollShiftMultiplier = -20;


@implementation MapConfiguration {
	
	NSTimer *_timer;
	
	CGVector _mouseShift;
	CGVector _scrollShift;
	BOOL _clicked;
}

- (BOOL)handleEvent:(OEHIDEvent *)event {
	
	BOOL handled = YES;
	
	if (event.type == OEHIDEventTypeAxis) {
		/* Mouse move and scroll */
		if (event.axis == OEHIDEventAxisX) {
			_mouseShift.dx = event.value;
		}
		else if (event.axis == OEHIDEventAxisY) {
			_mouseShift.dy = event.value;
		}
		else if (event.axis == OEHIDEventAxisRz) {
			_scrollShift.dx = event.value;
		}
		else if (event.axis == OEHIDEventAxisZ) {
			_scrollShift.dy = event.value;
		}
		else {
			handled = NO;
		}
	}
	else if (event.type == OEHIDEventTypeButton) {
		
		if (event.buttonNumber == 2) {
			/* Mouse left click */
			_clicked = event.state;
			[self mouseClick:_clicked];
		}
		else if (event.buttonNumber == 1) {
			/* Enter */
			[self postKeyboardEvent:kVK_Return state:event.state];
		}
		else if (event.buttonNumber == 3) {
			/* Delete */
			[self postKeyboardEvent:kVK_Delete state:event.state];
		}
		else if (event.buttonNumber == 4) {
			/* Tab */
			[self postKeyboardEvent:kVK_Tab state:event.state];
		}
		else if (event.buttonNumber == 5) {
			/* Shift */
			[self postKeyboardEvent:kVK_Shift state:event.state];
		}
		else if (event.buttonNumber == 6) {
			/* Command */
			[self postKeyboardEvent:kVK_Command state:event.state];
		}
		else {
			handled = NO;
		}
	}
	else if (event.type == OEHIDEventTypeHatSwitch) {
		/* Arrows */
		if (event.hatDirection & OEHIDEventHatDirectionNorth) {
			[self postKeyboardEvent:kVK_UpArrow state:OEHIDEventStateOn];
			[self postKeyboardEvent:kVK_UpArrow state:OEHIDEventStateOff];
		}
		if (event.hatDirection & OEHIDEventHatDirectionSouth) {
			[self postKeyboardEvent:kVK_DownArrow state:OEHIDEventStateOn];
			[self postKeyboardEvent:kVK_DownArrow state:OEHIDEventStateOff];
		}
		if (event.hatDirection & OEHIDEventHatDirectionWest) {
			[self postKeyboardEvent:kVK_LeftArrow state:OEHIDEventStateOn];
			[self postKeyboardEvent:kVK_LeftArrow state:OEHIDEventStateOff];
		}
		if (event.hatDirection & OEHIDEventHatDirectionEast) {
			[self postKeyboardEvent:kVK_RightArrow state:OEHIDEventStateOn];
			[self postKeyboardEvent:kVK_RightArrow state:OEHIDEventStateOff];
		}
	}
	
	/* Timer for mouse move and scroll update */
	if (CGVectorLength(_mouseShift) > kThreshold || CGVectorLength(_scrollShift) > kThreshold) {
		
		if (!_timer) _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 / 42
															   target:self
															 selector:@selector(update:)
															 userInfo:nil
															  repeats:YES];
	}
	else {
		
		[_timer invalidate], _timer = nil;
	}
	
	return handled;
}

- (void)update:(NSTimer *)timer {
	
	if (CGVectorLength(_mouseShift) > kThreshold) {
		[self moveMouse:_mouseShift];
	}
	else if (CGVectorLength(_scrollShift) > kThreshold) {
		[self scrollContent:_scrollShift];
	}
}

- (void)postKeyboardEvent:(CGKeyCode)code state:(OEHIDEventState)state {
	
	CGEventRef event = CGEventCreateKeyboardEvent(NULL, code, state);
	CGEventPost(kCGHIDEventTap, event);
	CFRelease(event);
}

- (void)moveMouse:(CGVector)vector {
	
	NSSize screenSize = NSScreen.mainScreen.frame.size;
	CGPoint currentLocation = NSEvent.mouseLocation;
	CGPoint mousePoint = CGPointMake(currentLocation.x, screenSize.height - currentLocation.y);
	
	CGPoint newLocation = CGPointMake(fmin(screenSize.width - 1, fmax(0, mousePoint.x + vector.dx * kMouseShiftMultiplier)),
									  fmin(screenSize.height - 1, fmax(0, mousePoint.y + vector.dy * kMouseShiftMultiplier)));
	
	CGEventRef event = CGEventCreateMouseEvent(NULL,
													_clicked ? kCGEventLeftMouseDragged : kCGEventMouseMoved,
													newLocation,
													kCGMouseButtonLeft);
	CGEventPost(kCGHIDEventTap, event);
	CFRelease(event);
}

- (void)scrollContent:(CGVector)vector {
	
	CGEventRef event = CGEventCreateScrollWheelEvent(NULL,
													 kCGScrollEventUnitPixel,
													 2,
													 (int32_t)ceil(vector.dx * kScrollShiftMultiplier),
													 (int32_t)ceil(vector.dy * kScrollShiftMultiplier));
	CGEventPost(kCGHIDEventTap, event);
	CFRelease(event);
}

- (void)mouseClick:(OEHIDEventState)state {
	
	CGPoint currentLocation = NSEvent.mouseLocation;
	CGPoint mousePoint = CGPointMake(currentLocation.x, NSScreen.mainScreen.frame.size.height - currentLocation.y);
	
	CGEventRef event = CGEventCreateMouseEvent(NULL,
							state ? kCGEventLeftMouseDown : kCGEventLeftMouseUp,
							mousePoint,
							kCGMouseButtonLeft);
	CGEventPost(kCGHIDEventTap, event);
	CFRelease(event);
}

@end

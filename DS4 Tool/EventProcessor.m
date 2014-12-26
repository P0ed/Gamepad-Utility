//
//  EventProcessor.m
//  DS4 Tool
//
//  Created by Konstantin Sukharev on 26/12/14.
//  Copyright (c) 2014 P0ed. All rights reserved.
//

#import "EventProcessor.h"
#import "OpenEmuSystem/OEHIDEvent.h"
#import "Vectors.h"


const CGFloat kThreshold = 0.1;
const CGFloat kMouseShiftMultiplier = 16;
const CGFloat kScrollShiftMultiplier = -20;


@implementation EventProcessor {
	NSTimer *_timer;
	
	CGVector _mouseShift;
	CGVector _scrollShift;
	BOOL _clicked;
}

- (void)processEvent:(OEHIDEvent *)event {
	
	if (event.type == OEHIDEventTypeAxis) {
		
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
	}
	else if (event.type == OEHIDEventTypeButton) {
		
		if (event.buttonNumber == 2) {
			_clicked = event.state;
			[self mouseClick:_clicked];
		}
	}
	
	if (CGVectorLength(_mouseShift) > kThreshold || CGVectorLength(_scrollShift) > kThreshold) {
		
		if (!_timer) _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 / 42
															   target:self
															 selector:@selector(update:)
															 userInfo:nil
															  repeats:YES];
	} else {
		[_timer invalidate], _timer = nil;
	}
}

- (void)update:(NSTimer *)timer {
	if (CGVectorLength(_mouseShift) > kThreshold) {
		[self moveMouse:_mouseShift];
	}
	else if (CGVectorLength(_scrollShift) > kThreshold) {
		[self scrollContent:_scrollShift];
	}
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

- (void)mouseClick:(BOOL)down {
	
	CGPoint currentLocation = NSEvent.mouseLocation;
	CGPoint mousePoint = CGPointMake(currentLocation.x, NSScreen.mainScreen.frame.size.height - currentLocation.y);
	
	CGEventRef event = CGEventCreateMouseEvent(NULL,
							down ? kCGEventLeftMouseDown : kCGEventLeftMouseUp,
							mousePoint,
							kCGMouseButtonLeft);
	CGEventPost(kCGHIDEventTap, event);
	CFRelease(event);
}

@end

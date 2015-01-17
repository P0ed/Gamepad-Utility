//
//  Action.m
//  Gamepad Utility
//
//  Created by Konstantin Sukharev on 16/01/15.
//  Copyright (c) 2015 P0ed. All rights reserved.
//

#import "Action.h"
#import "Event.h"


@interface KeyAction : Action
@property (nonatomic) CGKeyCode keyCode;
@end


@interface MouseClickAction : Action
@property (nonatomic) CGMouseButton mouseButton;
@end


@implementation Action
- (Event *)postEvent { return nil; }
@end


@implementation NSNumber (Action)

- (Action *)keyAction {
	KeyAction *action = KeyAction.new;
	action.keyCode = self.intValue;
	return action;
}

- (Action *)mouseClickAction {
	MouseClickAction *action = MouseClickAction.new;
	action.mouseButton = self.intValue;
	return action;
}

@end


@implementation KeyAction

- (Event *)postEvent {
	
	CGEventRef CGEvent = CGEventCreateKeyboardEvent(NULL, self.keyCode, true);
	Event *event = [Event eventWithCGEvent:CGEvent disposeBlock:^(CGEventRef CGEvent) {
		CGEventSetType(CGEvent, kCGEventKeyUp);
	}];
	CFRelease(CGEvent);
	
	return event;
}

@end


@import Cocoa;
@implementation MouseClickAction

- (Event *)postEvent {
	
//	NSDictionary *downEventTypeMap = @{
//									   @(kCGMouseButtonLeft): @(kCGEventLeftMouseDown),
//									   };
//	NSDictionary *upEventTypeMap = @{
//									 @(kCGMouseButtonLeft): @(kCGEventLeftMouseDown),
//									 };
	
	CGPoint currentLocation = NSEvent.mouseLocation;
	CGPoint mousePoint = CGPointMake(currentLocation.x, NSScreen.mainScreen.frame.size.height - currentLocation.y);
	
	CGEventRef CGEvent = CGEventCreateMouseEvent(NULL, kCGEventLeftMouseDown, mousePoint, self.mouseButton);
	Event *event = [Event eventWithCGEvent:CGEvent disposeBlock:^(CGEventRef CGEvent) {
//		CGEventSetType(CGEvent, upEventTypeMap[]);
	}];
	CFRelease(CGEvent);
	
	return event;
}

@end

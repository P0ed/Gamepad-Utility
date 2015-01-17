//
//  Event.m
//  Gamepad Utility
//
//  Created by Konstantin Sukharev on 16/01/15.
//  Copyright (c) 2015 P0ed. All rights reserved.
//

#import "Event.h"


@interface Event ()
@property (nonatomic) CGEventRef CGEvent;
@property (nonatomic, copy) void (^disposeBlock)(CGEventRef CGEvent);
@end


@implementation Event

+ (instancetype)eventWithCGEvent:(CGEventRef)CGEvent disposeBlock:(void (^)(CGEventRef))disposeBlock {
	
	Event *event = self.new;
	event.CGEvent = CGEvent;
	event.disposeBlock = disposeBlock;
	
	if (CGEvent) CGEventPost(kCGHIDEventTap, CGEvent);
	
	return event;
}

- (void)dispose {

	if (self.disposeBlock) self.disposeBlock(_CGEvent);
	if (self.CGEvent) CGEventPost(kCGHIDEventTap, _CGEvent);
}

- (void)setCGEvent:(CGEventRef)CGEvent {
	
	if (_CGEvent != CGEvent) {
		
		if (_CGEvent) CFRelease(_CGEvent);
		_CGEvent = CGEvent;
		if (_CGEvent) CFRetain(_CGEvent);
	}
}

- (void)dealloc {
	
	if (_CGEvent) CFRelease(_CGEvent);
}

@end

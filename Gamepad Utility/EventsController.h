//
//  EventsController.h
//  Gamepad Utility
//
//  Created by Konstantin Sukharev on 17/01/15.
//  Copyright (c) 2015 P0ed. All rights reserved.
//


@import Cocoa;
@class OEHIDEvent, OEDeviceHandler;


@interface EventsController : NSResponder

+ (instancetype)controllerForDeviceHandler:(OEDeviceHandler *)deviceHandler;
- (BOOL)handleEvent:(OEHIDEvent *)event;

@end

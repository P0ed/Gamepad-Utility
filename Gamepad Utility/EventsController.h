//
//  EventsController.h
//  Gamepad Utility
//
//  Created by Konstantin Sukharev on 17/01/15.
//  Copyright (c) 2015 P0ed. All rights reserved.
//


@import Foundation;
@class MapConfiguration, OEHIDEvent, OEDeviceHandler;


@interface EventsController : NSObject

@property (nonatomic) MapConfiguration *mapConfiguration;

+ (instancetype)controllerForDeviceHandler:(OEDeviceHandler *)deviceHandler;
- (BOOL)handleEvent:(OEHIDEvent *)inputEvent;

@end

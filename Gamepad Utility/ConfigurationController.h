//
//  ConfigurationController.h
//  Gamepad Utility
//
//  Created by Konstantin Sukharev on 17/01/15.
//  Copyright (c) 2015 P0ed. All rights reserved.
//


@import Cocoa;
@class MapConfiguration;


@interface ConfigurationController : NSResponder

@property (nonatomic, readonly) MapConfiguration *configuration;

@end

//
//  ConfigurationController.m
//  Gamepad Utility
//
//  Created by Konstantin Sukharev on 17/01/15.
//  Copyright (c) 2015 P0ed. All rights reserved.
//

#import "ConfigurationController.h"
#import "MapConfiguration.h"


@implementation ConfigurationController

- (instancetype)init {
	
	if (self = [super init]) {
		
		_configuration = MapConfiguration.defaultConfiguration;
		_configuration.nextResponder = self;
	}
	return self;
}

@end

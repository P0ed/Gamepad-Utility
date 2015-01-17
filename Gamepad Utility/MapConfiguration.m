//
//  MapConfiguration.m
//  Gamepad Utility
//
//  Created by Konstantin Sukharev on 26/12/14.
//  Copyright (c) 2014 P0ed. All rights reserved.
//


#import "MapConfiguration.h"
#import "Action.h"
#import "Vectors.h"
#import "OpenEmuSystem/OEHIDEvent.h"

@import Carbon.HIToolbox.Events;


@interface MapConfiguration ()
@property (nonatomic, readwrite) NSString *name;
@property (nonatomic) NSDictionary *actionsMapTable;
@end


@implementation MapConfiguration

- (instancetype)init {
	
	if (self = [super init]) {
		
		_actionsMapTable = @{};
	}
	return self;
}

+ (instancetype)defaultConfiguration {
	
	MapConfiguration *configuration = self.new;
	configuration.name = @"Default";
	configuration.actionsMapTable = @{
									  @(DSButtonSquare):	@(kVK_ANSI_1).keyAction,
									  @(DSButtonTriangle):	@(kVK_ANSI_2).keyAction,
									  @(DSButtonCross):		@(kCGMouseButtonLeft).mouseClickAction,
									  @(DSButtonCircle):	@(kCGMouseButtonRight).mouseClickAction,
									  @(DSButtonL):			@(kVK_ANSI_5).keyAction,
									  @(DSButtonR):			@(kVK_ANSI_6).keyAction,
									  @(DSButtonShare):		@(kVK_Escape).keyAction,
									  @(DSButtonOptions):	@(kVK_Return).keyAction,
									  };
	return configuration;
}

+ (instancetype)configurationWithName:(NSString *)name {
	
	MapConfiguration *configuration = self.new;
	configuration.name = name;

	return configuration;
}

+ (NSArray *)configurationList {
	
	return @[@"Default", @"MK9"];
}

- (Action *)actionForEvent:(OEHIDEvent *)event {
	
	
	
	return nil;
}

@end

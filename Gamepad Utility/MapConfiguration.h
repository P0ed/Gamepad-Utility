//
//  MapConfiguration.h
//  Gamepad Utility
//
//  Created by Konstantin Sukharev on 26/12/14.
//  Copyright (c) 2014 P0ed. All rights reserved.
//

@import Cocoa;
@class Action, OEHIDEvent;


typedef NS_ENUM(NSInteger, DSControl) {
	
	DSButtonUnknown = 0,

	DSButtonSquare = 1,
	DSButtonCross = 2,
	DSButtonCircle = 3,
	DSButtonTriangle = 4,

	DSButtonL = 5,
	DSButtonR = 6,

	DSButtonShare = 9,
	DSButtonOptions = 10,
	
	DSButtonUp = 65,
	DSButtonRight = 66,
	DSButtonDown = 67,
	DSButtonLeft = 68,
	
	DSStickLeft = 69,
	DSStickRight = 70,
	
	DSTriggerLeft = 71,
	DSTriggerRight = 72
};


@interface MapConfiguration : NSResponder /*<NSCoding>*/

@property (nonatomic, readonly) NSString *name;

+ (instancetype)defaultConfiguration;
+ (instancetype)configurationWithName:(NSString *)name;
+ (NSArray *)configurationList;

- (Action *)actionForEvent:(OEHIDEvent *)event;

@end

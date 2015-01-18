//
//  MapConfiguration.m
//  Gamepad Utility
//
//  Created by Konstantin Sukharev on 26/12/14.
//  Copyright (c) 2014 P0ed. All rights reserved.
//


#import "MapConfiguration.h"
#import "Action.h"
#import "OpenEmuSystem/OEHIDEvent.h"

@import Carbon.HIToolbox.Events;


@interface MapConfiguration ()
@property (nonatomic, readwrite) NSString *name;
@property (nonatomic) NSDictionary *actionsMapTable;
@end


@implementation MapConfiguration

+ (instancetype)defaultConfiguration {
	
	MapConfiguration *configuration = self.new;
	configuration.name = @"Default";
	configuration.actionsMapTable = @{
									  @(DSButtonSquare):					@(kVK_ANSI_1).buttonKeyAction,
									  @(DSButtonTriangle):					@(kVK_ANSI_2).buttonKeyAction,
									  @(DSButtonCross):						@(kCGMouseButtonLeft).buttonMouseClickAction,
									  @(DSButtonCircle):					@(kCGMouseButtonRight).buttonMouseClickAction,
									  @(DSButtonL):							@(kVK_ANSI_5).buttonKeyAction,
									  @(DSButtonR):							@(kVK_ANSI_6).buttonKeyAction,
									  @(DSButtonShare):						@(kVK_Escape).buttonKeyAction,
									  @(DSButtonOptions):					@(kVK_Return).buttonKeyAction,
									  @(DSDPad):							Action.dPadArrowsAction,
									  @(DSStickRight):						Action.stickMouseMoveAction,
									  @(DSStickRight | DSModifierRMask):	Action.stickScrollAction,
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

- (Action *)actionForEvent:(OEHIDEvent *)event modifierFlags:(DSModifierFlags)modifierFlags {
	
	DSControl control = 0;
	
	if (event.type == OEHIDEventTypeAxis) {
		
		if (event.axis == OEHIDEventAxisX || event.axis == OEHIDEventAxisY) {
			control = DSStickLeft;
		}
		else if (event.axis == OEHIDEventAxisZ || event.axis == OEHIDEventAxisRz) {
			control = DSStickRight;
		}
	}
	else if (event.type == OEHIDEventTypeTrigger) {
	
		if (event.axis == OEHIDEventAxisRx) {
			control = DSTriggerLeft;
		}
		else if (event.axis == OEHIDEventAxisRy) {
			control = DSTriggerRight;
		}
	}
	else if (event.type == OEHIDEventTypeButton) {
		control = event.buttonNumber;
	}
	else if (event.type == OEHIDEventTypeHatSwitch) {
		control = DSDPad;
	}
	
	return _actionsMapTable[@(control | modifierFlags)];
}

- (Action *)actionForControl:(DSControl)control modifierFlags:(DSModifierFlags)modifierFlags {
	return _actionsMapTable[@(control | modifierFlags)];
}

@end

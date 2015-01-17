//
//  main.m
//  Gamepad Utility
//
//  Created by Konstantin Sukharev on 25/12/14.
//  Copyright (c) 2014 P0ed. All rights reserved.
//

#import <Cocoa/Cocoa.h>

int main(int argc, const char * argv[]) {
	
	ProcessSerialNumber psn = { 0, kCurrentProcess };
	TransformProcessType(&psn, kProcessTransformToUIElementApplication);
	
	return NSApplicationMain(argc, argv);
}

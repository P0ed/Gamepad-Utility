//
//  AppDelegate.m
//  Gamepad Utility
//
//  Created by Konstantin Sukharev on 25/12/14.
//  Copyright (c) 2014 P0ed. All rights reserved.
//

#import "AppDelegate.h"
#import "OpenEmuSystem/OEDeviceManager.h"
#import "MapConfiguration.h"


@implementation AppDelegate {
	NSStatusItem *_statusItem;
	id _monitor;
	MapConfiguration *_mapConfiguration;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	
	[self preventMultipleInstances];
	
	_statusItem = [NSStatusBar.systemStatusBar statusItemWithLength:NSVariableStatusItemLength];
	_statusItem.button.image = [NSImage imageNamed:@"MenuIcon"];
	[_statusItem.button.image setTemplate:YES];
	
	_statusItem.menu = NSMenu.new;
	[_statusItem.menu addItemWithTitle:@"Quit" action:@selector(terminate:) keyEquivalent:@"q"];
	
	_mapConfiguration = MapConfiguration.new;
	
	_monitor = [OEDeviceManager.sharedDeviceManager addGlobalEventMonitorHandler:^BOOL(OEDeviceHandler *handler, OEHIDEvent *event) {
		return ![_mapConfiguration handleEvent:event];
	}];
}

- (void)preventMultipleInstances {
	
	NSArray *runningApplications = [NSRunningApplication runningApplicationsWithBundleIdentifier:NSBundle.mainBundle.bundleIdentifier];
	if (runningApplications.count > 1) {
		[NSApp terminate:nil];
	}
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag {
	return NO;
}

@end

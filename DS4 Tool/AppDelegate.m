//
//  AppDelegate.m
//  DS4 Tool
//
//  Created by Konstantin Sukharev on 25/12/14.
//  Copyright (c) 2014 P0ed. All rights reserved.
//

#import "AppDelegate.h"
#import "OpenEmuSystem/OEDeviceManager.h"
#import "EventProcessor.h"


@implementation AppDelegate {
	NSStatusItem *_statusItem;
	id _monitor;
	EventProcessor *_eventProcessor;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	_statusItem = [NSStatusBar.systemStatusBar statusItemWithLength:NSStatusBar.systemStatusBar.thickness];
	_statusItem.title = @"🎮";
	_statusItem.menu = NSMenu.new;
	[_statusItem.menu addItemWithTitle:@"Quit" action:@selector(terminate:) keyEquivalent:@"q"];
	
	_eventProcessor = EventProcessor.new;
	
	_monitor = [OEDeviceManager.sharedDeviceManager addGlobalEventMonitorHandler:^BOOL(OEDeviceHandler *handler, OEHIDEvent *event) {
		[_eventProcessor processEvent:event];
		return NO;
	}];
}

- (void)terminate:(id)sender {
	exit(0);
}

- (void)applicationWillTerminate:(NSNotification *)notification {}

@end

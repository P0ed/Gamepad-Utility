//
//  AppDelegate.m
//  Gamepad Utility
//
//  Created by Konstantin Sukharev on 25/12/14.
//  Copyright (c) 2014 P0ed. All rights reserved.
//

#import "AppDelegate.h"
#import "OpenEmuSystem/OEDeviceManager.h"
#import "OpenEmuSystem/OEDeviceHandler.h"
#import "OpenEmuSystem/OEControllerDescription.h"
#import "EventsController.h"
#import "MapConfiguration.h"


@implementation AppDelegate {
	NSStatusItem *_statusItem;
	NSMutableDictionary *_eventMonitors;
	NSMutableDictionary *_observers;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	
	[self preventMultipleInstances];
	
	_statusItem = self.createStatusItem;
	
	_eventMonitors = @{}.mutableCopy;
	_observers = @{}.mutableCopy;
	
	[OEDeviceManager sharedDeviceManager];
	
	_observers[OEDeviceManagerDidAddDeviceHandlerNotification] =
	[NSNotificationCenter.defaultCenter addObserverForName:OEDeviceManagerDidAddDeviceHandlerNotification
													object:nil
													 queue:NSOperationQueue.mainQueue
												usingBlock:^(NSNotification *note) {
													
													OEDeviceHandler *deviceHandler = note.userInfo[OEDeviceManagerDeviceHandlerUserInfoKey];
													[self addMonitorForDeviceHandler:deviceHandler];
													[self updateMenu];
												}];
	
	_observers[OEDeviceManagerDidRemoveDeviceHandlerNotification] =
	[NSNotificationCenter.defaultCenter addObserverForName:OEDeviceManagerDidRemoveDeviceHandlerNotification
													object:nil
													 queue:NSOperationQueue.mainQueue
												usingBlock:^(NSNotification *note) {
													
													OEDeviceHandler *deviceHandler = note.userInfo[OEDeviceManagerDeviceHandlerUserInfoKey];
													[self removeMonitorForDeviceHandler:deviceHandler];
													[self updateMenu];
												}];
}

- (void)dealloc {
	
	_observers.allValues.each(^(id observer) {
		
		[NSNotificationCenter.defaultCenter removeObserver:observer];
	});
}

- (void)addMonitorForDeviceHandler:(OEDeviceHandler *)deviceHandler {
	
	NSString *identifier = deviceHandler.controllerDescription.identifier;
	if (identifier) {
		
		/* Controller remains retained by event monitor's block */
		EventsController *eventsController = [EventsController controllerForDeviceHandler:deviceHandler];
		void(^handler)(OEDeviceHandler *handler, OEHIDEvent *event) = ^(OEDeviceHandler *handler, OEHIDEvent *event) {
			
			[eventsController handleEvent:event];
		};
		
		_eventMonitors[identifier] = [OEDeviceManager.sharedDeviceManager addEventMonitorForDeviceHandler:deviceHandler handler:handler];
	}
}

- (void)removeMonitorForDeviceHandler:(OEDeviceHandler *)deviceHandler {
	
	NSString *identifier = deviceHandler.controllerDescription.identifier;
	if (identifier) [_eventMonitors setValue:nil forKey:identifier];
}

- (NSStatusItem *)createStatusItem {
	
	NSStatusItem *statusItem = [NSStatusBar.systemStatusBar statusItemWithLength:NSVariableStatusItemLength];
	statusItem.button.image = [NSImage imageNamed:@"MenuIcon"];
	[statusItem.button.image setTemplate:YES];
	
	statusItem.menu = NSMenu.new;
	[statusItem.menu addItemWithTitle:@"Quit" action:@selector(terminate:) keyEquivalent:@"q"];
	
	return statusItem;
}

- (void)updateMenu {
	
	NSMenu *appMenu = NSMenu.new;
	
	NSArray *controllers = OEDeviceManager.sharedDeviceManager.controllerDeviceHandlers;
	if (controllers.count) {
		
		// Controllers
		NSMenuItem *devicesItem = NSMenuItem.new;
		devicesItem.title = [NSString stringWithFormat:@"Devices"];
		[appMenu addItem:devicesItem];
		
		// List
		controllers.each(^(OEDeviceHandler *deviceHandler) {
			
			NSString *identifier = deviceHandler.controllerDescription.identifier;
			if (identifier.length > 2) identifier = [identifier substringToIndex:2];
			NSString *name = [NSString stringWithFormat:@"%@ %@", deviceHandler.controllerDescription.name, identifier];
			
			NSMenuItem *controllerItem = NSMenuItem.new;
			controllerItem.title = name;
			[appMenu addItem:controllerItem];
			
			controllerItem.submenu = NSMenu.new;
			MapConfiguration.configurationList.each(^(NSString *configurationName) {
				
				NSMenuItem *configurationItem = NSMenuItem.new;
				configurationItem.title = configurationName;
				configurationItem.target = self;
				configurationItem.action = @selector(setConfiguration:);
				configurationItem.state = [configurationName isEqualToString:@"Default"] ? NSOnState : NSOffState;
				[controllerItem.submenu addItem:configurationItem];
			});
		});
		
		// Separator
		[appMenu addItem:NSMenuItem.separatorItem];
	}
	
	// Quit
	[appMenu addItemWithTitle:@"Quit" action:@selector(terminate:) keyEquivalent:@"q"];
	
	_statusItem.menu = appMenu;
}

- (void)setConfiguration:(id)sender {
	
}

- (void)preventMultipleInstances {
	if ([NSRunningApplication runningApplicationsWithBundleIdentifier:NSBundle.mainBundle.bundleIdentifier].count > 1) [NSApp terminate:nil];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag {
	return NO;
}

@end

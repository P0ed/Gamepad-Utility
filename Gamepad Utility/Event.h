//
//  Event.h
//  Gamepad Utility
//
//  Created by Konstantin Sukharev on 16/01/15.
//  Copyright (c) 2015 P0ed. All rights reserved.
//


@import Foundation;


@interface Event : NSObject

+ (void)postKeyboardEvent:(CGKeyCode)keyCode keyDown:(BOOL)keyDown;
+ (void)postMouseClickEvent:(CGMouseButton)mouseButton buttonDown:(BOOL)buttonDown;
+ (void)postMouseMoveEvent:(CGVector)vector;
+ (void)postScrollEvent:(CGVector)vector;

@end

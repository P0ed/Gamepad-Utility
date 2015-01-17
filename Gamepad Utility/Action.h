//
//  Action.h
//  Gamepad Utility
//
//  Created by Konstantin Sukharev on 16/01/15.
//  Copyright (c) 2015 P0ed. All rights reserved.
//


@import Foundation;
@class Event;


@interface Action : NSObject /*<NSCoding>*/
- (Event *)postEvent;
@end


@interface NSNumber (Action)
- (Action *)keyAction;
- (Action *)mouseClickAction;
@end

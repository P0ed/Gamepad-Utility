//
//  Event.h
//  Gamepad Utility
//
//  Created by Konstantin Sukharev on 16/01/15.
//  Copyright (c) 2015 P0ed. All rights reserved.
//


@import Foundation;


@interface Event : NSObject

+ (instancetype)eventWithCGEvent:(CGEventRef)CGEvent disposeBlock:(void(^)(CGEventRef CGEvent))disposeBlock;
- (void)dispose;

@end

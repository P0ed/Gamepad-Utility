//
//  NSValue+CGVector.h
//  Gamepad Utility
//
//  Created by Konstantin Sukharev on 18/01/15.
//  Copyright (c) 2015 P0ed. All rights reserved.
//

@import Foundation;

@interface NSValue (CGVector)

+ (NSValue *)valueWithVector:(CGVector)vector;
- (CGVector)vectorValue;

@end

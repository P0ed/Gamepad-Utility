//
//  NSValue+CGVector.m
//  Gamepad Utility
//
//  Created by Konstantin Sukharev on 18/01/15.
//  Copyright (c) 2015 P0ed. All rights reserved.
//

#import "NSValue+CGVector.h"

@implementation NSValue (CGVector)

+ (NSValue *)valueWithVector:(CGVector)vector {
	return [NSValue value:&vector withObjCType:@encode(CGVector)];
}

- (CGVector)vectorValue {
	
	CGVector vector;
	[self getValue:&vector];
	
	return vector;
}

@end

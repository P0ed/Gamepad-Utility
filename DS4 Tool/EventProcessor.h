//
//  EventProcessor.h
//  DS4 Tool
//
//  Created by Konstantin Sukharev on 26/12/14.
//  Copyright (c) 2014 P0ed. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OEHIDEvent;

@interface EventProcessor : NSObject
- (void)processEvent:(OEHIDEvent *)event;
@end

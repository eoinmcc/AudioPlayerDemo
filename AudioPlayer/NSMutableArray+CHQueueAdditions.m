//
//  NSMutableArray+CHQueueAdditions.m
//  AudioPlayer
//
//  Created by Eoin McCarthy on 5/08/13.
//  Copyright (c) 2013 Hydric Media Pty Ltd. All rights reserved.
//

#import "NSMutableArray+CHQueueAdditions.h"

@implementation NSMutableArray (CHQueueAdditions)

- (id) dequeue {
    // if ([self count] == 0) return nil; // to avoid raising exception (Quinn)
    id headObject = [self objectAtIndex:0];
    if (headObject != nil) {
        [self removeObjectAtIndex:0];
    }
    return headObject;
}

// Add to the tail of the queue (no one likes it when people cut in line!)
- (void) enqueue:(id)anObject {
    [self addObject:anObject];
    //this method automatically adds to the end of the array
}

@end

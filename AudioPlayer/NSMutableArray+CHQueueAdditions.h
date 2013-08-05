//
//  NSMutableArray+CHQueueAdditions.h
//  AudioPlayer
//
//  Created by Eoin McCarthy on 5/08/13.
//  Copyright (c) 2013 Hydric Media Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (CHQueueAdditions)

- (void)enqueue:(id)anObject;
- (id)dequeue;
@end

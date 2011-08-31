//
//  Coroutine.h
//  CoroutineKit
//
//  Created by Steve Dekorte on 20110830.
//  Copyright 2011 Steve Dekorte. All rights reserved.


#import <Foundation/Foundation.h>
#import "Coro.h"

@interface Coroutine : NSObject
{
	Coro *coro;
	id target;
	SEL action;
	BOOL hasStarted;
	Coroutine *next;
	Coroutine *previous;
}

@property (retain, nonatomic) id target;
@property (assign, nonatomic) SEL action;
@property (readonly, nonatomic) BOOL hasStarted;
@property (assign, nonatomic) Coroutine *next;
@property (assign, nonatomic) Coroutine *previous;

+ (Coroutine *)mainCoroutine;
+ (Coroutine *)currentCoroutine;

- (void)schedule;
- (void)unschedule;
- (void)yield;

// private

- (size_t)stackSize;
- (void)setStackSize:(size_t)size;
- (size_t)bytesLeftOnStack;

@end

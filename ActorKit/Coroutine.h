//
//  Coroutine.h
//  CoroutineKit
//
//  Created by Steve Dekorte on 20110830.
//  Copyright 2011 Steve Dekorte. BSD licensed.
//
// I recommend using the NSObject Actor category instead of this Class directly

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
	id waitingOnFuture;
	NSString *name;
}

// careful with this non-retains...

@property (assign, nonatomic) id target;
@property (assign, nonatomic) SEL action;
@property (readonly, nonatomic) BOOL hasStarted;
@property (assign, nonatomic) Coroutine *next;
@property (assign, nonatomic) Coroutine *previous;
@property (assign, nonatomic) id waitingOnFuture;
@property (retain, nonatomic) NSString *name;

+ (Coroutine *)mainCoroutine;
+ (Coroutine *)currentCoroutine;

- (void)scheduleFirst;
- (void)scheduleLast;
- (void)unschedule;
- (void)yield;

// private

- (id)initAsMain;

- (size_t)stackSize;
- (void)setStackSize:(size_t)size;
- (size_t)bytesLeftOnStack;

- (NSString *)nameId;
- (void)showCoroutineList;

@end

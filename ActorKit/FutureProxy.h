//
//  Future.h
//  ActorKit
//
//  Created by Steve Dekorte on 20110830.
//  Copyright 2011 Steve Dekorte. BSD licensed.

#import "Mutex.h"

@interface FutureProxy : NSProxy
{
	id actor;
	NSInvocation *futureInvocation;
	id value;
	id nextFuture;
	BOOL done;
	NSMutableSet *waitingThreads;
	NSException *exception;
	Mutex *lock;
	SEL action;
}

// private

@property (assign, nonatomic) id actor;
@property (retain, nonatomic) Mutex *lock;
@property (retain, nonatomic) NSInvocation *futureInvocation;
@property (retain, nonatomic) id value;
@property (retain, nonatomic) id nextFuture;
@property (retain, nonatomic) NSMutableSet *waitingThreads;
@property (retain, nonatomic) NSException *exception;

// private

- (void)futureAppend:(FutureProxy *)aFuture;
- (void)futureSend;
- (void)setFutureResult:(id)anObject;
- futureResult;


@end

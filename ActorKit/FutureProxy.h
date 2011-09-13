//
//  Future.h
//  ActorKit
//
//  Created by Steve Dekorte on 20110830.
//  Copyright 2011 Steve Dekorte. BSD licensed.

#import "Mutex.h"

@interface FutureProxy : NSProxy
{
	// these use the "future" prefix/suffix to avoid name collision with proxy target
	
	id futureActor;
	NSInvocation *futureInvocation;
	id futureValue;
	id nextFuture;
	BOOL done;
	NSMutableSet *futureWaitingThreads;
	NSException *futureException;
	Mutex *futureLock;
}

// these are all private

@property (assign, nonatomic) id futureActor;
@property (retain, nonatomic) NSInvocation *futureInvocation;
@property (retain, nonatomic) id futureValue;
@property (retain, nonatomic) id nextFuture;
@property (retain, nonatomic) NSMutableSet *futureWaitingThreads;
@property (retain, nonatomic) NSException *futureException;
@property (retain, nonatomic) Mutex *futureLock;

- (void)futureAppend:(FutureProxy *)aFuture;
- (void)futureSend;

- (void)setFutureResult:(id)anObject;
- futureResult;

@end

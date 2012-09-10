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
	Mutex *futureLock; // used to pause any threads accessing future before it is done
	Mutex *futureQueueLimitMutex; // used to pause the thread sending the message if the actor q limit is reached
}

// these are all private

@property (assign, atomic) id futureActor;
@property (retain, atomic) NSInvocation *futureInvocation;
@property (retain, atomic) id futureValue;
@property (retain, atomic) id nextFuture;
@property (retain, atomic) NSMutableSet *futureWaitingThreads;
@property (retain, atomic) NSException *futureException;
@property (retain, atomic) Mutex *futureLock;
@property (retain, atomic) Mutex *futureQueueLimitMutex;

- (id)init;

- (void)futureAppend:(FutureProxy *)aFuture;
- (void)futureSend;

- (void)setFutureResult:(id)anObject;
- futureResult;

- (void)pauseThreadOnQueueLimitMutex;

@end

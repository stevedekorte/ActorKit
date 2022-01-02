//
//  NSObject+Actor.h
//  ActorKit
//
//  Copyright 2011 Steve Dekorte. BSD licensed.
//

#import "FutureProxy.h"
#import "Mutex.h"
#import "NSThread+Actor.h"

@interface ActorProxy : NSProxy {
	// using the "actor" prefix to avoid name conflict with proxied object
	id actorTarget;
	Mutex *actorMutex;
	FutureProxy *firstFuture;
	NSThread *actorThread;
	size_t actorQueueSize; 
	size_t actorQueueLimit; // if zero, there is no limit
}

// all private

@property (retain, atomic) id actorTarget;
@property (retain, atomic) Mutex *actorMutex;
@property (retain, atomic) FutureProxy *firstFuture;
@property (retain, atomic) NSThread *actorThread;
@property (assign, atomic) size_t actorQueueSize; 

- (void)setProxyTarget:anObject;

// public

@property (assign, atomic) size_t actorQueueLimit;

+ (ActorProxy *)currentActorProxy;

- (id)pauseThread; // returns with object passed to resumeThreadWithReturnObject:
- (void)resumeThread;
- (void)resumeThreadWithReturnObject:(id)returnValue;

@end

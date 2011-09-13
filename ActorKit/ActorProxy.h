//
//  NSObject+Actor.h
//  ActorKit
//
//  Created by Steve Dekorte on 20110831.
//  Copyright 2011 Steve Dekorte. BSD licensed.
//

#import "FutureProxy.h"
#import "Mutex.h"
#import "NSThread+Actor.h"

@interface ActorProxy : NSProxy
{
	id actorTarget;
	Mutex *mutex;
	FutureProxy *firstFuture;
	NSThread *actorThread;
}

@property (retain, atomic) id actorTarget;
@property (retain, atomic) Mutex *mutex;
@property (retain, atomic) FutureProxy *firstFuture;
@property (retain, atomic) NSThread *actorThread;


@end

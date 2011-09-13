//
//  NSObject+Actor.m
//  ActorKit
//
//  Created by Steve Dekorte on 20110831.
//  Copyright 2011 Steve Dekorte. BSD licensed.
//

#import "NSObject+Actor.h"
#import "NSThread+Actor.h"
#import <objc/runtime.h>

@implementation NSObject (NSObject_Actor)

- (void)setMutex:(Mutex *)aMutex
{
	objc_setAssociatedObject(self, "mutex", aMutex, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (Mutex *)mutex
{
	return (Mutex *)objc_getAssociatedObject(self, "mutex");
}


- (void)setFirstFuture:(Future *)aFuture
{
	objc_setAssociatedObject(self, "firstFuture", aFuture, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (Future *)firstFuture
{
	return (Future *)objc_getAssociatedObject(self, "firstFuture");
}

- (void)setActorThread:(NSThread *)aThread
{
	objc_setAssociatedObject(self, "actorThread", aThread, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSThread *)actorThread
{	
	return (NSThread *)objc_getAssociatedObject(self, "actorThread");;
}

- (NSThread *)actorThreadCreateOrResumeIfNeeded
{
	NSThread *thread = [self actorThread];
		
	if(!thread)
	{
		[self setMutex:[[[Mutex alloc] init] autorelease]];
		thread = [[[NSThread alloc] initWithTarget:self selector:@selector(actorRunLoop:) object:nil] autorelease];
		[self setActorThread:thread];
		[thread setName:[NSString stringWithFormat:@"%@", [self className]]];
		[thread start];
	}
	else
	{
		[[self mutex] resumeThread];
	}
	
	return thread;
}

// still need to implement dealloc

/*
- (void)dealloc
{
	// threads retain the Future's they are waiting on, which retains the actor
	// so dealloc should only occur when it's safe of dependencies 

	if([self actorThread])
	{
		[[self actorThread] cancel];
	}
	
	[self setFirstFuture:nil];	
	[self setActorThread:nil];
}
*/

- (Future *)newFuture
{
	Future *future = [[[Future alloc] init] autorelease];
	
	
	return future;
}

- (void)asyncPerformSelector:(SEL)selector withObject:anObject
{
	[self futurePerformSelector:selector withObject:anObject];
}

- (Future *)futurePerformSelector:(SEL)selector withObject:anObject
{
	NSLock *lock = [[self actorThread] lock];
	[lock lock];

	Future *future = [self newFuture];

	[future setActor:self];
	[future setSelector:selector];
	[future setArgument:anObject];
	
	if([self firstFuture])
	{
		[[self firstFuture] append:future];
	}
	else
	{
		[self setFirstFuture:future];
	}
	
	[self actorThreadCreateOrResumeIfNeeded];
	[lock unlock];
	
	return future;
}

- (void)actorRunLoop:sender
{
	NSLock *lock = [[self actorThread] lock];

	if([NSThread currentThread] != [self actorThread])
	{
		[NSException raise:@"Actor" format:@"attempt to start actor loop from another thread"];
	}
	
	while(![[NSThread currentThread] isCancelled])
	{	
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init]; // Top-level pool
		
		while([self firstFuture])
		{
			Future *f = [self firstFuture];
			[f send]; // exceptions are caught within the send method
			[lock lock];
			[self setFirstFuture:[f nextFuture]];
			[lock unlock];
		}
		
		[pool release];
		
		[[self mutex] pauseThread];
	}
}

@end

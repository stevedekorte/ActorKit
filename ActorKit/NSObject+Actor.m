//
//  NSObject+Actor.m
//  ActorKit
//
//  Created by Steve Dekorte on 20110831.
//  Copyright 2011 Steve Dekorte. BSD licensed.
//

#import "NSObject+Actor.h"
#import <objc/runtime.h>


@implementation NSObject (NSObject_Actor)

static long activeActorCount = 0;

- (void)setFirstFuture:(Future *)aFuture
{
	objc_setAssociatedObject(self, "firstFuture", aFuture, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (Future *)firstFuture
{
	return (Future *)objc_getAssociatedObject(self, "firstFuture");
}

- (void)setActorCoroutine:(Coroutine *)aCoroutine
{
	objc_setAssociatedObject(self, "actorCoroutine", aCoroutine, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (Coroutine *)actorCoroutine
{
	Coroutine *c = (Coroutine *)objc_getAssociatedObject(self, "actorCoroutine");
	
	if(!c)
	{
		c = [[[Coroutine alloc] init] autorelease];
		[c setTarget:self];
		[c setAction:@selector(actorRunLoop)];
		[self setActorCoroutine:c];
		[c setName:[NSString stringWithFormat:@"%@", [self className]]];
	}
	
	return c;
}

/*
- (void)dealloc
{
	// coros retain the Future's they are waiting on, which retains the actor
	// so dealloc should only occur when it's safe of dependencies 
	[self setFirstFuture:nil];
	[self setCoroutine:nil];
	[super dealloc];
}
*/

- (Future *)newFuture
{
	Future *future = [[[Future alloc] init] autorelease];
	
	if([self firstFuture])
	{
		[[self firstFuture] append:future];
	}
	else
	{
		[self setFirstFuture:future];
	}
	
	return future;
}

- (void)asyncPerformSelector:(SEL)selector withObject:anObject
{
	[self futurePerformSelector:selector withObject:anObject];
}

- (Future *)futurePerformSelector:(SEL)selector withObject:anObject
{
	Future *future = [self newFuture];

	[future setActor:self];
	[future setSelector:selector];
	[future setArgument:anObject];
	[[self actorCoroutine] scheduleLast];
	
	return future;
}

- (void)actorRunLoop
{
	while(YES) // coroutines never return, they are only unscheduled
	{	
		activeActorCount ++;
		
		if([Coroutine currentCoroutine] != [self actorCoroutine])
		{
			[NSException raise:@"Actor" format:@"actorRunLoop not running from actor coroutine!"];
		}
		
		while([self firstFuture])
		{
			Future *f = [self firstFuture];
			[f send]; // exceptions are caught within the send method
			[self setFirstFuture:[f nextFuture]];
			[[self actorCoroutine] yield];
		}
		
		activeActorCount --;
		[[self actorCoroutine] unschedule];
	}
}

@end

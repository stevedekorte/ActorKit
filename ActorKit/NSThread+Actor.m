//
//  NSObject+Actor.m
//  ActorKit
//
//  Created by Steve Dekorte on 20110831.
//  Copyright 2011 Steve Dekorte. BSD licensed.
//

#import "NSThread+Actor.h"
#import "Mutex.h"

@implementation NSThread (NSThread_Actor)

// future

- (void)setWaitingOnFuture:(id)anObject
{
	if(anObject == nil)
	{
		[[self threadDictionary] removeObjectForKey:@"waitingOnFuture"];
	}
	else
	{
		[[self threadDictionary] setObject:anObject forKey:@"waitingOnFuture"];
	}
}

- waitingOnFuture
{
	return [[self threadDictionary] objectForKey:@"waitingOnFuture"];
}

// lock

- (void)setLock:(id)anObject
{
	if(anObject == nil)
	{
		[[self threadDictionary] removeObjectForKey:@"lock"];
	}
	else
	{
		[[self threadDictionary] setObject:anObject forKey:@"lock"];
	}
}

- (Mutex *)lock
{
	Mutex *lock = [[self threadDictionary] objectForKey:@"lock"];
	
	if (!lock)
	{
		lock = [[[NSLock alloc] init] autorelease];
		[self setLock:lock];
	}
	
	return lock;
}

@end

//
//  Future.m
//  ActorKit
//
//  Created by Steve Dekorte on 20110830.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Future.h"
#import "Coroutine.h"

@implementation Future

@synthesize actor;
@synthesize selector;
@synthesize argument;
@synthesize value;
@synthesize nextFuture;
@synthesize waitingCoroutines;

- (id)init
{
    self = [super init];
    
	if (self) 
	{
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc
{
	[self setActor:nil];
	[self setArgument:nil];
	[self setValue:nil];
	[self setNextFuture:nil];
	[self setWaitingCoroutines:nil];
	[super dealloc];
}

- (void)append:(Future *)aFuture
{
	if(nextFuture)
	{
		[nextFuture append:aFuture];
	}
	else
	{
		[self setNextFuture:aFuture];
	}
}

- (void)send
{
	[actor performSelector:selector withObject:arguemnt];
}

- (void)setResult:(id)anObject
{
	[self setValue:anObject];
	done = YES;
	
	for(Coroutine *c in waitingCoroutines)
	{
		[waitingCoroutine setWaitingOnFuture:nil];
		[waitingCoroutine scheduleNext];
	}
	 
	[waitingCoroutines removeAllObjects];
}

- (BOOL)isWaitingOnCurrentCoroutine
{
	for(Coroutine *c in waitingCoroutines)
	{
		Future *waitingOnFuture = [waitingCoroutine waitingOnFuture];
		if([waitingOnFuture isWaitingOnCurrentCoroutine]) return YES;
	}
	
	return NO;
}

- (id)result
{
	if(done) 
	{
		return value;
	}
	
	if([self isWaitingOnCurrentCoroutine])
	{
		[NSException raise:@"Future" format:@"waiting for result on this coroutine would cause a deadlock"];
	}
	
	[waitingCoroutines addObject:[Coroutine currentCoroutine]];
	[[Coroutine currentCoroutine] setWaitingOnFuture:self];
	
	while(!done) // make this a loop just in case someone accidentally schedules the coro
	{
		[[Coroutine currentCoroutine] unschedule];
	}
	
	return value;
}

@end

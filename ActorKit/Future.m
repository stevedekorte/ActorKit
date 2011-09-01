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
@synthesize exception;

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
	[self setException:nil];
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
	@try 
	{
		[actor performSelector:selector withObject:argument];
	}
	@catch (NSException *exception) 
	{
		[self setException:exception];
		[self setResult:nil];
	}
}

- (void)setResult:(id)anObject
{
	[self setValue:anObject];
	done = YES;
	
	for(Coroutine *waitingCoroutine in waitingCoroutines)
	{
		[waitingCoroutine setWaitingOnFuture:nil];
		[waitingCoroutine scheduleLast];
	}
	 
	[waitingCoroutines removeAllObjects];
}

- (BOOL)isWaitingOnCurrentCoroutine
{
	// recursion should void loop since the deadlock detection prevents loops
	
	for(Coroutine *waitingCoroutine in waitingCoroutines)
	{		
		if([[waitingCoroutine waitingOnFuture] isWaitingOnCurrentCoroutine]) 
		{
			return YES;
		}
	}
	
	return NO;
}

- (id)result
{
	if(done) 
	{
		return value;
	}
	
	while([self isWaitingOnCurrentCoroutine]) // loop in case exception is resumed 
	{
		[NSException raise:@"Future" format:@"waiting for result on this coroutine would cause a deadlock"];
	}
	
	[waitingCoroutines addObject:[Coroutine currentCoroutine]];
	[[Coroutine currentCoroutine] setWaitingOnFuture:self];
	
	[[Coroutine currentCoroutine] unschedule];

	while(!done) // loop in case exception is resumed 
	{
		[NSException raise:@"Future" format:@"attempt to resume coroutine waiting on future before result is ready"];
		[[Coroutine currentCoroutine] unschedule];
	}
	
	if(exception)
	{
		// guessing we have to wrap the exception so the stack info of original will be available
		NSException *e = [[NSException alloc] initWithName:@"Future" 
			reason:@"exception during send" 
			userInfo:[NSDictionary dictionaryWithObject:exception forKey:@"exception"]];
		[e raise];
	}
	
	return value;
}

@end

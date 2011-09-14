//
//  Future.m
//  ActorKit
//
//  Created by Steve Dekorte on 20110830.
//  Copyright 2011 Steve Dekorte. BSD licensed.
//

#import "ActorProxy.h"
#import "FutureProxy.h"
#import "NSThread+Actor.h"

@implementation FutureProxy

@synthesize futureActor;
@synthesize futureInvocation;
@synthesize futureValue;
@synthesize nextFuture;
@synthesize futureWaitingThreads;
@synthesize futureException;
@synthesize futureLock;

- (id)init
{
    //self = [super init]; // NSProxy doesn't implement init
    
	if (self) 
	{
		done = NO;
		[self setFutureLock:[[[Mutex alloc] init] autorelease]];
		[self setFutureWaitingThreads:[NSMutableSet set]];
    }
    
    return self;
}

- (void)dealloc
{
	[self setFutureActor:nil];
	[self setFutureInvocation:nil];
	[self setFutureValue:nil];
	[self setNextFuture:nil];
	[self setFutureWaitingThreads:nil];
	[self setFutureException:nil];
	[self setFutureLock:nil];
	[super dealloc];
}

- (void)futureAppend:(FutureProxy *)aFuture
{
	if(nextFuture)
	{
		[nextFuture futureAppend:aFuture];
	}
	else
	{
		[self setNextFuture:aFuture];
	}
}

- (void)futureShowSend
{
	NSLog(@"FutureProxy send [%@ %@]\n", 
		   [[futureActor actorTarget] className], 
		   NSStringFromSelector([futureInvocation selector]));
}

- (void)futureSend
{
	@try 
	{
		//[self futureShowSend];
		[futureInvocation invokeWithTarget:[futureActor actorTarget]];

		id r;
		[futureInvocation getReturnValue:(void *)&r];
		[self setFutureResult:r];
	}
	@catch (NSException *e) 
	{
		[self setFutureException:e];
		[self setFutureResult:nil];
	}
	
	for(NSThread *waitingThread in futureWaitingThreads)
	{
		[waitingThread setWaitingOnFuture:nil];
	}
	
	[futureWaitingThreads removeAllObjects];
	[futureLock resumeThread];
}

- (void)setFutureResult:(id)anObject
{
	if(done) 
	{	
		return;
	}
	
	done = YES;

	[self setFutureValue:anObject];
}

- (BOOL)isWaitingOnCurrentThread
{
	// the recursion should avoid loop since the deadlock detection prevents loops
	
	for(NSThread *waitingThread in futureWaitingThreads)
	{		
		if([[waitingThread waitingOnFuture] isWaitingOnCurrentThread]) 
		{
			return YES;
		}
	}
	
	return NO;
}

- (void)futurePassExceptionIfNeeded
{
	if(futureException)
	{
		// guessing we have to wrap the exception so the stack info of original will be available
		NSMutableDictionary *info = [NSMutableDictionary dictionary];
		[info setObject:futureException forKey:@"exception"];
		[info setObject:self forKey:@"future"];
		
		NSException *e = [[NSException alloc] initWithName:@"Future" 
													reason:@"exception during send" 
												  userInfo:info];
		[e raise];
	}
}

- (void)futureRaiseExceptionIfDeadlock
{
	if([self isWaitingOnCurrentThread]) 
	{
		[NSException raise:@"Future" format:@"waiting for result on this coroutine would cause a deadlock"];
	}

}

- futureResult
{	
	if(done) 
	{
		[self futurePassExceptionIfNeeded];
		return futureValue;
	}

	[futureWaitingThreads addObject:[NSThread currentThread]];
	[self futureRaiseExceptionIfDeadlock];
	[futureLock pauseThread];
	[self futurePassExceptionIfNeeded];
	
	return futureValue;
}


- (void)forwardInvocation:(NSInvocation *)anInvocation
{
	[anInvocation invokeWithTarget:[self futureResult]];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
	return [[self futureResult] methodSignatureForSelector:aSelector];
}

@end

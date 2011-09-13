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

@synthesize lock;
@synthesize actor;
@synthesize futureInvocation;
@synthesize value;
@synthesize nextFuture;
@synthesize waitingThreads;
@synthesize exception;

- (id)init
{
    //self = [super init]; // NSProxy doesn't implement init
    
	if (self) 
	{
		done = NO;
		[self setLock:[[[Mutex alloc] init] autorelease]];
		[self setWaitingThreads:[NSMutableSet set]];
    }
    
    return self;
}

- (void)dealloc
{
	[self setActor:nil];
	[self setFutureInvocation:nil];
	[self setValue:nil];
	[self setNextFuture:nil];
	[self setWaitingThreads:nil];
	[self setException:nil];
	[self setLock:nil];
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
		   [[actor actorTarget] className], 
		   NSStringFromSelector([futureInvocation selector]));
}

- (void)futureSend
{
	@try 
	{
		//[self futureShowSend];
		[futureInvocation invokeWithTarget:[actor actorTarget]];

		id r;
		[futureInvocation getReturnValue:(void *)&r];
		[self setFutureResult:r];
	}
	@catch (NSException *e) 
	{
		printf("exception\n");
		[self setException:e];
		[self setFutureResult:nil];
	}
	
	for(NSThread *waitingThread in waitingThreads)
	{
		[waitingThread setWaitingOnFuture:nil];
	}
	
	[waitingThreads removeAllObjects];
	[lock resumeThread];
}

- (void)setFutureResult:(id)anObject
{
	if(done) 
	{	
		return;
	}
	
	done = YES;

	[self setValue:anObject];
}

- (BOOL)isWaitingOnCurrentThread
{
	// the recursion should avoid loop since the deadlock detection prevents loops
	
	for(NSThread *waitingThread in waitingThreads)
	{		
		if([[waitingThread waitingOnFuture] isWaitingOnCurrentThread]) 
		{
			return YES;
		}
	}
	
	return NO;
}

- futureResult
{
	if(done) 
	{
		return value;
	}

	[waitingThreads addObject:[NSThread currentThread]];

	if([self isWaitingOnCurrentThread]) 
	{
		[NSException raise:@"Future" format:@"waiting for result on this coroutine would cause a deadlock"];
		return nil;
	}
	
	[lock pauseThread];
			
	if(exception)
	{
		// guessing we have to wrap the exception so the stack info of original will be available
		NSException *e = [[NSException alloc] initWithName:@"Future" 
													reason:@"exception during send" 
												  userInfo:[NSDictionary dictionaryWithObject:self forKey:@"future"]];
		[e raise];
	}
	
	return value;
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

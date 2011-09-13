//
//  Future.m
//  ActorKit
//
//  Created by Steve Dekorte on 20110830.
//  Copyright 2011 Steve Dekorte. BSD licensed.
//

#import "Future.h"
#import "NSThread+Actor.h"

@implementation Future

@synthesize lock;
@synthesize actor;
@synthesize selector;
@synthesize argument;
@synthesize value;
@synthesize nextFuture;
@synthesize waitingThreads;
@synthesize exception;
@synthesize error;
@synthesize delegate;

- (id)init
{
    self = [super init];
    
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
	[self setArgument:nil];
	[self setValue:nil];
	[self setNextFuture:nil];
	[self setWaitingThreads:nil];
	[self setException:nil];
	[self setError:nil];
	[self setDelegate:nil];
	[self setLock:nil];
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
		/*
		printf("Future send [%s %s%s]\n", 
			   [[actor className] UTF8String], 
			   [NSStringFromSelector(selector) UTF8String], 
			   [[argument className] UTF8String]);
		*/
		id r = [actor performSelector:selector withObject:argument];
		[self setResult:r];
	}
	@catch (NSException *e) 
	{
		printf("exception\n");
		[self setException:e];
		[self setResult:nil];
	}
	
	for(NSThread *waitingThread in waitingThreads)
	{
		[waitingThread setWaitingOnFuture:nil];
	}
	
	[waitingThreads removeAllObjects];
	[lock resumeThread];
}

- (void)setResult:(id)anObject
{
	if(done) 
	{	
		return;
	}
	
	done = YES;

	[self setValue:anObject];
	
	if (delegate && action) 
	{
		[delagate performSelector:action withObject:self];
	}
}

- (BOOL)isWaitingOnCurrentThread
{
	// thie recursion should avoid loop since the deadlock detection prevents loops
	
	for(NSThread *waitingThread in waitingThreads)
	{		
		if([[waitingThread waitingOnFuture] isWaitingOnCurrentThread]) 
		{
			return YES;
		}
	}
	
	return NO;
}

- result
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

@end

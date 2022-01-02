//
//  NSObject+Actor.m
//  ActorKit
//
//  Created by Steve Dekorte on 20110831.
//  Copyright 2011 Steve Dekorte. BSD licensed.
//

#import "ActorProxy.h"
#import "FutureProxy.h"

@implementation ActorProxy

@synthesize actorTarget;
@synthesize actorMutex;
@synthesize firstFuture;
@synthesize actorThread;
@synthesize actorQueueSize;
@synthesize actorQueueLimit;

- init {
    //self = [super init]; // NSProxy doesn't implement init
	return self;
}

- (void)setProxyTarget:anObject {
	[self setActorTarget:anObject];
}

- (NSThread *)actorThreadCreateOrResumeIfNeeded {
	NSThread *thread = [self actorThread];
		
	if (!thread) {
		[self setActorMutex:[[[Mutex alloc] init] autorelease]];
		thread = [[[NSThread alloc] initWithTarget:self selector:@selector(actorRunLoop:) object:nil] autorelease];
		[self setActorThread:thread];
		[thread setName:[NSString stringWithFormat:@"%@", [actorTarget className]]];
		
		[[thread threadDictionary] setObject:self forKey:@"actorProxy"];
		[thread start];
	} else {
		[actorMutex resumeAnyWaitingThreads];
	}
	
	return thread;
}

- (void)dealloc {
	// threads retain the Future's they are waiting on, which retains the actor
	// so dealloc should only occur when it's safe of dependencies 

	if ([self actorThread]) {
		[[self actorThread] cancel];
	}
	
	[super dealloc];
}

- (FutureProxy *)futurePerformInvocation:(NSInvocation *)anInvocation {
	BOOL willPauseCaller = NO;
	NSLock *lock = [[self actorThread] lock];
	
	[lock lock];

	FutureProxy *future = [[[FutureProxy alloc] init] autorelease];

	[future setFutureActor:self];
	[future setFutureInvocation:anInvocation];
	[anInvocation retainArguments];
	
	if ([self firstFuture]) {
		[[self firstFuture] futureAppend:future];
	} else {
		[self setFirstFuture:future];
	}
	
	actorQueueSize ++;
	
	[self actorThreadCreateOrResumeIfNeeded];
	
	willPauseCaller = (actorQueueLimit && actorQueueLimit == actorQueueSize);
	[lock unlock];
	
	if (willPauseCaller) {
		[future pauseThreadOnQueueLimitMutex];
	}
	
	return future;
}

- (void)actorRunLoop:sender {
	NSLock *lock = [[self actorThread] lock];

	if ([NSThread currentThread] != [self actorThread]) {
		[NSException raise:@"Actor" format:@"attempt to start actor loop from another thread"];
	}
	
	while(![[NSThread currentThread] isCancelled]) {	
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
		while([self firstFuture]) {
			FutureProxy *f = [self firstFuture];
			[f futureSend]; // exceptions are caught within the futureSend method
			[lock lock];
			[self setFirstFuture:[f nextFuture]];
			actorQueueSize --;
			[lock unlock];
		}
		
		[pool release];
		
		[actorMutex pauseThread];
	}
	
	// do these here so they aren't freed before the thread is done
	[self setFirstFuture:nil];	
	[self setActorThread:nil];
	[self setActorMutex:nil];
}

- (BOOL)respondsToSelector:(SEL)aSelector {
	return YES;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
	if ([[anInvocation methodSignature] methodReturnType][0] != '@') {
		NSString *msg = [NSString stringWithFormat:@"sent '%@' but only methods that return objects are supported",
						 NSStringFromSelector([anInvocation selector])];
		NSLog(@"ActorProxy ERROR: %@", msg);
		[NSException raise:@"ActorProxy" format:@"%@", msg];
	}
	
	FutureProxy *f = [self futurePerformInvocation:anInvocation];
	[anInvocation setReturnValue:(void *)&f];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
	return [actorTarget methodSignatureForSelector:aSelector];
}

// --- pausing and resuming ---
//
// for use from within an actor method executing in order to
// pause actor thread while waiting on async ops or other callbacks

+ (ActorProxy *)currentActorProxy {
	return [[[NSThread currentThread] threadDictionary] objectForKey:@"actorProxy"];
}

- (id)pauseThread {
	[actorMutex pauseThread];
	id returnValue = [[[NSThread currentThread] threadDictionary] objectForKey:@"returnValue"];
	[[[NSThread currentThread] threadDictionary] removeObjectForKey:@"returnValue"];
	return returnValue;
}

- (void)resumeThread {
	[actorMutex resumeAnyWaitingThreads];
}

- (void)resumeThreadWithReturnObject:(id)returnValue {
	// might move returnValue to ivar
	[[[NSThread currentThread] threadDictionary] setObject:returnValue forKey:@"returnValue"];
	[self resumeThread];
}

@end

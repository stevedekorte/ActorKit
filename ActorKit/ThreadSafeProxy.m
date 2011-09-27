//
//  NSObject+Actor.m
//  ActorKit
//
//  Created by Steve Dekorte on 20110831.
//  Copyright 2011 Steve Dekorte. BSD licensed.
//

#import "ThreadSafeProxy.h"


@implementation ThreadSafeProxy

@synthesize threadSafeProxyTarget;
@synthesize threadSafeProxyLock;

- init
{
	[self setThreadSafeProxyLock:[[[NSLock alloc] init] autorelease]];
	return self;
}

- (void)dealloc
{
	[self setThreadSafeProxyTarget:nil];
	[self setThreadSafeProxyLock:nil];
	[super dealloc];
}

- (void)setProxyTarget:anObject
{
	[self setThreadSafeProxyTarget:anObject];
	[threadSafeProxyLock setName:[threadSafeProxyTarget description]];
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
	return [threadSafeProxyLock respondsToSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
	// probably could have used @synchronized() {} 
	// but access to the lock object might be useful later
	
	[threadSafeProxyLock lock];
	[anInvocation invokeWithTarget:threadSafeProxyTarget];
	[threadSafeProxyLock unlock];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
	return [threadSafeProxyTarget methodSignatureForSelector:aSelector];
}

@end

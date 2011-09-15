//
//  NSObject+Actor.m
//  ActorKit
//
//  Created by Steve Dekorte on 20110831.
//  Copyright 2011 Steve Dekorte. BSD licensed.
//

#import "SyncProxy.h"


@implementation SyncProxy

@synthesize syncProxyTarget;
@synthesize syncProxyLock;

- init
{
	[self setSyncProxyLock:[[[NSLock alloc] init] autorelease]];
	return self;
}

- (void)dealloc
{
	[self setSyncProxyTarget:nil];
	[self setSyncProxyLock:nil];
	[super dealloc];
}

- (void)setProxyTarget:anObject
{
	[self setSyncProxyTarget:anObject];
	[syncProxyLock setName:[syncProxyTarget description]];
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
	return [syncProxyTarget respondsToSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
	// probably could have used @synchronized() {} 
	// but access to the lock object might be useful later
	
	[syncProxyLock lock];
	[anInvocation invokeWithTarget:syncProxyTarget];
	[syncProxyLock unlock];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
	return [syncProxyTarget methodSignatureForSelector:aSelector];
}

@end

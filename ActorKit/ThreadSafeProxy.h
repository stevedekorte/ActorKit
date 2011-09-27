//
//  NSObject+Actor.h
//  ActorKit
//
//  Created by Steve Dekorte on 20110831.
//  Copyright 2011 Steve Dekorte. BSD licensed.
//
// A simple proxy wrapper that synchronizes all messages to the target

@interface ThreadSafeProxy : NSProxy
{	
	id threadSafeProxyTarget;
	NSLock *threadSafeProxyLock;
}

// all private

@property (retain, atomic) id threadSafeProxyTarget;
@property (retain, atomic) NSLock *threadSafeProxyLock;

- (void)setThreadSafeProxyTarget:anObject;

@end

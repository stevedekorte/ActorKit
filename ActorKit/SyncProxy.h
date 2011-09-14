//
//  NSObject+Actor.h
//  ActorKit
//
//  Created by Steve Dekorte on 20110831.
//  Copyright 2011 Steve Dekorte. BSD licensed.
//
// A simple proxy wrapper that synchronizes all messages to the target

@interface SyncProxy : NSProxy
{	
	id syncProxyTarget;
	NSLock *syncProxyLock;
}

// all private

@property (retain, atomic) id syncProxyTarget;
@property (retain, atomic) NSLock *syncProxyLock;

@end

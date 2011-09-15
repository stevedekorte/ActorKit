//
//  NSObject+Actor.m
//  ActorKit
//
//  Created by Steve Dekorte on 20110831.
//  Copyright 2011 Steve Dekorte. BSD licensed.
//

#import "NSObject+Actor.h"
#import <objc/runtime.h>

@implementation NSObject (NSObject_Actor)

- proxyForProxyClass:(Class)aClass
{
	id obj = objc_getAssociatedObject(self, (void *)aClass);
	
	if(!obj)
	{
		obj = [[[aClass alloc] init] autorelease];
		[obj setProxyTarget:self];
		objc_setAssociatedObject(self, aClass, obj, OBJC_ASSOCIATION_ASSIGN);
	}
	
	return (id)obj;	
}

- asActor
{
	return [self proxyForProxyClass:[ActorProxy class]];
}

- asSynchronous
{
	return [self proxyForProxyClass:[SyncProxy class]];
}

/*
static char *actorKey = "ActorProxy";

- asActor
{
	ActorProxy *actor = objc_getAssociatedObject(self, actorKey);

	if(!actor)
	{
		actor = [[[ActorProxy alloc] init] autorelease];
		[actor setActorTarget:self];
		objc_setAssociatedObject(self, actorKey, actor, OBJC_ASSOCIATION_ASSIGN);
	}
	
	return (id)actor;	
}

static char *synchoronousKey = "SyncProxy";

- asSynchronous
{
	SyncProxy *sp = objc_getAssociatedObject(self, synchoronousKey);
	
	if(!sp)
	{
		sp = [[[SyncProxy alloc] init] autorelease];
		[sp setSyncProxyTarget:self];
		objc_setAssociatedObject(self, synchoronousKey, sp, OBJC_ASSOCIATION_ASSIGN);
	}
	
	return (id)sp;	
}
*/

@end

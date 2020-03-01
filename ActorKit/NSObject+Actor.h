//
//  NSObject+Actor.h
//  ActorKit
//
//  Copyright 2011 Steve Dekorte. BSD licensed.
//

#import "ActorProxy.h"
#import "ThreadSafeProxy.h"
#import "BatchProxy.h"

@interface NSObject (NSObject_Actor)

- proxyForProxyClass:(Class)aClass;

- asActor;
- asThreadSafe;

@end

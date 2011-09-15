//
//  NSObject+Actor.h
//  ActorKit
//
//  Created by Steve Dekorte on 20110831.
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

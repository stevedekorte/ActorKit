//
//  NSObject+Actor.h
//  ActorKit
//
//  Created by Steve Dekorte on 20110831.
//  Copyright 2011 Steve Dekorte. BSD licensed.
//

#import "ActorProxy.h"
#import "SyncProxy.h"

@interface NSObject (NSObject_Actor)

- asActor;
- asSynchronous;

@end

//
//  NSObject+Actor.h
//  ActorKit
//
//  Created by Steve Dekorte on 20110831.
//  Copyright 2011 Steve Dekorte. BSD licensed.
//

#import "Coroutine.h"
#import "Future.h"

@interface NSObject (NSObject_Actor)

// private

- (void)actorRunLoop;

// public

- (void)asyncPerformSelector:(SEL)selector withObject:anObject;
- (Future *)futurePerformSelector:(SEL)selector withObject:anObject;

@end

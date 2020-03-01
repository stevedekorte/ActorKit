//
//  NSObject+Actor.h
//  ActorKit
//
//  Copyright 2011 Steve Dekorte. BSD licensed.
//

#import <Foundation/Foundation.h>

@interface NSThread (NSThread_Actor)

- (void)setWaitingOnFuture:(id)aFuture;
- waitingOnFuture;

- (NSLock *)lock;

@end

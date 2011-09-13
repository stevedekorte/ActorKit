//
//  NSObject+Actor.h
//  ActorKit
//
//  Created by Steve Dekorte on 20110831.
//  Copyright 2011 Steve Dekorte. BSD licensed.
//

#import <Foundation/Foundation.h>

@interface NSThread (NSThread_Actor)

- (void)setWaitingOnFuture:(id)aFuture;
- waitingOnFuture;

- (NSLock *)lock;

@end

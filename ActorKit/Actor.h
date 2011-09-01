//
//  Actor.h
//  ActorKit
//
//  Created by Steve Dekorte on 20110830.
//  Copyright 2011 Steve Dekorte. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Coroutine.h"
#import "Future.h"

@interface Actor : NSObject
{
	Future *firstFuture; // todo: add last future for speed
	Coroutine *coroutine;
}

@property (retain, nonatomic) Future *firstFuture;
@property (retain, nonatomic) Coroutine *coroutine; // private

- (void)asyncPerformSelector:(SEL)selector withObject:anObject;
- (Future *)futurePerformSelector:(SEL)selector withObject:anObject;

@end

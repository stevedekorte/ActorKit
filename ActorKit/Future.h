//
//  Future.h
//  ActorKit
//
//  Created by Steve Dekorte on 20110830.
//  Copyright 2011 Steve Dekorte. BSD licensed.

#import "Mutex.h"

@interface Future : NSObject
{
	id actor;
	SEL selector;
	id argument;
	id value;
	id nextFuture;
	BOOL done;
	NSMutableSet *waitingThreads;
	NSException *exception;
	NSError *error;
	Mutex *lock;
	id delegate;
	SEL action;
}

// private

@property (assign, nonatomic) Mutex *lock;
@property (assign, nonatomic) id actor;
@property (assign, nonatomic) SEL selector;
@property (retain, nonatomic) id argument;
@property (retain, nonatomic) id value;
@property (retain, nonatomic) id nextFuture;
@property (retain, nonatomic) NSMutableSet *waitingThreads;
@property (retain, nonatomic) NSError *error;
@property (assign, nonatomic) id delegate;

- (void)append:(Future *)aFuture;
- (void)send;
- (void)setResult:(id)anObject;

// public

@property (retain, nonatomic) NSException *exception;

- result;


@end

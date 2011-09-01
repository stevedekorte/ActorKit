//
//  Future.h
//  ActorKit
//
//  Created by Steve Dekorte on 20110830.
//  Copyright 2011 Steve Dekorte. BSD licensed.



@interface Future : NSObject
{
	id actor;
	SEL selector;
	id argument;
	id value;
	id nextFuture;
	BOOL done;
	NSMutableSet *waitingCoroutines;
	NSException *exception;
	NSError *error;
}

// private

@property (assign, nonatomic) id actor;
@property (assign, nonatomic) SEL selector;
@property (retain, nonatomic) id argument;
@property (retain, nonatomic) id value;
@property (retain, nonatomic) id nextFuture;
@property (retain, nonatomic) NSMutableSet *waitingCoroutines;
@property (retain, nonatomic) NSError *error;

- (void)append:(Future *)aFuture;
- (void)send;
- (void)setResult:(id)anObject;

// public

@property (retain, nonatomic) NSException *exception;

- result;


@end

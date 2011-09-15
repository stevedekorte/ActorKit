//
//  Mutex.h
//  ActorKit
//
//  Created by Steve Dekorte on 20110830.
//  Copyright 2011 Steve Dekorte. BSD licensed.



@interface Mutex : NSObject
{
	pthread_mutexattr_t mutexAttributes;
	pthread_mutex_t mutex;
	
	pthread_condattr_t conditionAttributes;
	pthread_cond_t condition;
	
	BOOL isPaused;
}

- (BOOL)isPaused;
- (void)pauseThread;
- (void)resumeAnyWaitingThreads;

@end

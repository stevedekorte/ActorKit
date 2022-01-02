//
//  Mutex.m
//  ActorKit
//
//  Copyright 2011 Steve Dekorte. BSD licensed.
//

#import "Mutex.h"
#import <pthread.h>

@implementation Mutex

- (id)init {
    self = [super init];
    
	if (self) 
	{
		pthread_mutexattr_init(&mutexAttributes);
		pthread_mutexattr_settype(&mutexAttributes, PTHREAD_MUTEX_RECURSIVE);
		pthread_mutex_init(&mutex, &mutexAttributes);
		
		pthread_condattr_init(&conditionAttributes);
		pthread_cond_init(&condition, &conditionAttributes);		
    }
    
    return self;
}

- (void)dealloc {
	pthread_mutexattr_destroy(&mutexAttributes);
	pthread_mutex_destroy(&mutex);
	pthread_cond_destroy(&condition);
	pthread_condattr_destroy(&conditionAttributes);
	[super dealloc];
}

- (BOOL)isPaused {
	return isPaused;
}

- (void)pauseThread {
    // have do be carefull about pauses and resumes mixing...
    
	pthread_mutex_lock(&mutex);
	isPaused = YES;
	
	while (isPaused) {
		pthread_cond_wait(&condition, &mutex);
	}
	
	pthread_mutex_unlock(&mutex);
}

- (void)resumeAnyWaitingThreads {	
	if (isPaused) {
		pthread_mutex_lock(&mutex);
		isPaused = NO;	
		pthread_cond_broadcast(&condition);
		pthread_mutex_unlock(&mutex);
	}
}

@end

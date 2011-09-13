//
//  Mutex.m
//  ActorKit
//
//  Created by Steve Dekorte on 20110830.
//  Copyright 2011 Steve Dekorte. BSD licensed.
//

#import "Mutex.h"
#import <pthread.h>

@implementation Mutex

- (id)init
{
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

- (void)dealloc
{
	pthread_mutexattr_destroy(&mutexAttributes);
	pthread_mutex_destroy(&mutex);
	pthread_cond_destroy(&condition);
	pthread_condattr_destroy(&conditionAttributes);
	[super dealloc];
}

/*
- (void)lock
{
    pthread_mutex_lock(&mutex);
}

- (void)unlock
{
    pthread_mutex_unlock(&mutex);
}

- (BOOL)tryLock
{
    return pthread_mutex_trylock(&mutex) == 0; // 0 means we got the lock
}
*/

- (BOOL)isPaused
{
	return isPaused;
}

- (void)pauseThread
{
	//printf("%p pauseThread\n", (void *)[NSThread currentThread]);
	
	isPaused = YES;
	pthread_mutex_lock(&mutex);
	while (isPaused) 
	{
		pthread_cond_wait( &condition, &mutex);
	}
	pthread_mutex_unlock(&mutex);
}

- (void)resumeThread
{
	//printf("%p resumeThread\n", (void *)[NSThread currentThread]);
	
	if(isPaused)
	{
		isPaused = NO;	
		pthread_mutex_lock(&mutex);
		pthread_cond_broadcast(&condition);
		pthread_mutex_unlock(&mutex);
	}
}

@end

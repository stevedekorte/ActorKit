# About

ActorKit is a lightweight (under 300 semicolons) framework for multithreaded actors with transparent futures in Objective-C.

## ActorProxy

Sending an "asActor" message to any object returns an actor proxy for the object.

Sending messages to the actor will queue them to be processed in first-in-first-out order by the actor's thread and immediately returns a "future" object.

If its message queue exceeds a given limit (set with setActorQueueLimit:), the calling threads that exceeded the limit will be paused until more of the queue is processed.

## FutureProxy

A future is a transparent proxy for the result which, when accessed before the result is ready, pauses any threads attempting to access it until it is ready. 	

Futures auto detect and raise an exception in deadlock situations.

### Example

```objc
// the fetch return a future immediately
NSData *aFuture = [(NSURL *)[[@"http://yahoo.com" asURL] asActor] fetch];

// ... do stuff ...

// now when we try to access the values, 
// the thread waits if the values aren't ready
NSLog(@"request returned %i bytes", (int)[aFuture length]); 
```

## ThreadSafeProxy

Calling asThreadSafe on any object returns a proxy that ensures only one thread can access it at a time. Example:

```objc
NSMutableDictionary *dict = [[NSMutableDictionary dictionary] asThreadSafe];
```

## BatchProxy

Calling asBatch on an NSArray returns a BatchProxy which can be used to do a parallel "map" using GCD (BSD workerqueues). Example:

```objc
NSArray *results = [[urls asBatch] fetch];
```

Sends concurrent fetch messages to each element of the urls array and returns an array containing the results.

## Dealing with Async Callbacks

To deal with async callbacks within an actor's thread, pauseThread and resumeThread can be used. Example:

```objc
__block id response = nil;
__block NSError *error = nil;
__block ActorProxy *actor = [ActorProxy currentActorProxy];

request = [s3Client getBucket:bucketName
    success:^(id responseObject) 
    {
        response = responseObject;
        [actor resumeThread];	
    }
    failure:^(NSError *e)
    {
        error = e;
        [actor resumeThread];
    }
];
                   
id returnValue = [[ActorProxy currentActorProxy] pauseThread];

if(error)
{
    [NSException raise:@"SyncKitError" format:[error description]];
}
```

Also, if the thread is resumed using resumeThreadWithValue:, the pauseThread method will return the given value. 

## Notes

- Exceptions that occur while an actor processes a message will be passed to the future and raised in all the threads that attempt to access the future.
- It's ok for multiple threads to look at the same future. 
- ActorKit does no busy waits.
- Objects store their proxies as an associated objects so the same proxy is returned for a given instance.

## To Do

- handle BatchProxy exceptions
- make sure all locks deal with exceptions
- future notifications of some kind
- more tests
- auto deadlock detection for actor queue limit and batches
- add a total queue and/or total actor limits
- better respondsToSelector implementation
- (maybe) chainable persistent batch groups with in, out, and error queues
- (maybe) integrate with distibuted objects to allow bundles and data to be distributed...
- (maybe) explore synchronization via ownership 

## Credits

Thanks to Mark Papadakis for tips on mutex conditions.
IIRC I saw the BatchProxy pattern first used in Io by quag.

If you use this project, please drop me a line and let me know if you found it useful. Thanks.

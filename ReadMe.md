# ActorKit Documentation

## About

ActorKit is a lightweight framework (under 300 semicolons) for multithreaded actors with transparent futures in Objective-C.

## ActorProxy

Sending an `asActor` message to any object returns an actor proxy for that object.

Messages sent to the actor are queued and processed in first-in-first-out order by the actor's thread. Each message immediately returns a "future" object.

If the message queue exceeds a given limit (set with `setActorQueueLimit:`), calling threads that exceed the limit will pause until more of the queue is processed.

## FutureProxy

A future is a transparent proxy for a result. When accessed before the result is ready, it pauses any threads attempting to access it until the result becomes available.

Futures automatically detect and raise exceptions in deadlock situations.

### Example

```objc
// The fetch returns a future immediately
NSData *aFuture = [(NSURL *)[[@"http://example.com" asURL] asActor] fetch];

// ... do other work ...

// When we access the values, the thread waits if they aren't ready
NSLog(@"Request returned %i bytes", (int)[aFuture length]); 
```

## ThreadSafeProxy

Calling `asThreadSafe` on any object returns a proxy that ensures only one thread can access it at a time.

Example:

```objc
NSMutableDictionary *dict = [[NSMutableDictionary dictionary] asThreadSafe];
```

## BatchProxy

Calling `asBatch` on an NSArray returns a BatchProxy, which can be used for parallel "map" operations using GCD (BSD worker queues).

Example:

```objc
NSArray *results = [[urls asBatch] fetch];
```

This sends concurrent `fetch` messages to each element of the `urls` array and returns an array containing the results.

## Dealing with Async Callbacks

To handle asynchronous callbacks within an actor's thread, use `pauseThread` and `resumeThread`. 

Example:

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

if (error)
{
    [NSException raise:@"SyncKitError" format:[error description]];
}
```

If the thread is resumed using `resumeThreadWithValue:`, the `pauseThread` method will return the given value.

## Notes

- Exceptions that occur while an actor processes a message are passed to the future and raised in all threads that attempt to access the future.
- Multiple threads can safely access the same future.
- ActorKit does not use busy waits.
- Objects store their proxies as associated objects, ensuring the same proxy is returned for a given instance.

## To Do

- Handle BatchProxy exceptions
- Ensure all locks deal with exceptions
- Implement future notifications
- Add more tests
- Implement auto deadlock detection for actor queue limit and batches
- Add total queue and/or total actor limits
- Improve `respondsToSelector` implementation
- (Maybe) Implement chainable persistent batch groups with in, out, and error queues
- (Maybe) Integrate with distributed objects to allow bundle and data distribution
- (Maybe) Explore synchronization via ownership

## Credits

Thanks to Mark Papadakis for tips on mutex conditions.

The BatchProxy pattern was first observed in the Io language, implemented by quag.

If you use this project, please let us know if you found it useful. Your feedback is appreciated!
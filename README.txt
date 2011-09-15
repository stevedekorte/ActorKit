

About

	ActorKit is a framework for multithreaded actors with transparent futures in Objective-C.


ActorProxy
	
	Sending an "asActor" message to any object returns an actor proxy for the object.
	
	Sending messages to the actor will queue them to be processed in first-in-first-out order 
	by the actor's thread and immediately returns a "future" object.
	
	When it's message queue reaches that limit (settable with setActorQueueLimit:), 
	calling threads will be paused. 



FutureProxy

	A future is a transparent proxy for the result which, when accessed before the 
	result is ready, will pauses calling threads until it is ready. 	
		
	Futures auto detect and raise an exception in deadlock situations.
	
	Example

	// these spawn threads for each actor to and return immediately

	NSData *aFuture = [(NSURL *)[[@"http://yahoo.com" asURL] asActor] fetch];

	// ... do stuff that doesn't need to wait on the results ...
	
	// now when we try to access the values, they block if the values aren't ready

	NSLog(@"request returned %i bytes", (int)[aFuture length]); 



SyncProxy

	Calling asSynchronous on any object returns a SyncProxy for it. Example:

	NSMutableDictionary *dict = [[NSMutableDictionary dictionary] asSynchronous];

	You now have a thread safe dictionary.



BatchProxy

	Calling asBatch on an NSArray returns a BatchProxy which can be used to do
	a parallel "map" using GCD (BSD workerqueues). Example:

	NSArray *results = [[urls asBatch] fetch];

		
	
Notes

	Exceptions that occur while an actor processes a message will be
	passed to the future and raised in all the threads that attempt to access the future.
	
	It's ok for multiple threads to look at the same future. 
	  
	ActorKit does no busy waits.
	
	Objects store their proxies as an associated objects so the same 
	proxy is returned for an instance.
	


To Do

	- handle BatchProxy exceptions
	
	- extend collection classes to use workqueues for makeObjectsPerform: etc
	
	- future notifications of some kind

	- tests
	
	- convenience methods for returning NSNumbers instead of C types

	- convenience methods for performing blocking ops via single calls to instance methods
	
	- auto deadlock detection for actor queue limit, synchronous and batches
	
	- add a total queue and/or total actor limits
	
	- better respondsToSelector implementation
	
	- chainable batch groups with in, out, and error queues



Credits

	Thanks to Mark Papadakis for tips on mutex conditions.
	IIRC I saw the BatchProxy pattern first used in Io by quag.
	
	
	


About

	ActorKit is a framework supporting multithreaded actors with transparent futures in Objective-C.


ActorProxy and FutureProxy
	
	Sending an "asActor" message to any object returns an actor proxy for the object.

	Each actor spawns an os thread to process it's queue of messages. 
	
	Sending messages to the actor will queue them to be processed in first-in-first-out order 
	by the actor's thread and immediately returns a "future" object.
	
	A future is a proxy for the result. If it is accessed before the result is ready, it
	pauses any calling threads until it is ready. After it is ready, it acts as a transparent
	proxy for the result, passing messages to the result as if the future were the same object.
		
	Futures detect and raise an exception in situations where pausing the calling thread 
	would cause a deadlock.
	
	An actor's queue limit can be set with the setActorQueueLimit: method.
	When it's message queue reaches that limit, calling threads will be paused. 
	This is an automatic way of avoiding excessive spawning of actors.


	Example

	// these spawn threads for each actor to and return immediately

	NSData *future1 = [(NSURL *)[[NSURL URLWithString:@"http://yahoo.com"] asActor] fetch];
	NSData *future2 = [(NSURL *)[[NSURL URLWithString:@"http://google.com"] asActor] fetch];

	// ... do stuff that doesn't need to wait on the results ...
	
	// now when we try to access the values, they block if the values aren't ready

	NSLog(@"request 1 returned %i bytes", (int)[future1 length]); 
	NSLog(@"request 2 returned %i bytes", (int)[future2 length]);

	// We just did a safe, coordinated interaction between three threads 
	// by only adding two tokens and with no state machines or callbacks

	// you'll need to add this method for the above example because 
	// dataWithContentsOfURL: is a class method but actors have to be instances
 
	@implementation NSURL (fetch)
	- (NSData *)fetch { return [NSData dataWithContentsOfURL:self]; }
	@end



SyncProxy

	Calling asSynchronous on any object returns a SyncProxy for it. Example:

	NSMutableDictionary *dict = [[NSMutableDictionary dictionary] asSynchronous];

	Now message sends from all threads to dict will be locked such that only one 
	thread can access it at a time.



BatchProxy

	Calling batch on an NSArray returns a BatchProxy which can be used to do
	a parallel "map" using GCD (BSD workerqueues). Example:

	NSArray *results = [[urls asBatch] fetch];

	You can also combine asSynchronous and asBatch to get the type of synchronization
	and parallelism that suits your problem.

		
	
Notes

	Exceptions that occur while an actor processes a message will be
	passed to the future and raised in all the threads that attempt to access the future.
	
	It's ok for multiple threads to look at the same future. 
	Each will block until the future is ready.
	  
	All blocking is done by pausing/resuming the requesting thread.
	ActorKit does no busy waits.
	
	When an actor finishes processing it's message queue, it's thread
	is paused until a new message is added to the queue.
	
	Objects store their actor proxies as an associated object so the same 
	actor is returned for multiple calls of asActor on the same instance.
	


To Do

	- extend collection classes to use workqueues for makeObjectsPerform: etc
	
	- future notifications of some kind

	- tests
	
	- convenience methods for returning NSNumbers instead of C types

	- convenience methods for performing blocking ops via single calls to instance methods
	
	- deadlock detection for actor queue limit, synchronous and batches
	
	- add a total queue and/or total actor limits
	
	- better respondsToSelector implementation



Credits

	Thanks to Mark Papadakis for tips on mutex conditions.
	IIRC I saw the BatchProxy pattern first used in Io by quag.
	
	
	
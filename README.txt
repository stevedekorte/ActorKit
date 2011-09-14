

About:

	ActorKit is a framework supporting multithreaded actors with transparent futures in Objective-C.

	Sending an "asActor" message to any object returns an actor proxy for the object.

	Each actor spawns an os thread to process it's queue of messages. 
	
	Sending messages to the actor will queue them to be processed in first-in-first-out order 
	by the actor's thread and immediately returns a "future" object.
	
	A future is a proxy for the result. If it is accessed before the result is ready, it
	pauses any calling threads until it is ready. After it is ready, it acts as a transparent
	proxy for the result, passing messages to the result as if the future were the same object.
		
	Futures detect and raise an exception in situations where pausing the calling thread 
	would cause a deadlock.



Example:

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
	- (NSData *)fetch:sender { return [NSData dataWithContentsOfURL:self]; }
	@end
	
	
	
Notes:

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
	
	
	
SyncProxy

	As an extra feature, NSObject is also extended to have a asSynchronous method.
	Calling it will return a proxy to the object which will ensure that only one thread
	can message the object at a time. This allows any Objective-C class to be used
	in a thread safe way. This does no checks for deadlocks and may not be optimal 
	in performance, but it is an convenient way to get object level thread safety.
	
	
Example:

	// just call asSynchronous to get the proxy
	
	NSMutableDictionary *dict = [[NSMutableDictionary dictionary] asSynchronous];
	
	// now message sends from all threads to dict will be locked such that only one 
	// thread can access it at a time. Again, this does not use busy waits.
	
	

Credits:

	Thanks to Mark Papadakis for help me figure out how to properly use mutex conditions.
	
	
	
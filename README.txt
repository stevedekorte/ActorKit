
About:

	ActorKit allows any object to become an actor. 

	Each actor has an os thread and a queue of incoming messages which it processes in 
	first-in-first-out order.

	Any message to an actor returns a "future" object which is a proxy for the result
	and only blocks when it is accessed if the result isn't ready.
	
	Futures detect and raise an exception in situations that would cause a deadlock.


Example:

	// these spawn threads for each actor to and return immediately
	
	NSData *future1 = [(NSURL *)[[NSURL URLWithString:@"http://yahoo.com"] asActor] fetch];
	NSData *future2 = [(NSURL *)[[NSURL URLWithString:@"http://google.com"] asActor] fetch];
	
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

	It's ok for multiple threads to look at the same future. 
	Each will block until the future is ready.
	  
	All blocks are done by pausing/resuming the requesting thread.
	ActorKit does no busy waits.
	
	

Credits:

	Thanks to Mark Papadakis for help with figuring out how to properly use mutex conditions.
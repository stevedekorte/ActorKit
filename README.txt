
About:

	ActorKit extends NSObject to allow all objects to become actors. 

	Each actor has an os thread and a queue of incoming messages which it processes in 
	first-in-first-out order.

	Any message to an actor returns a "future" object which only blocks when it is accessed. 
	Futures detect and raise an exception in situations that would cause a deadlock.

Example:

	// look ma, no state machines or callbacks
	// these spawn threads to and return immediately
	
	NSData *future1 = [(NSURL *)[[NSURL URLWithString:@"http://yahoo.com"] asActor] fetch];
	NSData *future2 = [(NSURL *)[[NSURL URLWithString:@"http://google.com"] asActor] fetch];
	
	// now when we try to access the values, they block if the values aren't ready
	
	NSLog(@"request 1 returned %i bytes", (int)[future1 length]); 
	NSLog(@"request 2 returned %i bytes", (int)[future2 length]);

	// We just did a coordinated interaction between 3 threads without  
	// lots of incomprehensible, bug prone code and by only adding two tokens?
	// neat huh?

Notes:

	// you'll need to add this method for the above example because 
	// dataWithContentsOfURL: is a class method but actors have to be instances
 
	@implementation NSURL (fetch)
	- (NSData *)fetch:sender { return [NSData dataWithContentsOfURL:self]; }
	@end

Credits:

	Thanks to Mark Papadakis for help with figuring out how to properly use mutex conditions.
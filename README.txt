
ActorKit extends NSObject to allow all objects to become actors. An actor has an os thread and a queue of incoming messages which it processes in first-in-first-out order. A message to the actor can also return a "future" object which only blocks when the result is requested and is not yet ready and this is done without busy waits. Futures also support automatic deadlock avoidance by checking for deadlock loops when a result is requested.

example:

	// look ma, no state machine or callbacks - these spawn threads and return immediately
	
	NSURL *future1 = [[NSURL URLWithString:@"http://yahoo.com"] asActor];
	NSURL *future2 = [[NSURL URLWithString:@"http://google.com"] asActor];
	
	// now when we try to access the values, they block if the values aren't ready
	
	NSLog(@"request 1 returned %i bytes", (int)[future1 length]); 
	NSLog(@"request 2 returned %i bytes", (int)[future2 length]);


note:

	// you'll beed to add this method because dataWithContentsOfURL: is a class method but actors have to be instances
 
	@implementation NSURL (fetch)
	- (NSData *)fetch:sender { return [NSData dataWithContentsOfURL:self]; }
	@end

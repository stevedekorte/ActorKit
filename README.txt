
ActorKit extends NSObject to allow all objects to become coroutine based actors where an actor has a cooperative thread and a queue of incoming messages which it processes in first-in-first-out order. A message to the actor can also return a "future" object which only blocks when the result is requested and is not yet ready, automatically minizing blocking time or busy waits. Futures also support automatic deadlock avoidance by checking for deadlock loops when a result is requested.

Simple example of using a future:

  // this returns immediately

  Future *future = [NSURLConnection futurePerformSelector:@selector(sendRequest:) withObject:request];

  // ...later, when we need the result, [future result] blocks if the result is not yet ready

  NSDictionary *result = [future result];
  NSData *data = [result objectForKey:@"data"];

Note that if you did this from the main thread, only made one request, and asked for the result right away, it would no different than doing a normal synchronous NSURLConnection request. To get more concurrency, we need to perform our requests from another actor's thread, so the main thread can return. While there are active actors, the main thread will have a timer that periodically calls back in and allows all the active actors to have a chance to process their next message.

See the [forthcoming] text code for an example of how to do that.


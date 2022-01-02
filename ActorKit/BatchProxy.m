//
//  NSObject+Actor.m
//  ActorKit
//
//  Copyright 2011 Steve Dekorte. BSD licensed.
//

#import "BatchProxy.h"
#import "NSInvocation+Copy.h"

@implementation BatchProxy

@synthesize batchTarget;

- init {
    //self = [super init]; // NSProxy doesn't implement init
	return self;
}

- (void)dealloc {
	[self setBatchTarget:nil];
	[super dealloc];
}

- (void)setProxyTarget:anObject {
	[self setBatchTarget:anObject];
}

- (BOOL)respondsToSelector:(SEL)aSelector {
	return YES;
}

- (dispatch_queue_t)batchDispatchQueue {
	return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
}

- (void)forwardInvocation:(NSInvocation *)theInvocation {
	__block NSInvocation *anInvocation = theInvocation;
	
	if ([[anInvocation methodSignature] methodReturnType][0] != '@') {
		NSString *msg = [NSString stringWithFormat:@"sent '%@' but only methods that return objects are supported",
						 NSStringFromSelector([anInvocation selector])];
		NSLog(@"BatchProxy ERROR: %@", msg);
		[NSException raise:@"BatchProxy" format:@"%@", msg];
	}
	
	[anInvocation retain]; // uh, why?
	[anInvocation retainArguments];

	NSInteger length = [batchTarget count];
	__block id *results = calloc(0, sizeof(id) * length);
	
	// use an invocation pool?
	
	dispatch_apply(length, [self batchDispatchQueue], ^(size_t i) {
			//printf("start %i\n", (int)i);
			id item = [batchTarget objectAtIndex:i];
			NSInvocation *copyInvocation = [anInvocation copy];
			[copyInvocation retain];
			[copyInvocation invokeWithTarget:item];
			
			id r;
			[copyInvocation getReturnValue:&r];
			results[i] = r;
			[copyInvocation release]; // ?
			//printf("end %i\n", (int)i);
		}
	);

	NSMutableArray *resultsArray = [NSMutableArray 
									arrayWithObjects:results count:length];

	free(results); //NSArray docs don't mention who owns the memory, so assume it's a copy
	
	[anInvocation setReturnValue:(void *)&resultsArray];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
	if ([batchTarget count]) {
		id firstObject = [batchTarget objectAtIndex:0];
		NSMethodSignature *sig =  [firstObject methodSignatureForSelector:aSelector];
		return sig;
	}
	
	return nil;
}

@end

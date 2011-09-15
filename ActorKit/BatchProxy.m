//
//  NSObject+Actor.m
//  ActorKit
//
//  Created by Steve Dekorte on 20110831.
//  Copyright 2011 Steve Dekorte. BSD licensed.
//

#import "BatchProxy.h"
#import "NSInvocation+Copy.h"

@implementation BatchProxy

@synthesize batchTarget;

- init
{
    //self = [super init]; // NSProxy doesn't implement init
	return self;
}

- (void)dealloc
{
	
	[super dealloc];
}

- (void)setProxyTarget:anObject
{
	[self setBatchTarget:anObject];
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
	return YES;
}

- (dispatch_queue_t)batchDispatchQueue
{
	return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
	if([[anInvocation methodSignature] methodReturnType][0] != '@')
	{
		[NSException raise:@"BatchProxy" format:
		 [NSString stringWithFormat:@"sent '%@' but only methods that return objects are supported", 
		  NSStringFromSelector([anInvocation selector])]];
	}
	
	NSInteger length = [batchTarget length];
	id *results = calloc(0, sizeof(id) * length);
	
	[anInvocation retainArguments];
		
	dispatch_apply(length, [self batchDispatchQueue], 
		^(size_t i)
		{
			id item = [batchTarget objectAtIndex:i];
			NSInvocation *copyInvocation = [anInvocation copy];
			[copyInvocation invokeWithTarget:item];
			
			id r;
			[copyInvocation getReturnValue:&r];
			results[i] = r;
		}
	);

	NSMutableArray *resultsArray = [NSMutableArray arrayWithCapacity:length];
	
	for(size_t i = 0; i < length; i ++)
	{
		[resultsArray addObject:results[i]];
	}
	
	[anInvocation setReturnValue:(void *)&resultsArray];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
	return [batchTarget methodSignatureForSelector:aSelector];
}

@end

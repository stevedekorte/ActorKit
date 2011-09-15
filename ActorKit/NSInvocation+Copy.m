//
//  NSObject+Actor.m
//  ActorKit
//
//  Created by Steve Dekorte on 20110831.
//  Copyright 2011 Steve Dekorte. BSD licensed.
//

#import "NSInvocation+Copy.h"


@implementation NSInvocation (NSInvocation_Copy)

- (id)copy
{
	NSInvocation *copy = [NSInvocation invocationWithMethodSignature:[self methodSignature]];
	[copy setTarget:[self target]];
	[copy setSelector:[self selector]];
	char buffer[sizeof(intmax_t)]; 
	
	NSUInteger argCount = [[self methodSignature] numberOfArguments];
	
	for (int i = 0; i < argCount; i++)
	{
		[self getArgument:(void *)&buffer atIndex:i];
		[copy setArgument:(void *)&buffer atIndex:i];
	}
	
	return copy;
}

@end

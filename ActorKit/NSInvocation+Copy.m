//
//  NSObject+Actor.m
//  ActorKit
//
//  Copyright 2011 Steve Dekorte. BSD licensed.
//

#import "NSInvocation+Copy.h"

@implementation NSInvocation (NSInvocation_Copy)

- (id)copy
{
	NSInvocation *copy = [NSInvocation invocationWithMethodSignature:[self methodSignature]];
	NSUInteger argCount = [[self methodSignature] numberOfArguments];
	
	for (int i = 0; i < argCount; i++) {
		char buffer[sizeof(intmax_t)]; 
		[self getArgument:(void *)&buffer atIndex:i];
		[copy setArgument:(void *)&buffer atIndex:i];
	}
		
	return copy;
}

@end

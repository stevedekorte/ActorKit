//
//  NSObject+Actor.m
//  ActorKit
//
//  Copyright 2011 Steve Dekorte. BSD licensed.
//

#import "BatchProxy.h"
#import "NSObject+Actor.h"

@implementation NSArray (NSArray_Actor)

- asBatch
{
	return [self proxyForProxyClass:[BatchProxy class]];
}

@end

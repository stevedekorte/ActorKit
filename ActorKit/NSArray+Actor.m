//
//  NSObject+Actor.m
//  ActorKit
//
//  Created by Steve Dekorte on 20110831.
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

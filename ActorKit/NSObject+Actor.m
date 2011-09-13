//
//  NSObject+Actor.m
//  ActorKit
//
//  Created by Steve Dekorte on 20110831.
//  Copyright 2011 Steve Dekorte. BSD licensed.
//

#import "NSObject+Actor.h"
//#import <objc/runtime.h>

@implementation NSObject (NSObject_Actor)

- (ActorProxy *)asActor
{
	ActorProxy *ap = [[[ActorProxy alloc] init] autorelease];
	[ap setActorTarget:self];
	return ap;
}


@end

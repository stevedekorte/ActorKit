//
//  NSObject+Actor.h
//  ActorKit
//
//  Created by Steve Dekorte on 20110831.
//  Copyright 2011 Steve Dekorte. BSD licensed.
//

@interface BatchProxy : NSProxy
{
	// using the "batch" prefix to avoid name conflict with proxied object
	
	id batchTarget;

}

// private

@property (retain, atomic) id batchTarget;

- (void)setProxyTarget:anObject;


@end

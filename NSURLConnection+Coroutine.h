//
//  NSURLConnection+Future.h
//  ActorKit
//
//  Created by Steve Dekorte on 20110831.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//



@interface NSURLConnection (NSURLConnection_Coroutine)

+ (NSDictionary *)sendRequest:(NSURLRequest *)request;

@end

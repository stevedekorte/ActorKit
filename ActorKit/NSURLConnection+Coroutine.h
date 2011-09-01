//
//  NSURLConnection+Future.h
//  ActorKit
//
//  Created by Steve Dekorte on 20110831.
//  Copyright 2011 Steve Dekorte. BSD licensed.
//



@interface NSURLConnection (NSURLConnection_Coroutine)

+ (NSDictionary *)sendRequest:(NSURLRequest *)request;

@end

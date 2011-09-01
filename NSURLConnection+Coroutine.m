//
//  NSURLConnection+Future.m
//  ActorKit
//
//  Created by Steve Dekorte on 20110831.
//  Copyright 2011 Steve Dekorte. BSD licensed.
//

#import "NSURLConnection+Coroutine.h"
#import "Coroutine.h"

@implementation NSURLConnection (NSURLConnection_Coroutine)

+ (NSDictionary *)sendRequest:(NSURLRequest *)request
{
	Coroutine *coroutine = [Coroutine currentCoroutine];
	__block NSURLResponse *theResponse = nil;
	__block NSData *theData = nil;
	__block NSError *theError = nil;
	
	[NSURLConnection sendAsynchronousRequest:request 
									   queue:[NSOperationQueue mainQueue]
						   completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
						   { 
							   theResponse = response;
							   theData = data;
							   theError = error;
							   [coroutine scheduleLast];
						   }];
	
	[coroutine unschedule]; // pauses coroutine until completionHandler resumes it
	
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	[dict setObject:theResponse		forKey:@"response"];
	[dict setObject:theData			forKey:@"data"];
	[dict setObject:theError		forKey:@"error"];
	return dict;
}
	 
@end

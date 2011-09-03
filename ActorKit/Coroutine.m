//
//  Coroutine.m
//  CoroutineKit
//
//  Created by Steve Dekorte on 20110830.
//  Copyright 2011 Steve Dekorte. BSD licensed.

#import "Coroutine.h"

@implementation Coroutine

static Coroutine *mainCoroutine    = nil;
static Coroutine *currentCoroutine = nil;

@synthesize target;
@synthesize action;
@synthesize hasStarted;
@synthesize next;
@synthesize previous;
@synthesize waitingOnFuture;
@synthesize name;

static long activeCoroutineCount = 0;
static NSTimer *activeCoroutineTimer = nil;

+ (void)incrementActiveCoroutineCount
{
	activeCoroutineCount ++;
	
	if(!activeCoroutineTimer)
	{
		activeCoroutineTimer = [NSTimer timerWithTimeInterval:1.0/30.0 
															target:mainCoroutine 
															selector:@selector(timer:)
															userInfo:nil
															repeats:YES];
		[activeCoroutineTimer retain];
	}
	
	if([activeCoroutineTimer isValid])
	{
		[activeCoroutineTimer fire];
	}
}
							
+ (void)decrementActiveCoroutineCount
{
	activeCoroutineCount --;
	
	if(activeCoroutineCount == 0 && [activeCoroutineTimer isValid])
	{
		[activeCoroutineTimer invalidate];
	}
}

- (void)timer:userInfo
{
	[mainCoroutine yield];
}

- (Coro *)coro
{
	return coro;
}

+ (Coroutine *)currentCoroutine
{
	return currentCoroutine;
}

+ (Coroutine *)mainCoroutine
{
	if(!mainCoroutine)
	{
		mainCoroutine = [[Coroutine alloc] initAsMain];
		currentCoroutine = mainCoroutine;
	}
	
	return mainCoroutine;
}

- (id)initAsMain
{
    self = [super init];
	
    if (self) 
	{
		coro = Coro_new();
		Coro_initializeMainCoro(coro);
		hasStarted = YES;		
		[self setNext:self];
		[self setPrevious:self];
		[self setName:@"MainCoroutine"];
    }
	
    return self;
}

- (id)init
{
    self = [super init];
	
    if (self) 
	{
		coro = Coro_new();
		[self setName:@"unnamed"];
		[Coroutine mainCoroutine];
    }
	
    [[self class] incrementActiveCoroutineCount];
    return self;
}

- (void)dealloc
{
    [[self class] decrementActiveCoroutineCount];
	[self setTarget:nil]; // just to cleanup
	[self setNext:nil]; // just to cleanup
	[self setPrevious:nil]; // just to cleanup
	[self setName:nil];
	Coro_free(coro);
	[super dealloc];
}

- (size_t)stackSize
{
	return Coro_stackSize(coro);
}

- (void)setStackSize:(size_t)size
{
	Coro_setStackSize_(coro, size);
}

- (size_t)bytesLeftOnStack
{
	return Coro_bytesLeftOnStack(coro);
}

//typedef void (CoroStartCallback)(void *);

- (void)startup
{
	[target performSelector:action];
}

static void callback(void *aCoroutine)
{
	Coroutine *self = (Coroutine *)aCoroutine;
	[self startup];
}

- (void)start 
{
	#ifdef COROUTINE_DEBUG
		printf("%s start\n", [[self nameId] UTF8String]);
	#endif
	
	if(!hasStarted)
	{
		hasStarted = YES;		
		Coroutine *lastCoroutine = currentCoroutine;
		currentCoroutine = self;
		Coro_startCoro_([lastCoroutine coro], [self coro], (void *)self, callback);
	}
	else
	{
		[NSException raise:@"Coroutine" format:@"attempt to start a Coroutine twice"];
	}
}

- (void)resume
{

	if(!hasStarted)
	{
		[self start];
	}
	else
	{
#ifdef COROUTINE_DEBUG
		printf("%s resume\n", [[self nameId] UTF8String]);
#endif
		Coroutine *lastCoroutine = currentCoroutine;
		currentCoroutine = self;
		Coro_switchTo_([lastCoroutine coro], [self coro]);
	}
}

- (void)remove
{
	Coroutine *n = next;
	Coroutine *p = previous;
	
	[p setNext:n];
	[n setPrevious:p];
	
	[self setNext:nil];
	[self setPrevious:nil];
}

- (void)checkLinkedList
{
	if(next == nil)
	{
		[NSException raise:@"Coroutine" format:@"missing next"];
	}
	
	if(previous == nil)
	{
		[NSException raise:@"Coroutine" format:@"missing previous"];
	}	
}

- (void)insertFirst:(Coroutine *)aCoroutine
{
#ifdef COROUTINE_DEBUG
	[self checkLinkedList];
	printf("%s insertFirst: %s\n", [[self nameId] UTF8String], [[aCoroutine nameId] UTF8String]);
#endif

	if(aCoroutine == self) 
	{
		return;
	}

	Coroutine *n = next;
	//Coroutine *p = previous;
		
	[aCoroutine remove];
	[aCoroutine setNext:n];
	[aCoroutine setPrevious:self];	
	[n setPrevious:aCoroutine];
	[self setNext:aCoroutine];
	
#ifdef COROUTINE_DEBUG
	[self showCoroutineList];
#endif
}

- (void)insertLast:(Coroutine *)aCoroutine
{
#ifdef COROUTINE_DEBUG
	[self checkLinkedList];
	printf("%s insertLast: %s\n", [[self nameId] UTF8String], [[aCoroutine nameId] UTF8String]);
#endif
	if(aCoroutine == self) 
	{
		return;
	}
	

	[aCoroutine remove];

	//Coroutine *n = next;
	Coroutine *p = previous;
	[self setPrevious:aCoroutine];
	
	[aCoroutine setNext:self];
	[aCoroutine setPrevious:p];	
	[p setNext:aCoroutine];

#ifdef COROUTINE_DEBUG
	[self showCoroutineList];
	printf("done insertLast\n");
#endif
}

- (void)scheduleFirst
{
#ifdef COROUTINE_DEBUG
	printf("%s scheduleFirst\n", [[self nameId] UTF8String]);
#endif
	[currentCoroutine insertFirst:self];
}

- (void)scheduleLast
{
#ifdef COROUTINE_DEBUG
	printf("%s scheduleLast\n", [[self nameId] UTF8String]);
#endif
	[currentCoroutine insertLast:self];
}

- (void)yield
{
#ifdef COROUTINE_DEBUG
	printf("%s yield\n", [[self nameId] UTF8String]);
#endif
	if(currentCoroutine == self)
	{
		return;
	}
	
	[[currentCoroutine next] resume];
}

- (void)unschedule
{
	if(currentCoroutine == self)
	{
		/*
		if(currentCoroutine == mainCoroutine)
		{
			// yield 
			[NSException raise:@"Coroutine" format:@"attempt to unschedule main coroutine"];
			return;
		}
		*/
		
#ifdef COROUTINE_DEBUG
		printf("%s unschedule current\n", [[self nameId] UTF8String]);
#endif		
		Coroutine *nextCoroutine = [self next];
		
		if(nextCoroutine != currentCoroutine)
		{
			[self remove];
			[nextCoroutine resume];
		}
		else
		{
			printf("only one coroutine, so resuming instead of unscheduling it!\n");
		}
	}
	else
	{
#ifdef COROUTINE_DEBUG
		printf("%s unschedule non-current\n", [[self nameId] UTF8String]);
#endif
		[self remove];
	}
}

- (NSString *)nameId
{
	return [self name];
	//return [NSString stringWithFormat:@"Coroutine-%@-%p", [self name], (void *)self];
}

- (void)showCoroutineListUntil:aCoroutine
{
#ifdef COROUTINE_DEBUG
	printf("  %s\n", [[self nameId] UTF8String]);
#endif

	if(next == aCoroutine) 
	{
		return;
	}
	
	[next showCoroutineListUntil:aCoroutine];
}

- (void)showCoroutineList
{
	printf("Coroutine list:\n");
	[self showCoroutineListUntil:self];
	printf("\n");
}

@end

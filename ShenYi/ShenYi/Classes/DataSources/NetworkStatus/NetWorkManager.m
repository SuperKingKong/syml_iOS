//
//  NetWorkManager.m
//  Constellation
//
//  Created by fang yuxi on 10-12-6.
//  Copyright 2010 我酷. All rights reserved.
//

#import "NetWorkManager.h"

#pragma mark private
#pragma ---

@interface NetWorkManager(private)

- (void)reachabilityChanged:(NSNotification *)note; 

/*+ (NetworkStatus) checkNowNetWorkStatus;*/
- (NetworkStatus) checkNowNetWorkStatus;
@end

#pragma mark implementation NetWorkManager
#pragma ---

@implementation NetWorkManager

@synthesize delegate = _delegate;
@synthesize netWorkIsEnabled = _netWorkIsEnabled;
@synthesize witchNetWorkEnabled = _witchNetWorkEnabled;

static NetWorkManager* defaultManager = nil;

#pragma mark init & dealloc
#pragma ---

+ (NetWorkManager*) sharedManager
{
	if (!defaultManager)
	{
		defaultManager = [[NetWorkManager alloc] init];
	}
	return defaultManager;
}

+ (id) allocWithZone:(NSZone *)zone
{
	@synchronized(self)
	{
		if (defaultManager == nil)
		{ 
			defaultManager = [super allocWithZone:zone];
			return defaultManager;
		}
	}
	return nil;
}

- (void) dealloc
{
	[super dealloc];
}

#pragma mark checkNowNetWorkStatus
#pragma ---
/* 改为实例方法。by haydn li 4月10日
+ (NetworkStatus) checkNowNetWorkStatus
{
	SReachability *r = [SReachability reachabilityWithHostName:@"www.baidu.com"];
	return [r currentReachabilityStatus];
}
*/
- (NetworkStatus) checkNowNetWorkStatus
{
    return [rech currentReachabilityStatus];   
}
#pragma mark start and stop watch net
#pragma ---

- (Boolean) startNetWorkWatch
{
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(reachabilityChanged:)
												 name: kReachabilityChangedNotification
											   object: nil];
    if (nil == rech) {
        //rech = [[SReachability reachabilityWithHostName:@"www.baidu.com"] retain];        
        rech = [[SReachability reachabilityForLocalWiFi] retain]; 
    }

	Boolean finish = [rech startNotifier];
	return finish;
}

- (void) stopNetWorkWatch
{
	[rech stopNotifier];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
    
	[defaultManager release];
	defaultManager = nil;
}

#pragma mark private callback
#pragma ---

- (void)reachabilityChanged:(NSNotification *)note 
{
	SReachability* curReach = [note object];
	NetworkStatus status = [curReach currentReachabilityStatus];
    
    //_witchNetWorkEnabled = status;
	//网络将要发生变化
    if ([(NSObject*)self.delegate respondsToSelector:@selector(netWorkStatusWillChange:)])
    {
        [self.delegate netWorkStatusWillChange:status];
    }
	
	//代理的可选方法
	switch (status)
	{
		case NotReachable:
		{
			//网络不可达
			_netWorkIsEnabled = NO;
			_witchNetWorkEnabled = NotReachable;
			
			if ([(NSObject*)self.delegate respondsToSelector:@selector(netWorkStatusWillDisconnection)])
			{
				[self.delegate netWorkStatusWillDisconnection];
			}
		}
            break;
		case ReachableViaWiFi:
		{
			//网络可达
			_netWorkIsEnabled = YES;
			_witchNetWorkEnabled = ReachableViaWiFi;
			
			if ([(NSObject*)self.delegate respondsToSelector:@selector(netWorkStatusWillEnabledViaWifi)])
			{
				[self.delegate netWorkStatusWillEnabledViaWifi];
			}
		}
            break;
		case ReachableViaWWAN:
		{
			//网络可达
			_netWorkIsEnabled = YES;
			_witchNetWorkEnabled = ReachableViaWWAN;
			
			if ([(NSObject*)self.delegate respondsToSelector:@selector(netWorkStatusWillEnabledViaWWAN)])
			{
				[self.delegate netWorkStatusWillEnabledViaWWAN];
			}
		}
            break;
		default:
			break;
	}
}

#pragma mark overwirte getter
#pragma ---

- (Boolean) netWorkIsEnabled
{
    return !([self checkNowNetWorkStatus] == NotReachable);
}

- (NetworkStatus) witchNetWorkEnabled
{
    return  [self checkNowNetWorkStatus];
}

- (void) activePost
{
    rech = [[SReachability reachabilityWithHostName:@"www.baidu.com"] retain];
	[rech startNotifier];
}
@end

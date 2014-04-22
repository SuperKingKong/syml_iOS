//
//  NetWorkManager.h
//  Constellation
//
//  Created by fang yuxi on 10-12-6.
//  Copyright 2010 我酷. All rights reserved.

#import <Foundation/Foundation.h>
#import "SReachability.h"

#pragma mark NetWorkManagerDelegate
#pragma ---

@protocol NetWorkManagerDelegate

@optional

- (void) netWorkStatusWillChange:(NetworkStatus)status;

- (void) netWorkStatusWillEnabled;

- (void) netWorkStatusWillEnabledViaWifi;

- (void) netWorkStatusWillEnabledViaWWAN;

- (void) netWorkStatusWillDisconnection;

@end


#pragma mark interface NetWorkManager
#pragma ---

@interface NetWorkManager : NSObject
{
@private
    
	SReachability* rech;
	
	/** 标识网络是否活跃 **/
	Boolean _netWorkIsEnabled;
	
	/** 设备链接网络的方式 **/
	NetworkStatus _witchNetWorkEnabled;
    
	id<NetWorkManagerDelegate> _delegate;
}

@property (nonatomic, assign) id<NetWorkManagerDelegate> delegate;
@property (nonatomic, assign) Boolean netWorkIsEnabled;
@property (nonatomic, assign) NetworkStatus witchNetWorkEnabled;

@end

#pragma mark NetWorkManager public method
#pragma ---

@interface NetWorkManager (publics)

+ (id) sharedManager;

+ (id) allocWithZone:(NSZone *)zone;

/** 手动发送通知 **/
- (void) activePost;

- (Boolean) startNetWorkWatch;

- (void) stopNetWorkWatch;

@end

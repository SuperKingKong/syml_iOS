//
//  BYCommand.h
//  BaiYing
//
//  Created by Sang Chengjiang on 13-7-29.
//  Copyright (c) 2013年 sohu-inc.com. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 ------------------------------------------------------------------------------------
 为某些相同的操作提供一个统一的调用接口，如调用相机、图库等
 ------------------------------------------------------------------------------------
 */

@interface BYCommand : NSObject

- (void)execute;
@end

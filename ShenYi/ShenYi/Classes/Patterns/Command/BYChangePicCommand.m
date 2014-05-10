//
//  BYChangePicCommand.m
//  BaiYing
//
//  Created by Sang Chengjiang on 13-7-29.
//  Copyright (c) 2013年 sohu-inc.com. All rights reserved.
//

#import "BYChangePicCommand.h"

@implementation BYChangePicCommand

- (id)initWithReceiver:(BYChangePicReceiver *)receiver
{
    self = [super init];
    if (self) {
        _receiver = receiver;
    }
    return self;
}

- (void)execute
{
    [_receiver changePic];
}

@end

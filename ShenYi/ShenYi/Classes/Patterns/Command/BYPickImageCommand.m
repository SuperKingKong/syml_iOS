//
//  BYPickImageCommand.m
//  BaiYing
//
//  Created by Sang Chengjiang on 13-7-29.
//  Copyright (c) 2013年 sohu-inc.com. All rights reserved.
//

#import "BYPickImageCommand.h"

@implementation BYPickImageCommand

- (void)execute
{
    [_pickReceiver pickImage];
}

- (id)initWithReceiver:(BYPickImageReceiver *)receiver
{
    self = [super init];
    if (self) {
        _pickReceiver = receiver;
    }
    return self;
}
@end

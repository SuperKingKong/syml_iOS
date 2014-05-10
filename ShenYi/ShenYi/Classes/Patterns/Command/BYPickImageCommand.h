//
//  BYPickImageCommand.h
//  BaiYing
//
//  Created by Sang Chengjiang on 13-7-29.
//  Copyright (c) 2013年 sohu-inc.com. All rights reserved.
//

#import "BYCommand.h"
#import "BYPickImageReceiver.h"

/*
 ------------------------------------------------------------------------------------
 点击相机或图库时的操作
 ------------------------------------------------------------------------------------
 */
@interface BYPickImageCommand : BYCommand
{
    BYPickImageReceiver * _pickReceiver;
}

- (id)initWithReceiver:(BYPickImageReceiver *)receiver;
@end

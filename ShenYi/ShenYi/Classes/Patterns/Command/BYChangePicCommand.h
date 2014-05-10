//
//  BYChangePicCommand.h
//  BaiYing
//
//  Created by Sang Chengjiang on 13-7-29.
//  Copyright (c) 2013年 sohu-inc.com. All rights reserved.
//

#import "BYCommand.h"
#import "BYChangePicReceiver.h"

/*
 ------------------------------------------------------------------------------------
 点击某按钮，弹出选择相机或图库对话框
 ------------------------------------------------------------------------------------
 */
@interface BYChangePicCommand : BYCommand
{
    BYChangePicReceiver * _receiver;
}

- (id)initWithReceiver:(BYChangePicReceiver *)receiver;

@end

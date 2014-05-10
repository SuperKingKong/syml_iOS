//
//  BYChangePicActionSheet.h
//  BaiYing
//
//  Created by Sang Chengjiang on 13-7-30.
//  Copyright (c) 2013年 sohu-inc.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SYConfig.h"
#import "BYCommand.h"
#import "BYPickImageCommand.h"
#import "BYPickImageReceiver.h"
#import <UIKit/UIKit.h>

/*
 ------------------------------------------------------------------------------------
 选择相机或图库对话框的点击事件的回调
 ------------------------------------------------------------------------------------
 */
@interface BYChangePicActionSheet : NSObject<UIActionSheetDelegate>
{
    UIViewController *_controller;
    __weak id<UIImagePickerControllerDelegate, UINavigationControllerDelegate> _delegate;
    
}

- (id)initWithController:(UIViewController *)controller delegate:(id<UIImagePickerControllerDelegate,UINavigationControllerDelegate>) delegate;
@end

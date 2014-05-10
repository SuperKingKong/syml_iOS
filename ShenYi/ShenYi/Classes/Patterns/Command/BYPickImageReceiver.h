//
//  BYPickImageReceiver.h
//  BaiYing
//
//  Created by Sang Chengjiang on 13-7-29.
//  Copyright (c) 2013年 sohu-inc.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/*
 ------------------------------------------------------------------------------------
 点击相机或图库时的操作
 ------------------------------------------------------------------------------------
 */

@interface BYPickImageReceiver : NSObject
{
    __weak id<UIImagePickerControllerDelegate, UINavigationControllerDelegate> _delegate;
    UIViewController * _controller;
    
    BOOL _isCamera;
}

- (id)initWithController:(UIViewController *) controller
                delegate:(id<UIImagePickerControllerDelegate, UINavigationControllerDelegate>) delegate
                  camera:(BOOL) isCamera;

- (void)pickImage;

@end

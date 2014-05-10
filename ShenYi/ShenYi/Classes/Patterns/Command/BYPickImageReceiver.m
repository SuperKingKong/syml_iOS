//
//  BYPickImageReceiver.m
//  BaiYing
//
//  Created by Sang Chengjiang on 13-7-29.
//  Copyright (c) 2013年 sohu-inc.com. All rights reserved.
//

#import "BYPickImageReceiver.h"

@implementation BYPickImageReceiver

- (id)initWithController:(UIViewController *) controller
                delegate:(id<UIImagePickerControllerDelegate, UINavigationControllerDelegate>) delegate
                  camera:(BOOL) isCamera
{
    self = [super init];
    if (self) {
        _controller = controller;
        _delegate = delegate;
        _isCamera = isCamera;
    }
    return self;
}

- (void)pickImage {
    //先设定sourceType为相机，然后判断相机是否可用（ipod）没相机，不可用将sourceType设定为相片库
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera] || !_isCamera) {
        sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = _delegate;
    picker.allowsEditing = YES;
    picker.sourceType = sourceType;
    [_controller presentViewController:picker animated:YES completion:NULL];
}

@end

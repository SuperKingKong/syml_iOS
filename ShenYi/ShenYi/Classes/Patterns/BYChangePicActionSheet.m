//
//  BYChangePicActionSheet.m
//  BaiYing
//
//  Created by Sang Chengjiang on 13-7-30.
//  Copyright (c) 2013年 sohu-inc.com. All rights reserved.
//

#import "BYChangePicActionSheet.h"

@implementation BYChangePicActionSheet

- (id)initWithController:(UIViewController *)controller delegate:(id<UIImagePickerControllerDelegate,UINavigationControllerDelegate>) delegate
{
    self = [super init];
    if (self) {
        _controller = controller;
        _delegate = delegate;
    }
    return self;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString* btnTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    BYPickImageReceiver *receiver ;
    
    if ([btnTitle isEqualToString:kACTitleCamera]) {
        receiver = [[BYPickImageReceiver alloc] initWithController:_controller delegate:_delegate camera:YES];
        NSLog(@"从相机选取");
    }else if ([btnTitle isEqualToString:kACTitlePhotoLib]) {
        receiver = [[BYPickImageReceiver alloc] initWithController:_controller delegate:_delegate camera:NO];
        NSLog(@"从图库选取");
    } else {
        return;
    }
    
    BYCommand *command = [[BYPickImageCommand alloc] initWithReceiver:receiver];
    [command execute];
}
@end

//
//  BYChangePicReceiver.m
//  BaiYing
//
//  Created by Sang Chengjiang on 13-7-29.
//  Copyright (c) 2013年 sohu-inc.com. All rights reserved.
//

#import "BYChangePicReceiver.h"

@implementation BYChangePicReceiver
{
    
}

- (id)initWithDelegate:(id<UIActionSheetDelegate>) delegate
                   tag:(int)tag
                 title:(NSString *)title
                  view:(UIView *)view
{
    self = [super init];
    if (self) {
        _delegate = delegate;
        _tag = tag;
        _title = title;
        _view = view;
    }
    return self;
}

- (void)changePic{
    UIActionSheet *_actionSheet = [[UIActionSheet alloc] initWithTitle:_title delegate:_delegate cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles: nil];
    _actionSheet.tag = _tag;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [_actionSheet addButtonWithTitle:kACTitleCamera];
    }
    [_actionSheet addButtonWithTitle:kACTitlePhotoLib];
    [_actionSheet addButtonWithTitle:kACTitleCancle];
    
    _actionSheet.cancelButtonIndex = [_actionSheet numberOfButtons] - 1;
    [_actionSheet showInView:_view];
}

@end


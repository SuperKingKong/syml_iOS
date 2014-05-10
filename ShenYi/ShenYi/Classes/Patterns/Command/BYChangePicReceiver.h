//
//  BYChangePicReceiver.h
//  BaiYing
//
//  Created by Sang Chengjiang on 13-7-29.
//  Copyright (c) 2013年 sohu-inc.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SYConfig.h"

/*
 ------------------------------------------------------------------------------------
 点击某按钮，弹出选择相机或图库对话框
 ------------------------------------------------------------------------------------
 */
@interface BYChangePicReceiver : NSObject
{
    int _tag;
    NSString *_title;
    __weak id<UIActionSheetDelegate> _delegate;
    UIView *_view;
    
}

- (id)initWithDelegate:(id<UIActionSheetDelegate>) delegate
                   tag:(int)tag
                 title:(NSString *)title
                  view:(UIView *)view;

- (void)changePic;

@end

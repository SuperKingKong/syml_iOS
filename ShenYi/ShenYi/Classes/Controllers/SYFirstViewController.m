//
//  SYFirstViewController.m
//  ShenYi
//
//  Created by hujinzang on 14-4-22.
//  Copyright (c) 2014年 SuperKingKong. All rights reserved.
//

#import "SYFirstViewController.h"
#import "BYChangePicReceiver.h"
#import "BYChangePicCommand.h"
#import "BYChangePicActionSheet.h"
#import "BYCommand.h"
#import "UIImageAdditionsEx.h"
#import "Util.h"

@interface SYFirstViewController (){
    UIButton *uploadButton;
    UIImageView *selectImageView;
}

@end

@implementation SYFirstViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    uploadButton = [[UIButton alloc]initWithFrame:CGRectMake(80, 250, 140, 30)];
    
    UIImage  *normalImgae = [Util imageWithName:@"phone_green_button" withResizeCapEdgeInset:UIEdgeInsetsMake(0, 10, 0, 10)];
    [uploadButton setBackgroundImage:normalImgae forState:UIControlStateNormal];
    [uploadButton addTarget:self action:@selector(uploadImage:) forControlEvents:UIControlEventTouchDown];
    [uploadButton setTitle:@"上传照片" forState:UIControlStateNormal];
    [self.view addSubview:uploadButton];
    
    selectImageView = [[UIImageView alloc]initWithFrame:CGRectMake(40, 290, 240, 150)];
    selectImageView.contentMode = UIViewContentModeScaleToFill;
    [self.view addSubview:selectImageView];
}


-(void)uploadImage:(id)sender{
    
    BYChangePicReceiver *receiver = [[BYChangePicReceiver alloc]initWithDelegate:self tag:0 title:@"上传照片" view:self.view];
    BYCommand *command = [[BYChangePicCommand alloc] initWithReceiver:receiver];
    [command execute];
}

#pragma mark Camera View Delegate Methods
- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    UIImage* thePhotoTaken = (UIImage *)[info objectForKey:UIImagePickerControllerEditedImage];
    // 按宽高裁为一样处理
    
    [self performSelector:@selector(saveImage:)
               withObject:thePhotoTaken
               afterDelay:0.5];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark- actionsheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    BYChangePicActionSheet *cpActionsheet = [[BYChangePicActionSheet alloc] initWithController:self delegate:self];
    [cpActionsheet actionSheet:actionSheet clickedButtonAtIndex:buttonIndex];
    
}

- (void)saveImage:(UIImage *)image {
    //    _ivBgView.image = image;
    [UIImage writeImageToDocument:image];
    selectImageView.image = image;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

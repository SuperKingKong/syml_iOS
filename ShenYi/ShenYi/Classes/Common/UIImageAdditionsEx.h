//
//  UIImage.h
//  ImageBeautyDemo
//
//  Created by jiang jing on 7/4/11.
//  Copyright 2011 sohu-inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SYConfig.h"
#import "Util.h"

@interface UIImage(Beautiy)
+(UIImage*) rotateImage:(UIImage*)inImage;
+(UIImage*) scaleAndRotateImage:(UIImage*)inImage maxWidth:(int)Resolution;
+(UIImage*) imageFromPixelData:(unsigned char* )data size:(CGSize)s;
+(UIImage *)scalAndClipCenterImage:(UIImage *)image targetSize:(CGSize)targetSize;

+(CGContextRef) createRGBABitmapContext:(CGSize)s;//需要释放返回的cgcontextref,以及其中的data

- (UIImage *)subimageWithRect:(CGRect)rect;

-(CGContextRef) createRGBABitmapContext;  //需要释放返回的cgcontextref,以及其中的data
-(CGContextRef) createGrayBitmapContext;
-(void *)requestImagePixelData;  //需要释放返回的像素数据 free
void releaseCGDataProviderBuffer(void *info,const void *data,size_t size);
@end

@interface UIImage(compressAndsave)
+(NSData*)ImagePress:(UIImage*)image PressRateType:(USettingsUploadImageQuality)rateType;
+(NSString*) writeImageToDocument:(UIImage*)image;
+(NSString*) writeImageDataToDocument:(NSData*)imageData;
@end
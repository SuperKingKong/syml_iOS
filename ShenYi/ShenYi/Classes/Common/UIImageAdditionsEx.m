//
//  UIImage.m
//  ImageBeautyDemo
//
//  Created by jiang jing on 7/4/11.
//  Copyright 2011 sohu-inc. All rights reserved.
//

#import "UIImageAdditionsex.h"

@implementation UIImage(Beautiy)

+(UIImage*) rotateImage:(UIImage*)inImage
{
    CGImageRef imgRef = inImage.CGImage;
	
	CGFloat width = CGImageGetWidth(imgRef);
	CGFloat height = CGImageGetHeight(imgRef);
	
	CGAffineTransform transform = CGAffineTransformIdentity;
	CGRect bounds = CGRectMake(0, 0, width, height);
	
	
	CGSize imageSize = CGSizeMake(width,height);
	CGFloat boundHeight;
	UIImageOrientation orient = inImage.imageOrientation;
	switch(orient) {
			
		case UIImageOrientationUp: //EXIF = 1
			transform = CGAffineTransformIdentity;
			break;
			
		case UIImageOrientationUpMirrored: //EXIF = 2
			transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			break;
			
		case UIImageOrientationDown: //EXIF = 3
			transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
			transform = CGAffineTransformRotate(transform, M_PI);
			break;
			
		case UIImageOrientationDownMirrored: //EXIF = 4
			transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
			transform = CGAffineTransformScale(transform, 1.0, -1.0);
			break;
			
		case UIImageOrientationLeftMirrored: //EXIF = 5
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
			break;
			
		case UIImageOrientationLeft: //EXIF = 6
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
			break;
			
		case UIImageOrientationRightMirrored: //EXIF = 7
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeScale(-1.0, 1.0);
			transform = CGAffineTransformRotate(transform, M_PI / 2.0);
			break;
			
		case UIImageOrientationRight: //EXIF = 8
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
			transform = CGAffineTransformRotate(transform, M_PI / 2.0);
			break;
			
		default:
			[NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
			
	}
	
	UIGraphicsBeginImageContext(bounds.size);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
		CGContextScaleCTM(context, -1, 1);
		CGContextTranslateCTM(context, -height, 0);
	}
	else {
		CGContextScaleCTM(context, 1, -1);
		CGContextTranslateCTM(context, 0, -height);
	}
	
	CGContextConcatCTM(context, transform);
	
	CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
	UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
    //[self setRotatedImage:imageCopy];
	return imageCopy;
}
+(UIImage*) scaleAndRotateImage:(UIImage*)inImage maxWidth:(int)Resolution;
{
	CGImageRef imgRef = inImage.CGImage;
	
	CGFloat width = CGImageGetWidth(imgRef);
	CGFloat height = CGImageGetHeight(imgRef);
	
	CGAffineTransform transform = CGAffineTransformIdentity;
    UIImageOrientation orient = inImage.imageOrientation;
	CGRect bounds = CGRectMake(0, 0, width, height);
	if (width > Resolution || height > Resolution) {
		CGFloat ratio = width/height;
		if (ratio > 1) {
			bounds.size.width = Resolution;
			bounds.size.height = bounds.size.width / ratio;
		}
		else {
			bounds.size.height = Resolution;
			bounds.size.width = bounds.size.height * ratio;
		}
	}else {
        if (orient == UIImageOrientationUp) {
            return inImage;
        }
    }
	
	CGFloat scaleRatio = bounds.size.width / width;
	CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
	CGFloat boundHeight;
	
	switch(orient) {
			
		case UIImageOrientationUp: //EXIF = 1
			transform = CGAffineTransformIdentity;
			break;
			
		case UIImageOrientationUpMirrored: //EXIF = 2
			transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			break;
			
		case UIImageOrientationDown: //EXIF = 3
			transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
			transform = CGAffineTransformRotate(transform, M_PI);
			break;
			
		case UIImageOrientationDownMirrored: //EXIF = 4
			transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
			transform = CGAffineTransformScale(transform, 1.0, -1.0);
			break;
			
		case UIImageOrientationLeftMirrored: //EXIF = 5
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
			break;
			
		case UIImageOrientationLeft: //EXIF = 6
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
			break;
			
		case UIImageOrientationRightMirrored: //EXIF = 7
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeScale(-1.0, 1.0);
			transform = CGAffineTransformRotate(transform, M_PI / 2.0);
			break;
			
		case UIImageOrientationRight: //EXIF = 8
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
			transform = CGAffineTransformRotate(transform, M_PI / 2.0);
			break;
			
		default:
			[NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
			
	}
	
	UIGraphicsBeginImageContext(bounds.size);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
		CGContextScaleCTM(context, -scaleRatio, scaleRatio);
		CGContextTranslateCTM(context, -height, 0);
	}
	else {
		CGContextScaleCTM(context, scaleRatio, -scaleRatio);
		CGContextTranslateCTM(context, 0, -height);
	}
	
	CGContextConcatCTM(context, transform);
	
	CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
	UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return imageCopy;
}


+(UIImage *)scalAndClipCenterImage:(UIImage *)image targetSize:(CGSize)targetSize
{
	UIImage *sourceImage = image;
	UIImage *newImage = nil;        
	CGSize imageSize = sourceImage.size;
    //CGSize targetSize =CGSizeMake(320, 320);
	CGFloat width = imageSize.width;
	CGFloat height = imageSize.height;
	CGFloat targetWidth = targetSize.width;
	CGFloat targetHeight = targetSize.height;
	CGFloat scaleFactor = 0.0;
	CGFloat scaledWidth = targetWidth;
	CGFloat scaledHeight = targetHeight;
	CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
	
	if (CGSizeEqualToSize(imageSize, targetSize) == NO) 
	{
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
		
        if (widthFactor > heightFactor) 
			scaleFactor = widthFactor; // scale to fit height
        else
			scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
		
        // center the image
        if (widthFactor > heightFactor)
		{
			thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5; 
		}
        else if (widthFactor < heightFactor)
        {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
	}       
	
	UIGraphicsBeginImageContext(targetSize); // this will crop
	
	CGRect thumbnailRect = CGRectZero;
	thumbnailRect.origin = thumbnailPoint;
	thumbnailRect.size.width  = scaledWidth;
	thumbnailRect.size.height = scaledHeight;
	
	[sourceImage drawInRect:thumbnailRect];
	
	newImage = UIGraphicsGetImageFromCurrentImageContext();
	
    //pop the context to get back to the default
	UIGraphicsEndImageContext();
	return newImage;
	
    
}

- (UIImage *)subimageWithRect:(CGRect)rect {
    UIImage *result = nil;
    CGImageRef resultRef = CGImageCreateWithImageInRect(self.CGImage, rect);
    result = [UIImage imageWithCGImage:resultRef];
    CGImageRelease(resultRef);
    return result;
}


// Return a bitmap context using alpha/red/green/blue byte values 
-(CGContextRef) createRGBABitmapContext
{
    
	CGSize s = [self size];
	CGContextRef context = NULL; 
	CGColorSpaceRef colorSpace; 
	void *bitmapData; 
	int bitmapByteCount=s.width*s.height*4 ; 
	
	
	colorSpace = CGColorSpaceCreateDeviceRGB();
	if (colorSpace == NULL) 
	{
		//fprintf(stderr, "Error allocating color space\n"); 
		return NULL;
	}
	// allocate the bitmap & create context 
	bitmapData = malloc( bitmapByteCount ); 
	if (bitmapData == NULL) 
	{
		//fprintf (stderr, "Memory not allocated!"); 
		CGColorSpaceRelease( colorSpace ); 
		return NULL;
	}
    
	
	if (self.imageOrientation == UIImageOrientationUp || self.imageOrientation == UIImageOrientationDown) {
		context = CGBitmapContextCreate (bitmapData, 
										 s.width, 
										 s.height, 
										 8, 
										 s.width*4, 
										 colorSpace, 
										 kCGImageAlphaPremultipliedFirst); 
	}
	else {
		context = CGBitmapContextCreate (bitmapData, 
										 s.height, 
										 s.width, 
										 8, 
										 s.height*4, 
										 colorSpace, 
										 kCGImageAlphaPremultipliedFirst);
	}
    
    
    if (self.imageOrientation == UIImageOrientationLeft) {
        CGContextRotateCTM(context, (90 * M_PI/180) );
        CGContextTranslateCTM(context, 0, -s.height);
    }
	else if(self.imageOrientation == UIImageOrientationRight)
	{
		CGContextRotateCTM(context, (-90 * M_PI/180) );
		CGContextTranslateCTM(context, -s.width,0);
	}
	else if(self.imageOrientation == UIImageOrientationDown)
	{
		CGContextTranslateCTM(context, s.width,s.height);
		CGContextRotateCTM(context, (-180 * M_PI/180) );
        
	}
	
	if (context == NULL) 
	{
		free (bitmapData); 
		//fprintf (stderr, "Context not created!");
	} 
	CGColorSpaceRelease( colorSpace ); 
	return context;
}

// Return a bitmap context using alpha/red/green/blue byte values
+(CGContextRef) createRGBABitmapContext:(CGSize)s
{
    
	CGContextRef context = NULL; 
	CGColorSpaceRef colorSpace; 
	void *bitmapData; 
	int bitmapByteCount=s.width*s.height*4 ; 
	
	
	colorSpace = CGColorSpaceCreateDeviceRGB();
	if (colorSpace == NULL) 
	{
		fprintf(stderr, "Error allocating color space\n"); 
        return NULL;
	}
	// allocate the bitmap & create context 
	bitmapData = malloc( bitmapByteCount ); 
	if (bitmapData == NULL) 
	{
		fprintf (stderr, "Memory not allocated!"); 
		CGColorSpaceRelease( colorSpace ); 
		return NULL;
	}
    
    context = CGBitmapContextCreate (bitmapData, 
                                     s.width, 
                                     s.height, 
                                     8, 
                                     s.width*4, 
                                     colorSpace, 
                                     kCGImageAlphaPremultipliedFirst); 
	
	if (context == NULL) 
	{
		free (bitmapData); 
		fprintf (stderr, "Context not created!");
	} 
	CGColorSpaceRelease( colorSpace ); 
	return context;
}

-(CGContextRef) createGrayBitmapContext
{
    CGSize s = [self size];
	CGContextRef context = NULL; 
	CGColorSpaceRef colorSpace; 
	void *bitmapData; 
	int bitmapByteCount=s.width*s.height ; 
	
	
	colorSpace = CGColorSpaceCreateDeviceGray();
	if (colorSpace == NULL) 
	{
		//fprintf(stderr, "Error allocating color space\n"); 
		return NULL;
	}
	// allocate the bitmap & create context 
	bitmapData = malloc( bitmapByteCount ); 
	if (bitmapData == NULL) 
	{
		//fprintf (stderr, "Memory not allocated!"); 
		CGColorSpaceRelease( colorSpace ); 
		return NULL;
	}
    
	
	if (self.imageOrientation == UIImageOrientationUp || self.imageOrientation == UIImageOrientationDown) {
		context = CGBitmapContextCreate (bitmapData, 
										 s.width, 
										 s.height, 
										 8, 
										 s.width, 
										 colorSpace, 
										 kCGImageAlphaNone); 
	}
	else {
		context = CGBitmapContextCreate (bitmapData, 
										 s.height, 
										 s.width, 
										 8, 
										 s.height, 
										 colorSpace, 
										 kCGImageAlphaNone);
	}
    
    
    if (self.imageOrientation == UIImageOrientationLeft) {
        CGContextRotateCTM(context, (90 * M_PI/180) );
        CGContextTranslateCTM(context, 0, -s.height);
    }
	else if(self.imageOrientation == UIImageOrientationRight)
	{
		CGContextRotateCTM(context, (-90 * M_PI/180) );
		CGContextTranslateCTM(context, -s.width,0);
	}
	else if(self.imageOrientation == UIImageOrientationDown)
	{
		CGContextTranslateCTM(context, s.width,s.height);
		CGContextRotateCTM(context, (-180 * M_PI/180) );
        
	}
	
	if (context == NULL) 
	{
		free (bitmapData); 
		//fprintf (stderr, "Context not created!");
	} 
	CGColorSpaceRelease( colorSpace ); 
	return context;
    
}
// Return Image Pixel data as an RGBA bitmap 
-(void *)requestImagePixelData 
{
	CGImageRef img = [self CGImage]; 
	CGSize size = [self size];
	CGContextRef cgctx = [self createRGBABitmapContext];
	
	if (cgctx == NULL) 
		return NULL;
	
	CGRect rect = {{0,0},{size.width, size.height}}; 
	CGContextDrawImage(cgctx, rect, img); 
	unsigned char *data = CGBitmapContextGetData (cgctx); 
	CGContextRelease(cgctx);
	return data;
}



//释放CGDataProviderCreateWithData 中的buffer
void releaseCGDataProviderBuffer(void *info,const void *data,size_t size)
{
	free((void*)data);
}

+(UIImage *)imageFromPixelData:(unsigned char* )data size:(CGSize)s
{
	NSInteger dataLength =s.width * s.height *4;
	CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, data, dataLength, releaseCGDataProviderBuffer);

	// prep the ingredients
	int bitsPerComponent = 8;
	int bitsPerPixel = 32;
	int bytesPerRow = 4 *s.width;
	CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
	CGBitmapInfo bitmapInfo = kCGImageAlphaPremultipliedFirst;
	CGColorRenderingIntent renderingIntent = kCGRenderingIntentRelativeColorimetric;
	
	// make the cgimage
	CGImageRef imageRef = CGImageCreate(s.width, s.height, 
										bitsPerComponent, 
										bitsPerPixel, 
										bytesPerRow, 
										colorSpaceRef, 
										bitmapInfo, 
										provider, 
										NULL, NO, renderingIntent);
	
	UIImage *my_Image = [UIImage imageWithCGImage:imageRef];
	
	CFRelease(imageRef);
	CGColorSpaceRelease(colorSpaceRef);
	CGDataProviderRelease(provider);
	
	return my_Image;
}

@end

#import "UIImageAdditionsex.h"
#import "NetWorkManager.h"
#define kSmallImage   220*220 //鉴于网页F_图：160宽，220高，超出截取
@implementation UIImage(compressAndsave)
+(NSData*)ImagePress:(UIImage*)image PressRateType:(USettingsUploadImageQuality)rateType
{
	NSData *imageData = nil;
	double rate = kCompressRateLow;
	switch (rateType) {
        case USettingsUploadImageQualityAuto:
        {
            if ([[NetWorkManager sharedManager] witchNetWorkEnabled] == ReachableViaWiFi) {
                rate  = kCompressRateHigh;
            }
        }
			break;
		case USettingsUploadImageQualityHigh:
			rate = kCompressRateHigh;
			break;
		case USettingsUploadImageQualityLow:
			rate  = kCompressRateLow;	
			break;
		default:
			break;
	}
    
	if (image.size.height * image.size.width <= kSmallImage) {
		rate = kCompressRateHigh;
	}
	imageData = UIImageJPEGRepresentation(image,rate);
	return imageData;
}

+(NSString*) writeImageToDocument:(UIImage*)image
{
    if (image == nil) {
        return nil;
    }
    NSString *str = nil;
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *date = [dateFormatter stringFromDate:[NSDate date]];
    NSString* randStr = [NSString stringWithFormat:@"%ld",random()%1000];
	NSString *tmpOriginalPath = [[Util pathCacheImgs] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@",date,randStr]];
    
    NSData *doriginal= UIImageJPEGRepresentation(image, [Util imageQulity:image]);
	if (doriginal) {
		BOOL b =	[doriginal writeToFile:tmpOriginalPath atomically:YES];
		if (b) {
            str =  tmpOriginalPath;
		}
	}
    return str;
}

+(NSString*) writeImageDataToDocument:(NSData*)imageData
{
    if (imageData == nil) {
        return nil;
    }
    NSString *str = nil;    
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *date = [dateFormatter stringFromDate:[NSDate date]];
    NSString* randStr = [NSString stringWithFormat:@"%ld",random()%1000];
	NSString *tmpOriginalPath = [[Util pathCacheImgs] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@",date,randStr]];
    
	if (imageData) {
		BOOL b =	[imageData writeToFile:tmpOriginalPath atomically:YES];
		if (b) {
            str =  tmpOriginalPath;
		}
	}
    return str;
}
@end
//
//  Util.m
//  SohuWeibo
//
//  Created by Teng Song on 11-12-21.
//  Copyright (c) 2011年 Sohu.com. All rights reserved.
//

#import "Util.h"
#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>
#import <CommonCrypto/CommonDigest.h>
#include <sys/sysctl.h>
#import <objc/runtime.h>
#import "GTMBase64.h"
#import "svn_version.h"

#include <sys/types.h>
#include <stdio.h>
#include <string.h>
#include <sys/socket.h>
#include <net/if_dl.h>
#include <ifaddrs.h>

#include <sys/socket.h> // Per msqr
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

#include <sys/stat.h>
#include <dirent.h>
#import "NetWorkManager.h"
#import "TTURLCache.h"

@interface Util(cacheDelete)
+ (long long) _folderSizeAtPath: (const char*)folderPath;
+ (long long) _deletefolderFilesAtPath: (const char*)folderPath minSize:(long) minSize lastAccessTime:(long) atimes persistfolder:(BOOL) persist;
@end

@implementation Util(cacheDelete)
+ (long long) _folderSizeAtPath: (const char*)folderPath{
    long long folderSize = 0;
    DIR* dir = opendir(folderPath);
    if (dir == NULL) return 0;
    struct dirent* child;
    while ((child = readdir(dir))!=NULL) {
        if (child->d_type == DT_DIR && (
                                        (child->d_name[0] == '.' && child->d_name[1] == 0) || // 忽略目录 .
                                        (child->d_name[0] == '.' && child->d_name[1] == '.' && child->d_name[2] == 0) // 忽略目录 ..
                                        )) continue;
        
        int folderPathLength = strlen(folderPath);
        char childPath[1024]; // 子文件的路径地址
        stpcpy(childPath, folderPath);
        if (folderPath[folderPathLength-1] != '/'){
            childPath[folderPathLength] = '/';
            folderPathLength++;
        }
        stpcpy(childPath+folderPathLength, child->d_name);
        childPath[folderPathLength + child->d_namlen] = 0;
        if (child->d_type == DT_DIR){ // directory
            folderSize += [self _folderSizeAtPath:childPath]; // 递归调用子目录
            // 把目录本身所占的空间也加上
            struct stat st;
            if(lstat(childPath, &st) == 0) folderSize += st.st_size;
        }else if (child->d_type == DT_REG || child->d_type == DT_LNK){ // file or link
            struct stat st;
            if(lstat(childPath, &st) == 0) folderSize += st.st_size;
        }
    }
    return folderSize;
}

// 按规则删除文件夹中的文件，返回删除的文件总个数
// folderPath:文件路径
// minSize:最小文件，指的是按照大小删除，大于minSize的文件都要删掉。minSize=-1标示不起作用
// atimes:最后使用时间。atimes=-1标示不起作用
// persist:是否保留文件夹不删除
+ (long long) _deletefolderFilesAtPath: (const char*)folderPath minSize:(long) minSize lastAccessTime:(long) atimes persistfolder:(BOOL) persist{
//    printf("-----atimes:%ld \n",atimes);
    if (folderPath == NULL) {
        return 0;
    }
    if (minSize == -1 && atimes == -1) {
        return 0;
    }
    
    long long folderSize = 0;
    char buf[256];
    DIR* dir = opendir(folderPath);
    if (dir == NULL){
        if (fopen (folderPath,"r") != NULL) {
            remove(folderPath);
            return 1;
        }
        return 0;
    }
    struct dirent* child;
    while ((child = readdir(dir))!=NULL) {
        if (folderSize >= kMaxCacheCount && minSize != 0) {
            return kMaxCacheCount;
        }
        if (child->d_type == DT_DIR && (
                                        (child->d_name[0] == '.' && child->d_name[1] == 0) || // 忽略目录 .
                                        (child->d_name[0] == '.' && child->d_name[1] == '.' && child->d_name[2] == 0) // 忽略目录 ..
                                        )) continue;
        
        int folderPathLength = strlen(folderPath);
        char childPath[1024]; // 子文件的路径地址
        stpcpy(childPath, folderPath);
        if (folderPath[folderPathLength-1] != '/'){
            childPath[folderPathLength] = '/';
            folderPathLength++;
        }
        stpcpy(childPath+folderPathLength, child->d_name);
        childPath[folderPathLength + child->d_namlen] = 0;
        if (child->d_type == DT_DIR){ // directory
            folderSize += [self _deletefolderFilesAtPath:childPath minSize:minSize lastAccessTime:atimes persistfolder:persist]; // 递归调用子目录
        }else if (child->d_type == DT_REG || child->d_type == DT_LNK){ // file or link
            struct stat st;
            if(lstat(childPath, &st) == 0)
            {
//                printf("----- Atime:%ld Mtime:%ld Ctime:%ld \n",st.st_atimespec.tv_sec,st.st_mtimespec.tv_sec,st.st_ctimespec.tv_sec);
                if (atimes > -1) {
                    if (minSize > -1) {
                        if (st.st_size >= minSize && st.st_mtimespec.tv_sec <= atimes) {
                            // 按最后使用时间、文件大小删
                            sprintf(buf, "%s/%s", folderPath, child->d_name);
                            remove(buf);
                            folderSize ++;
                        }
                    }
                    else if(st.st_mtimespec.tv_sec <= atimes){
                        // 按最后使用时间删
                        sprintf(buf, "%s/%s", folderPath, child->d_name);
                        remove(buf);
                        folderSize ++;
                    }
                }
                else{
                    if (minSize > -1 && st.st_size >= minSize) {
                        // 按文件大小删
                        sprintf(buf, "%s/%s", folderPath, child->d_name);
                        remove(buf);
                        folderSize ++;
                    }
                }
            }
        }
    }
    
    if ((child = readdir(dir)) == NULL && persist == NO) {
        remove(folderPath);
        folderSize ++;
    }
    return folderSize;
}
@end

@implementation Util
#pragma mark -
#pragma mark File Manager
+ (NSString *)pathShare
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,  NSUserDomainMask, YES);
	if ([paths count] > 0) {		
        
		NSString *dPath = [NSString stringWithFormat:@"%@",[paths objectAtIndex:0]];
        return dPath;
	}	
	return nil; 
}
// 公共图片
+ (NSString *)pathCacheImgs {
	return [self filePathWith:kDirCommonCacheImage isDirectory:YES];
}
// 公共文档
+ (NSString *)pathCacheDocs {
	return [self filePathWith:kDirCommonCacheDocument isDirectory:YES];
}
// 公共音频
+ (NSString *)pathCacheAudio {
	return [self filePathWith:kDirCommonCacheAudio isDirectory:YES];
}


// 用户文档
+ (NSString *)pathUserCacheDocsWithUID:(NSString *)uid {
    return [self filePathWith:[uid stringByAppendingPathComponent:kDirUserCacheDocument] isDirectory:YES];
}

+ (NSString *)dirCurrentUserCacheDocs{
//    if ([[TDataManager shareInstance] isDemoAccount]) {
        return kDirCommonCacheDocument;
//    }else{
//        return  [[[TDataManager shareInstance].currentUser.idUser stringValue] stringByAppendingPathComponent:kDirUserCacheDocument];
//    }
}


// 用户音频
+ (NSString *)pathUserCacheAudiosWithUID:(NSString *)uid {
    return [self filePathWith:[uid stringByAppendingPathComponent:kDirUserCacheAudio] isDirectory:YES];
}
// 用户DB
+ (NSString *)pathUserDBWithUID:(NSString *)uid {
    return [self filePathWith:[uid stringByAppendingPathComponent:kDirUserCacheDB] isDirectory:YES];
}

// 当前用户目录
+ (NSString *)pathCurrentUser{
    //return [self filePathWith:[[TDataManager shareInstance].currentUser.idUser stringValue] isDirectory:YES];
    return nil;
}



+ (NSString *)filePathWith:(NSString *)name isDirectory:(BOOL)isDirectory
{
	NSString *path = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,  NSUserDomainMask, YES);
	if ([paths count] > 0) {	
		name = isDirectory ? name : [name lastPathComponent];
		path = [[paths objectAtIndex:0] stringByAppendingPathComponent:name];
	}
	return path;
}
+ (BOOL)createDirectoryIfNecessaryAtPath:(NSString *)path
{
	BOOL succeeded = YES;
	if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
		NSError *err = [[NSError alloc] init];
		succeeded = [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&err];
		if (!succeeded) {
			SDPRINT(@"Create Path Error : %@", err);
		}
	}
	return succeeded;
}
+ (BOOL)removePathAt:(NSString *)path
{
	BOOL succeeded = YES;
    
    //File Not Exist return Yes
    if (![Util fileIfExist:path]) {
        return YES;
    }
    
	NSError *err = [[NSError alloc] init];
	succeeded = [[NSFileManager defaultManager] removeItemAtPath:path error:&err];
	if (!succeeded) {
		SDPRINT(@"Remove Path Error : %@", err);
	}
	return succeeded;
}
+ (long long) deletefolderFilesAtPath: (NSString*)folderPath minSize:(long) minSize lastAccessTime:(long) atimes persistfolder:(BOOL) persist
{
    return [self _deletefolderFilesAtPath:[folderPath cStringUsingEncoding:NSUTF8StringEncoding] minSize:minSize lastAccessTime:atimes persistfolder:persist];
}

+ (BOOL)fileIfExist:(NSString *)filePath
{
    BOOL rtn = YES;
    //EmptyPath return file Not Exist
    if([Util isEmptyString:filePath])  return NO;
    
    NSFileManager *file_manager = [NSFileManager defaultManager];
    rtn =  [file_manager fileExistsAtPath:filePath];
    return rtn;
}
+ (float)fileSize:(NSString *)filePath
{
    float rtn = 0.0;
    NSFileManager *file_manager = [NSFileManager defaultManager];
    if ([file_manager fileExistsAtPath:filePath]) {
        NSDictionary * attributes = [file_manager attributesOfItemAtPath:filePath error:nil];
        // file size
        NSNumber *theFileSize;
        theFileSize = [attributes objectForKey:NSFileSize];
        if (theFileSize) {
            rtn = [theFileSize floatValue];
        }
    }
    return rtn;
}
+ (long long) folderSizeAtPath:(NSString*) folderPath
{
    return [self _folderSizeAtPath:[folderPath cStringUsingEncoding:NSUTF8StringEncoding]];
}
+ (NSString *)fileModifyDate:(NSString *)filePath
{
    NSString * rtn = nil;
    NSFileManager *file_manager = [NSFileManager defaultManager];
    if ([file_manager fileExistsAtPath:filePath]) {
        NSDictionary * attributes = [file_manager attributesOfItemAtPath:filePath error:nil];
        NSDate * date = [attributes objectForKey:NSFileModificationDate];
        
        rtn = [Util format:date style:@"M月d日"];
    }
    return rtn;
}
+ (NSString*)randomFileNameWithExt:(NSString *)ext
{
    NSMutableString * rtn = [[NSMutableString alloc] init];
    NSString * dictionary = @"abcdefghijklmnopqrstuvwsyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
    //srandom(time(NULL));
    for (int i=0 ; i< 20; i++) {
        int r = arc4random() % [dictionary length];
        [rtn appendString:[dictionary substringWithRange:NSMakeRange(r, 1)]];
    }
    if (![Util isEmptyString:ext]) {
        [rtn appendFormat:@".%@",ext];
    }
    return rtn;
}
+ (NSString*)DataFileNameWithExt:(NSString *)ext
{
    NSMutableString * rtn = [[NSMutableString alloc] init];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"ddMMMyyyyHHmmss"];
    [rtn appendFormat:@"%@", [dateFormatter stringFromDate:[NSDate date]]];
    
    if (![Util isEmptyString:ext]) {
        [rtn appendFormat:@".%@",ext];
    }
    // fix
    return rtn;
}
#pragma mark -
#pragma mark Date Formate
+ (NSString*)formatRefreshTime:(NSDate *)date
{
   	NSTimeInterval elapsed = abs([date timeIntervalSinceNow]);
	if (elapsed < S_MINUTE) {
		return @"刚刚";
	}
	if (elapsed < S_HOUR) {
		int mins = (int)floor(elapsed/S_MINUTE);
		return [NSString stringWithFormat:@"%d分钟前",mins];
	}
    return [Util formatDateTime:date];
}

+ (NSString*)formatRelativeTime:(NSDate *)date 
{	
	NSTimeInterval elapsed = abs([date timeIntervalSinceNow]);
	if (elapsed < S_MINUTE) {
		int secds = (int)floor(elapsed);
//		return secds < 2 ? @"刚刚" : [NSString stringWithFormat:@"%d秒前",secds];
        if(secds < 1) secds = 1;
		return [NSString stringWithFormat:@"%d秒前",secds];
	}
	if (elapsed < S_HOUR) {
		int mins = (int)floor(elapsed/S_MINUTE);
		return [NSString stringWithFormat:@"%d分钟前",mins];
	}
    
//	if (elapsed < S_DAY) {
//		int hours = (int)floor(elapsed/S_HOUR);
//		return [NSString stringWithFormat:@"%d小时前",hours];
//	}
// 去掉昨天前天，by haydn 2012.4.6
/*
	int days = (int)floor((elapsed+S_DAY/2)/S_DAY);
	if (days < 2) {
		return @"昨天";
	}
	if (days < 365) {
		return @"前天";
	}
 */
	return [Util formatDateTime:date];
}

+ (NSString*)formatDateTime:(NSDate *)date 
{
    // 加入年，by haydn 2012.4.6
    NSCalendar* cal = [NSCalendar currentCalendar];
    NSDateComponents* day_ = [cal components:NSYearCalendarUnit
                                   fromDate:date];
    NSDateComponents* today_ = [cal components:NSYearCalendarUnit
                                     fromDate:[NSDate date]];
    
    //判断是否同年
    if (day_.year < today_.year) 
    {
        return [Util format:date style:@"YYYY年M月d日"];
    }
    
    //是否同月同日
    if([cal components:NSCalendarUnitMonth fromDate:date].month ==
       [cal components:NSCalendarUnitMonth fromDate:[NSDate date]].month &&
        [cal components:NSCalendarUnitDay fromDate:date].day ==
                            [cal components:NSCalendarUnitDay fromDate:[NSDate date]].day)
    {
        // 同日的用小时
        NSTimeInterval elapsed = abs([date timeIntervalSinceNow]);
        if (elapsed < S_DAY) {
            int hours = (int)floor(elapsed/S_HOUR);
            return [NSString stringWithFormat:@"%d小时前",hours];
        }
//        NSString *time = [Util format:date style:@"aa h:mm"];
//		return [NSString stringWithFormat:@"%@", time];  
    }

    //是否同月昨天
    if([cal components:NSCalendarUnitMonth fromDate:date].month ==
       [cal components:NSCalendarUnitMonth fromDate:[NSDate date]].month &&
       [cal components:NSCalendarUnitDay fromDate:date].day + 1 ==
       [cal components:NSCalendarUnitDay fromDate:[NSDate date]].day)
    {
//        NSString *time = [Util format:date style:@"昨天 aah:mm"];//12小时
        NSString *time = [Util format:date style:@"昨天 HH:mm"];//24小时
		return [NSString stringWithFormat:@"%@", time];
    }
    
    //是否同月前天
    if([cal components:NSCalendarUnitMonth fromDate:date].month ==
       [cal components:NSCalendarUnitMonth fromDate:[NSDate date]].month &&
       [cal components:NSCalendarUnitDay fromDate:date].day + 2 ==
       [cal components:NSCalendarUnitDay fromDate:[NSDate date]].day)
    {
    // 星期几
    // NSString *time = [Util format:date style:@"eee HH:mm"];
        NSString *time = [Util format:date style:@"前天 HH:mm"];
		return [NSString stringWithFormat:@"%@", time];
    }
    
	return [Util format:date style:@"M月d日"];
}

//同formatDateTime，但整年不加几点几分
+ (NSString*)formatDateWholeYear:(NSDate *)date
{
    // 加入年，by haydn 2012.4.6
    NSCalendar* cal = [NSCalendar currentCalendar];
    NSDateComponents* day_ = [cal components:NSYearCalendarUnit
                                    fromDate:date];
    NSDateComponents* today_ = [cal components:NSYearCalendarUnit
                                      fromDate:[NSDate date]];
    
    //判断是否同年
    if (day_.year < today_.year) 
    {
        return [Util format:date style:@"YYYY年M月d日"];
    }
    
    return [self formatDateTime:date];
}

+ (NSString*)formatTime:(NSDate *)date 
{
	return [Util format:date style:@"h:mm a"];
}
+ (NSString*)format:(NSDate *)date style:(NSString*)strFmt
{
	NSString *result = nil;
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    [formatter setLocale:usLocale];
	[formatter setDateFormat:strFmt];
	result = [formatter stringFromDate:date];
	return result;
}
+ (NSString*)formatTimeWithSecond:(float)formatSecond
{
    NSString * rtn = nil;
    NSString * secondString = nil;
    NSString * miniteString = nil;
    
    NSInteger second = ceilf(formatSecond);
    
    if (second < S_MINUTE) 
    {
        secondString = [NSString stringWithFormat:@"%02d", second];
        miniteString = @"00";
	}
	else if (second < S_HOUR) 
    {
        NSInteger tmpMinite =  second / S_HOUR;
        miniteString = [NSString stringWithFormat:@"%02d", tmpMinite];
        NSInteger tmpSecond = (int)(second-tmpMinite*S_MINUTE) % S_MINUTE;
        secondString = [NSString stringWithFormat:@"%02d", tmpSecond];
	}
    
    rtn = [NSString stringWithFormat:@"%@:%@",miniteString,secondString];
    
    return rtn;
}
+ (NSString *)formatVideoRecordTimeWith:(NSTimeInterval)interval
{
    NSString *result = @"00:00:00";
    
    if (interval < 0) return result;
    
    NSInteger hour = (NSInteger)floor(interval/S_HOUR);
    interval -= hour * S_HOUR;
    NSInteger minute = (NSInteger)floor(interval/S_MINUTE);
    interval -= minute * S_MINUTE;
    NSInteger second = (NSInteger)floor(interval);
    result = [NSString stringWithFormat:@"%02d:%02d:%02d", hour, minute, second];
    return result;
}

+ (NSDate *)parseSWTimeFormat:(NSString *)strTime
{
	if ([Util isEmptyString:strTime]) {
		return nil;
	}		
	return [NSDate dateWithTimeIntervalSince1970:[strTime doubleValue]/1000];
}

#pragma marc -
#pragma marc Empty String
+ (BOOL)isEmptyString:(NSString *)string
{
    BOOL result = NO;
    if (string == nil || [string length] == 0 || [string isEqualToString:@""]) {
        result = YES;
    }
    return result;
}

#pragma marc -
#pragma marc URL Encode
+ (NSString *)base64URLEncodeWith:(NSString *)urlstring {
    NSString *result = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)urlstring,
                                                                           NULL,(CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                           kCFStringEncodingUTF8 ));
    return result;
}
+ (NSString *)urlEncode:(NSString *)originalString stringEncoding:(NSStringEncoding)stringEncoding
{
    if ([Util isEmptyString:originalString]) {
		return nil;
	}	
	//!  @  $  &  (  )  =  +  ~  `  ;  '  :  ,  /  ?
	//%21%40%24%26%28%29%3D%2B%7E%60%3B%27%3A%2C%2F%3F
    NSArray *escapeChars = [NSArray arrayWithObjects:@";" , @"/" , @"?" , @":" ,
							@"@" , @"&" , @"=" , @"+" ,	@"$" , @"," ,
							@"!", @"'", @"(", @")", @"*", nil];	
    NSArray *replaceChars = [NSArray arrayWithObjects:@"%3B" , @"%2F" , @"%3F" , @"%3A" , 
							 @"%40" , @"%26" , @"%3D" , @"%2B" , @"%24" , @"%2C" ,
							 @"%21", @"%27", @"%28", @"%29", @"%2A", nil];	
    int len = [escapeChars count];	
	NSString *temp = [originalString stringByAddingPercentEscapesUsingEncoding:stringEncoding];
	NSString* newString = nil;
    for(int i = 0; i < len; i++) {
        newString = [temp stringByReplacingOccurrencesOfString:[escapeChars objectAtIndex:i]
											   withString:[replaceChars objectAtIndex:i]
												  options:NSLiteralSearch
													range:NSMakeRange(0, [temp length])];
        temp = newString;
        newString = nil;
    }	
    NSString *outString = [NSString stringWithString:temp];	
    return outString;
}

+ (NSString *)md5Hash:(NSString *)content
{
	const char* str = [content UTF8String];
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	CC_MD5(str, strlen(str), result);
	
	return [NSString stringWithFormat:
			@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
			result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
			result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]
			];
}

#pragma mark -
#pragma mark Image Manager
+ (UIImage *)imageWithName:(NSString *)imgname
{
    UIImage *img = [Util imageWithName:imgname ofType:@"png"];
    if (!img) {
        img = [Util imageWithName:imgname ofType:@"jpg"];
    }
	return img;
}

+ (UIImage *)imageWithName:(NSString *)imgname ofType:(NSString *)imgtype
{
    return [UIImage imageNamed:[NSString stringWithFormat:@"%@.%@",imgname,imgtype]];
}

// 导航栏资源拉伸后的png图片
+ (UIImage *)imageWithName:(NSString *)imgname ofType:(NSString *)imgtype withResizeCapEdgeInset:(UIEdgeInsets)inset{
    
    if ([self isCurrentVersionLowerThanRequiredVersion:@"5.0"]) {
        return [[Util imageWithName:imgname ofType:imgtype] stretchableImageWithLeftCapWidth:inset.left topCapHeight:inset.top];
    }
    return [[Util imageWithName:imgname ofType:imgtype] resizableImageWithCapInsets:inset];
}

+ (UIImage *)imageWithNameAfterAutoResize:(NSString *)imageName
{
    
    UIImage *aImage = [UIImage imageNamed:imageName];
    
    if ([self isCurrentVersionLowerThanRequiredVersion:@"5.0"]) {
        return [aImage stretchableImageWithLeftCapWidth:aImage.size.width/2.0-1 topCapHeight:0];
    }
    return [aImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, aImage.size.width/2.0-1 , 0, aImage.size.width/2.0-1 )];
    
}


+ (UIImage *)imageWithName:(NSString *)imgname withResizeCapEdgeInset:(UIEdgeInsets)inset
{
    return [self imageWithName:imgname ofType:@"png" withResizeCapEdgeInset:inset];
}



+ (UIImage *)scaleImageWithName:(NSString*)imgname
{
    return [[UIImage alloc] initWithCGImage:
            [Util imageWithName:imgname].CGImage scale:1.0 orientation:UIImageOrientationDown];
}

+ (CGGradientRef)newGradientWithColors:(UIColor**)colors locations:(CGFloat*)locations
								 count:(int)count {
	CGFloat* components = malloc(sizeof(CGFloat)*4*count);
	for (int i = 0; i < count; ++i) {
		UIColor* color = colors[i];
		size_t n = CGColorGetNumberOfComponents(color.CGColor);
		const CGFloat* rgba = CGColorGetComponents(color.CGColor);
		if (n == 2) {
			components[i*4] = rgba[0];
			components[i*4+1] = rgba[0];
			components[i*4+2] = rgba[0];
			components[i*4+3] = rgba[1];
		} else if (n == 4) {
			components[i*4] = rgba[0];
			components[i*4+1] = rgba[1];
			components[i*4+2] = rgba[2];
			components[i*4+3] = rgba[3];
		}
	}
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGColorSpaceRef space = CGBitmapContextGetColorSpace(context);
	CGGradientRef gradient = CGGradientCreateWithColorComponents(space, components, locations, count);
	free(components);
	return gradient;
}

//缩放图片为了对iphone设备适配
+ (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size
{ 
    // 创建一个bitmap的context  
    // 并把它设置成为当前正在使用的context  
    UIGraphicsBeginImageContext(size);  
    // 绘制改变大小的图片  
    [img drawInRect:CGRectMake(0, 0, size.width, size.height)];  
    // 从当前context中创建一个改变大小后的图片  
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();  
    // 使当前的context出堆栈  
    UIGraphicsEndImageContext();  
    // 返回新的改变大小后的图片  
    return scaledImage;  
}


// 根据网络情况调整
+ (CGFloat)imageWidthForUpload:(BOOL)isLandScape{
    NetworkStatus netStatue = [[NetWorkManager sharedManager] witchNetWorkEnabled];
    CGFloat maxWidth;
    if (!isLandScape) {
        maxWidth = k3GImageSize;
        if (netStatue == ReachableViaWiFi) {
            maxWidth = kWifiImageSize;
        }
    }else{
        maxWidth = k3GImageSizeLS;
        if (netStatue == ReachableViaWiFi) {
            maxWidth = kWifiImageSizeLS;
        }
    }
    return maxWidth;
}

+ (CGFloat)imageQulity:(UIImage *)image{
    CGFloat rate = 1;
	if (image.size.height * image.size.width <= kSmallImage) {
		rate = kCompressRateHigh;
	}else{
        if ([[NetWorkManager sharedManager] witchNetWorkEnabled] == ReachableViaWiFi) {
            rate  = kCompressRateHigh;
        }else{
            rate = kCompressRateLow;
        }
    }
    return rate;
}

+ (UIImage *)imgFromView:(UIView *)view{

    UIGraphicsBeginImageContext(view.bounds.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
#pragma mark -
#pragma mark Rotate
+ (void)rotateView:(UIView *)view From:(UIInterfaceOrientation)currentOrientation To:(UIInterfaceOrientation)targetOrientation With:(BOOL)animated Delegate:(id)delegate
{
	UIInterfaceOrientation current = currentOrientation;
	UIInterfaceOrientation orientation = targetOrientation;    
    
    if ( current == orientation )
        return;
    
    // direction and angle
    CGFloat angle = 0.0;
    switch ( current )
    {
        case UIInterfaceOrientationPortrait:
        {
            switch ( orientation )
            {
                case UIInterfaceOrientationPortraitUpsideDown:
                    angle = (CGFloat)M_PI;  // 180.0*M_PI/180.0 == M_PI
                    break;
                case UIInterfaceOrientationLandscapeLeft:
                    angle = (CGFloat)(M_PI*-90.0)/180.0;
                    break;
                case UIInterfaceOrientationLandscapeRight:
                    angle = (CGFloat)(M_PI*90.0)/180.0;
                    break;
                default:
                    return;
            }
            break;
        }
        case UIInterfaceOrientationPortraitUpsideDown:
        {
            switch ( orientation )
            {
                case UIInterfaceOrientationPortrait:
                    angle = (CGFloat)M_PI;  // 180.0*M_PI/180.0 == M_PI
                    break;
                case UIInterfaceOrientationLandscapeLeft:
                    angle = (CGFloat)(M_PI*90.0)/180.0;
                    break;
                case UIInterfaceOrientationLandscapeRight:
                    angle = (CGFloat)(M_PI*-90.0)/180.0;
                    break;
                default:
                    return;
            }
            break;
        }
        case UIInterfaceOrientationLandscapeLeft:
        {
            switch ( orientation )
            {
                case UIInterfaceOrientationLandscapeRight:
                    angle = (CGFloat)M_PI;  // 180.0*M_PI/180.0 == M_PI
                    break;
                case UIInterfaceOrientationPortraitUpsideDown:
                    angle = (CGFloat)(M_PI*-90.0)/180.0;
                    break;
                case UIInterfaceOrientationPortrait:
                    angle = (CGFloat)(M_PI*90.0)/180.0;
                    break;
                default:
                    return;
            }
            break;
        }
        case UIInterfaceOrientationLandscapeRight:
        {
            switch ( orientation )
            {
                case UIInterfaceOrientationLandscapeLeft:
                    angle = (CGFloat)M_PI;  // 180.0*M_PI/180.0 == M_PI
                    break;
                case UIInterfaceOrientationPortrait:
                    angle = (CGFloat)(M_PI*-90.0)/180.0;
                    break;
                case UIInterfaceOrientationPortraitUpsideDown:
                    angle = (CGFloat)(M_PI*90.0)/180.0;
                    break;
                default:
                    return;
            }
            break;
        }
    }
	
	UIView *v = view;
	if (animated) {	
		[UIView beginAnimations:@"RotateAnimation" context:NULL];
		[UIView setAnimationDuration:0.3];
		//v.transform = CGAffineTransformRotate(v.transform, angle);
        v.layer.transform = CATransform3DRotate(v.layer.transform, angle, 0.0, 0.0, 1.0);
		[UIView commitAnimations];
	}else {
		//v.transform = CGAffineTransformRotate(v.transform, angle);
        v.layer.transform = CATransform3DRotate(v.layer.transform, angle, 0.0, 0.0, 1.0);
	}
}

+ (void)replaceDictionaryValue:(NSMutableDictionary*)dict value:(id)value forKey:(id)key
{
	[dict removeObjectForKey:key];
	[dict setObject:value forKey:key];
}

#pragma mark Sysctlbyname Utils
#pragma ---

+ (NSString *)getSysInfoByName:(char *)typeSpecifier
{
	size_t size;
    sysctlbyname(typeSpecifier, NULL, &size, NULL, 0);
    char *answer = malloc(size);
	sysctlbyname(typeSpecifier, answer, &size, NULL, 0);
	NSString *results = [NSString stringWithCString:answer encoding: NSUTF8StringEncoding];
	free(answer);
	return results;
}

+ (NSString *)platform
{
	return [Util getSysInfoByName:"hw.machine"];
}

+ (UIDevicePlatform)platformType
{
	NSString *platform = [Util platform];
    if ([platform hasPrefix:@"iPhone3"])			return UIDevice4iPhone;
	if ([platform hasPrefix:@"iPhone4"])			return UIDevice4SiPhone;
	if ([platform hasPrefix:@"iPhone5"])			return UIDevice5iPhone;
    if ([platform hasPrefix:@"iPhone2"])	        return UIDevice3GSiPhone;
    if ([platform isEqualToString:@"iPhone1,2"])	return UIDevice3GiPhone;
    
    if ([platform isEqualToString:@"iPad1,1"])      return UIDevice1GiPad;
	if ([platform isEqualToString:@"iPad2,1"])      return UIDevice2GiPad;
    if ([platform hasPrefix:@"iPad2"])              return UIDevice2GiPad;
    if ([platform hasPrefix:@"iPad3"])              return UIDevice3GiPad;
	
    if ([platform isEqualToString:@"iPod3,1"])      return UIDevice3GiPod;
	if ([platform isEqualToString:@"iPod4,1"])      return UIDevice4GiPod;
	if ([platform isEqualToString:@"iPod5,1"])      return UIDevice5GiPod;
    if ([platform isEqualToString:@"iPod1,1"])      return UIDevice1GiPod;
	if ([platform isEqualToString:@"iPod2,1"])      return UIDevice2GiPod;
	if ([platform isEqualToString:@"iPhone1,1"])	return UIDevice1GiPhone;
	return UIDeviceUnknown;
}

+ (BOOL)isCurrentVersionLowerThanRequiredVersion:(NSString *)sysVersion
{
	NSString *curVersion = [[UIDevice currentDevice] systemVersion];
	if ([curVersion compare:sysVersion options:NSNumericSearch] == NSOrderedAscending) {
		return YES;
	}
	return NO;
}

+ (void)removeAndReleaseViewSafefly:(UIView *)aview
{
	if (aview.superview) {
		[aview removeFromSuperview];
	}
	aview = nil;
}

+ (NSLocale*) currentLocale
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	NSArray* languages = [defaults objectForKey:@"AppleLanguages"];
	if (languages.count > 0) {
		NSString* currentLanguage = [languages objectAtIndex:0];
		return [[NSLocale alloc] initWithLocaleIdentifier:currentLanguage];
	} else {
		return [NSLocale currentLocale];
	}
}

+ (NSString *) macAddress
{
    int                     mib[6];
    size_t                  len;
    char                    *buf;
    unsigned char           *ptr;
    struct if_msghdr        *ifm;
    struct sockaddr_dl      *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0)
    {
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) 
    {
        return NULL;
    }
    
    if ((buf = malloc(len)) == NULL) 
    {
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0)
    {
        return NULL;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    NSString *outstring = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    free(buf);
    return outstring;
}


+ (NSError *)requestErrorWith:(SErrorCode)errorCode {
    NSError *error = nil;
    NSString *description = nil;
    if (errorCode <= Max_Network_ErrorCode) {
        if (errorCode == SErrorUrlNotExits){
            description = @"请求的的图片不存在";
        } else if(errorCode == SErrorOperationCouldNotComplate){
            description = @"请求的内容出错了";
        }
        else {
            description = @"网络不给力，重试一下吧";
        }
    } else {
        switch (errorCode) {
            case SErrorDefault:
                description = @"出错了";
                break;
            case SErrorLogonFail:
                description = @"登录失败，用户名和密码校验失败";
                break;
            case SErrorDeleteInvalidItem:
                description = @"删除的数据无效";
                break;
            case SErrorNotLogin:
                description = @"用户尚未登录";
                break;
            case SErrorHadLogin:
                description = @"用户已经登录";
                break;
            case SErrorInvalidUserWhileChangeActiveUser:
                description = @"无效的帐户信息";
                break;
            case SErrorNoneOauthTokenWhileChangeActiveUser:
                description = @"无身份认证，需要重新登录";
                break;
            case SErrorSaveGIF:
                description = @"系统不支持保存GIF";
                break;
            case SErrorReadGIF:
                description = @"系统不支持该编码类型的图片";
                break;
            case SErrorWillShowPicTooMuch:
                description = @"请求的图片太大啦";
                break;
            default:
                description = @"网络不给力，重试一下吧";
                break;
        }
    }
    
    if (![self isEmptyString:description]) {
        error = [NSError errorWithDomain:kErrorDomain code:errorCode userInfo:[NSDictionary dictionaryWithObjectsAndKeys:description, NSLocalizedDescriptionKey, nil]];
    }
    return error;
}
+ (NSInteger)intErrorCodeWith:(NSString *)codeString {
	NSInteger result = 0;
	NSArray *codes = [codeString componentsSeparatedByString:@"_"];
	for (NSString *v in codes) {
		result += [v intValue];
	}
	result = result == 0 ? [codeString intValue] : result;
    result += 10000;
	return result;
}

+ (NSString *)appVersion {
#ifdef TARGET_STORE
    return [[NSBundle mainBundle].infoDictionary valueForKey:(NSString *)kCFBundleVersionKey];
#else
    return APP_VERSION_FULL;
#endif
}

+ (BOOL)isValidNewVersionNotification:(NSString *)newVersionStr {
    if ([newVersionStr compare:[[NSBundle mainBundle].infoDictionary valueForKey:(NSString*)kCFBundleVersionKey] options:NSNumericSearch] == NSOrderedDescending) {
        return YES;
    }
    return NO;
}

#pragma mark - Images
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

+ (BOOL)dictValid:(id)obj{
    if([obj isKindOfClass:[NSDictionary class]]){
        return YES;
    }
    return NO;
}


+ (NSInteger)randIntLessThan:(NSInteger)ceil seedObject:(NSObject *)obj{
    srand (obj.hash);
    if (ceil == 0) {
        return rand();
    }
    return  rand() % ceil;
}

#pragma mark - Baiying related


// 导航栏资源拉伸后的右侧按钮背景 以对话页为例
+ (UIImage *)imageButtonNavRight
{
    return [Util imageWithName:@"Top_right_button_bg" withResizeCapEdgeInset:UIEdgeInsetsMake(0, 11, 0, 11)];
}


// 将文件以URL缓存
+ (BOOL)moveFile:(NSString *)path toCache:(NSString *)targetUrl type:(BOOL)isPic
{
    if (!path || !targetUrl) {
        return NO;
    }
    if (![path isKindOfClass:[NSString class]] || ![targetUrl isKindOfClass:[NSString class]]) {
        return NO;
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return NO;
    }
    
    TTURLCache *cache = isPic? [TTURLCache sharedImgsCache] : [TTURLCache sharedAudioCache];
    NSString *pathTarget = [cache cachePathForURL:targetUrl];
    if (!isPic) {
        return [[NSFileManager defaultManager] copyItemAtPath:path toPath:pathTarget error:nil];
    }else{
        return [[NSFileManager defaultManager] moveItemAtPath:path toPath:pathTarget error:nil];
    }
}

+ (BOOL)isLocalPath:(NSString *)str
{
    if (!str) {
        return NO;
    }
    if (![str respondsToSelector:@selector(hasPrefix:)]) {
        return NO;
    }
    
    if ([str hasPrefix:@"/"] || [str hasPrefix:@"file"]) {
        return YES;
    }
    return NO;
}

+ (BOOL)isUrlHasThumbnail:(NSString *)url
{
    if (!url) {
        return NO;
    }
    NSURL *urlOrigin = [NSURL URLWithString:url];
    NSString * picName = [urlOrigin lastPathComponent];
    if ([picName hasPrefix:@"t_"]) {
        return YES;
    }
    return NO;
}

+ (NSString *)randomFileNameWithPrefix:(NSString *)path{
    if (!path) {
        return nil;
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *date = [dateFormatter stringFromDate:[NSDate date]];
    NSString* randStr = [NSString stringWithFormat:@"%ld",random()%1000];
    NSString *tmpOriginalPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@",date,randStr]];
    return tmpOriginalPath;
}



+ (BOOL)isSupportCamera
{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        return NO;
    
    return YES;
}

+(CGSize)sizeForText:(NSString*)text width:(CGFloat)width fontHeight:(CGFloat)fontHeight
{
    
    CGSize constraintSize;
    
    constraintSize.width = width;
    
    constraintSize.height = MAXFLOAT;
    
    UIFont *labelFont = [UIFont systemFontOfSize:fontHeight];
    
    CGSize stringSize =[text sizeWithFont:labelFont constrainedToSize: constraintSize lineBreakMode: NSLineBreakByWordWrapping];
    
    return stringSize;
}

+(CGFloat)heightOfText:(CGSize)size fontHeight:(CGFloat)fontHeight
{
    CGFloat height = size.height;
    //如果是单行，则返回字体高度，否则返回计算出来的高度
    if(height < fontHeight * 2) {
        height = fontHeight;
    }
    return height;
}

// 适配 iOS 7 和低版本 iOS UI
+(CGRect)compatibilityCGRectMakeOrignX:(CGFloat)x orignY:(CGFloat)y width:(CGFloat)width height:(CGFloat)height
{
    if([Util isCurrentVersionLowerThanRequiredVersion:@"7.0"]){
        return CGRectMake(x, y, width, height);
    }
    else{
        return CGRectMake(x, y+20, width, height); /* 用sdk 7 编译适配*/
        //return CGRectMake(x, y+0, width, height);    /* sdk 6 编译不做任何处理*/

    }
}



+(CGRect)compatibilityCGrectOffSet:(CGRect)frame deltaX:(CGFloat)x deltaY:(CGFloat)y
{
    if([Util isCurrentVersionLowerThanRequiredVersion:@"7.0"]){
        return CGRectOffset(frame, x, y);
    }
    else{
        return CGRectOffset(frame, x, y+10);  /* 用sdk 7 编译适配*/
        //return CGRectOffset(frame, x, y+0);     /* sdk 6 编译不做任何处理*/
    }
}

+ (NSString *)dataFilePath:(NSString *)fileName
{
    /*常量NSDocumentDirectory表明我们正在查找Documents目录路径，第二个常量NSUserDomainMask表示的是把搜索范围定在应用程序沙盒中，YES表示的是希望希望该函数能查看用户主目录*/
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //  数组索引0处Documentd目录，
    NSString *documentDirectory = [paths objectAtIndex:0];
    //    返回一个kFileName的完整路径
    return [documentDirectory stringByAppendingPathComponent:fileName];
}

+ (NSString *)trim:(NSString *)str
{
    return [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}


+ (BOOL)string:(NSMutableString *)string shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text maxNumber:(NSInteger)maxNumber willChange:(BOOL *)change {
    
    //删除，则随便
    if (range.length == 1) {
        return YES;
    }
    
    NSInteger distance = maxNumber - string.length;
    if (distance <= 0) {
        return NO;
    }
    
    if (text.length > distance) {
        text = [text substringToIndex:distance];
        [string insertString:text atIndex:range.location];
        *change = YES;
        //        [self.delegate changeText:string];
        return NO;
    }
    
    if (range.location >= maxNumber) {
        return NO;
    }
    
    return YES;
}

/*检查是否是手机号，符合手机号正则式*/
+(BOOL)isMobilePhoneNumber:(NSString *)mobile
{
    /**
     * 手机号码
     * 移动：134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     * 联通：130,131,132,152,155,156,185,186
     * 电信：133,1349,153,180,189
     */
    NSString * MOBILE = kMobileRegex;
    /**
     10         * 中国移动：China Mobile
     11         * 134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     12         */
    NSString * CM = kCMMobileRegex;
    /**
     15         * 中国联通：China Unicom
     16         * 130,131,132,152,155,156,185,186
     17         */
    NSString * CU = kCUMobileRegex;
    /**
     20         * 中国电信：China Telecom
     21         * 133,1349,153,180,189
     22         */
    NSString * CT = kCTMobileRegex;
    /**
     25         * 大陆地区固话及小灵通
     26         * 区号：010,020,021,022,023,024,025,027,028,029
     27         * 号码：七位或八位
     28         */
    // NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    
    if (([regextestmobile evaluateWithObject:mobile] == YES)
        || ([regextestcm evaluateWithObject:mobile] == YES)
        || ([regextestct evaluateWithObject:mobile] == YES)
        || ([regextestcu evaluateWithObject:mobile] == YES))
    {
        return YES;
    }
    return NO;
}

/*检查手机号属于哪家运营商*/
+(NSString *)mobilePhoneNumberBelong:(NSString *)mobile
{
    /**
     * 手机号码
     * 移动：134[0-8],135,136,137,138,139,150,151,152,157,158,159,182,183,184,187,188,147
     * 联通：130,131,132,155,156,176,185,186,145
     * 电信：133,1349,153,170,177,180,181,189
     */
    //NSString * MOBILE = @"^1(3[0-9]|4[7]|5[0-35-9]|7[07]|8[0-9])\\d{8}$";
    /**
     10         * 中国移动：China Mobile
     11         * 134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     12         */
    NSString * CM = kCMMobileRegex;
    /**
     15         * 中国联通：China Unicom
     16         * 130,131,132,155,156,185,186
     17         */
    NSString * CU = kCUMobileRegex;
    /**
     20         * 中国电信：China Telecom
     21         * 133,1349,153,180,189
     22         */
    NSString * CT = kCTMobileRegex;
    /**
     25         * 大陆地区固话及小灵通
     26         * 区号：010,020,021,022,023,024,025,027,028,029
     27         * 号码：七位或八位
     28         */
    // NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
    
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    
    if ([regextestcm evaluateWithObject:mobile] == YES) {
        return @"cmPageStayTime";
    }
    else if ([regextestct evaluateWithObject:mobile] == YES){
        return @"cuPageStayTime";
    }
    else if ([regextestcu evaluateWithObject:mobile] == YES){
        return @"ctPageStayTime";
    }
    else{
        return @"otherPageStayTime";
    }

}

//
//+ (NSInteger) sideLengthOfPicCount:(NSInteger)count index:(NSInteger)index{
//    
//    if (index >= count) {
//        return 0;
//    }
//    
//    switch (count) {
//        case 1:
//            return kWidthLevel1_2;
//        case 2:
//            return kWidthLevel3_2;
//        case 3:
//        {
//            switch (index) {
//                case 0:
//                    return kWidthLevel2_2;
//                case 1:
//                case 2:
//                    return kWidthLevel4_2;
//            }
//        }
//        case 4:
//            return kWidthLevel3_2;
//        case 5:
//        {
//            switch (index) {
//                case 0:
//                    return kWidthLevel2_2;
//                case 1:
//                case 2:
//                    return kWidthLevel4_2;
//                case 3:
//                case 4:
//                    return kWidthLevel3_2;
//         
//            }
//        }
//        case 6:
//        {
//            if (index == 0) {
//                return kWidthLevel2_2;
//            } else {
//                return kWidthLevel4_2;
//            }
//        }
//    }
//    return 0;
//}

+(UIWindow *)windowWithLevel:(UIWindowLevel)windowLevel{
    NSArray *windows = [[UIApplication sharedApplication]windows];
    for(UIWindow *window in windows){
        if(window.windowLevel == windowLevel){
            return window;
        }
    }
    return nil;
}

+ (NSString *)append_t_toStr:(NSString *)strUrl{
    NSURL *urlOrigin = [NSURL URLWithString:strUrl];
    NSString * picName = [urlOrigin lastPathComponent];
    NSString *newPicName = [NSString stringWithFormat:@"t_%@",picName];
    NSURL *newUrl = [[urlOrigin URLByDeletingLastPathComponent] URLByAppendingPathComponent:newPicName];
    return [newUrl absoluteString];
}

+ (NSString *)replaceSuffixTo:(NSString *)strSuffix inStr:(NSString *)originStr{
    if (!strSuffix || !originStr) {
        return originStr;
    }
    NSURL *urlOrigin = [NSURL URLWithString:originStr];
    NSURL *urlTarget = [[urlOrigin URLByDeletingPathExtension] URLByAppendingPathExtension:strSuffix];
    return [urlTarget absoluteString];
}

+ (CGFloat)keyboardHeightInNotification:(NSNotification *) notification {
    NSDictionary *userInfo = [notification userInfo];
    
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    CGRect keyboardRect = [aValue CGRectValue];
    return keyboardRect.size.height;
}

+ (NSTimeInterval) keyboardDurationInNotification:(NSNotification *) notification {
    NSValue *animationDurationValue = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    
    NSTimeInterval animationDuration;
    
    [animationDurationValue getValue:&animationDuration];
    
    return animationDuration;
}

+ (CGRect) layoutView:(UIView *)view byChangeHeight:(CGFloat) newHeight {
    CGRect rect = view.frame;
    rect.size.height = newHeight;
    view.frame = rect;
    return rect;
}

+ (CGRect) layoutView:(UIView *)view byChangeY:(CGFloat)deltaY
{
    CGRect rect = view.frame;
    rect.origin.y += deltaY;
    view.frame = rect;
    return rect;
}

+ (long long) fileSizeAtPath:(NSString*) filePath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}

//将十进制转化为二进制,设置返回NSString 长度
+ (NSString *)decimalTOBinary:(uint16_t)tmpid backLength:(int)length
{
    NSString *a = @"";
    while (tmpid)
    {
        a = [[NSString stringWithFormat:@"%d",tmpid%2] stringByAppendingString:a];
        if (tmpid/2 < 1)
        {
            break;
        }
        tmpid = tmpid/2 ;
    }
    
    if (a.length <= length)
    {
        NSMutableString *b = [[NSMutableString alloc]init];;
        for (int i = 0; i < length - a.length; i++)
        {
            [b appendString:@"0"];
        }
        
        a = [b stringByAppendingString:a];
    }
    
    return a;
    
}

+ (NSString *)generateUUID {
    
    CFUUIDRef uuid = CFUUIDCreate(nil);
    
    NSString *uuidString = (NSString*)CFBridgingRelease(CFUUIDCreateString(nil, uuid));
    
    CFRelease(uuid);
    
    return uuidString;
}

/*
 * iphoneStreamer 对iphone4 ios6的适配不好，对ipod touch的适配也不好，因此特别适配这些设备
 * @author haydn 2014.2.17
 */
+ (BOOL)isIphone4AndIOS6{
    UIDevicePlatform  platform = [Util platformType];
    if (platform == UIDevice4iPhone){
        return [Util isCurrentVersionLowerThanRequiredVersion:@"7.0"];
    }
    if (platform == UIDevice3GiPod || platform == UIDevice4GiPod || platform == UIDevice5GiPod) {
        return YES;
    }
    return NO;
}

@end

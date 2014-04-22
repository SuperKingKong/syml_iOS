//
//  Util.h
//  SohuWeibo
//
//  Created by Teng Song on 11-12-21.
//  Copyright (c) 2011年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SYConfig.h"

/*
 ------------------------------------------------------------------------------------
 静态方法
 ------------------------------------------------------------------------------------
 */

#pragma mark -
#pragma mark Marcos
//  log control
#ifdef TARGET_IPHONE_DEBUG
#define SDPRINT(xx, ...)  NSLog(@"%s(%d): " xx, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define SDPRINT(xx, ...)  ((void)0)
#endif
//  assert control
#ifdef TARGET_IPHONE_DEBUG
#define SDASSERT(xx) { if(!(xx)) { SDPRINT(@"SDASSERT failed: %s", #xx); } } ((void)0)
#else
#define SDASSERT(xx) ((void)0)
#endif
//  time manager
#define S_MINUTE    60
#define S_HOUR      (60 * S_MINUTE)
#define S_DAY       (24 * S_HOUR)
#define S_WORKDAY   (5 * S_DAY)
#define S_WEEK      (7 * S_DAY)
#define S_MONTH     (30.5 * S_DAY)
#define S_YEAR      (365 * S_DAY)
//  color manager
#define SRGBCOLOR(r,g,b) [UIColor colorWithRed:r/256.0 green:g/256.0 blue:b/256.0 alpha:1]
#define SRGBACOLOR(r,g,b,a) [UIColor colorWithRed:r/256.0 green:g/256.0 blue:b/256.0 alpha:a]
//  prints the current method's name.
#define SDPRINTMETHODNAME() SDPRINT(@"%s", __PRETTY_FUNCTION__)

// Safe releases
#define BY_RELEASE_SAFELY(__POINTER) { __POINTER = nil; }
//#define BY_RELEASE_SAFELY(__POINTER) if(__POINTER != nil) { [__POINTER release]; __POINTER = nil;}
#define TT_INVALIDATE_TIMER(__TIMER) { [__TIMER invalidate]; __TIMER = nil; }

#define CGRectMake_BC(x,y,w,h) [Util compatibilityCGRectMakeOrignX:x orignY:y width:w height:h]
#define CGRectOffset_BC(r,dx,dy) [Util compatibilityCGrectOffSet:r deltaX:dx deltaY:dy]

#define kMaxCacheCount 1000 //清理缓存时为了保证效率，最多清理1000个

#define kMobileRegex     @"^1(3[0-9]|4[7]|5[0-35-9]|7[067]|8[0-9])\\d{8}$" // 手机号正则表达式
#define kCMMobileRegex   @"^1(34[0-8]|(3[5-9]|4[7]|5[0127-9]|8[23478])\\d)\\d{7}$" // 中国移动手机号正则表达式
#define kCUMobileRegex   @"^1(3[0-2]|5[56]|7[6]|8[56])\\d{8}$" // 中国联通手机号正则表达式
#define kCTMobileRegex   @"^1((33|53|7[07]|8[019])[0-9]|349)\\d{7}$" // 中国电信手机号正则表达式

/** 设备类型 **/

typedef enum 
{
	UIDeviceUnknown,
	
    UIDevice1GiPod,
	UIDevice2GiPod,
	UIDevice3GiPod,
    
    UIDevice1GiPad,
    
	UIDevice1GiPhone,
	UIDevice3GiPhone,
	UIDevice3GSiPhone,
	UIDevice4iPhone,
    UIDevice4SiPhone,
	UIDevice5iPhone,
    
    UIDevice4GiPod,
    UIDevice5GiPod,
	UIDevice2GiPad,
    UIDevice3GiPad,
    
} UIDevicePlatform;


#pragma mark -
#pragma mark Class Methods
@interface Util : NSObject {
    
}
// dir manager
// 公共文档
// 公共音频
// 公共图片
+ (NSString *)pathShare;
+ (NSString *)pathCacheImgs;
+ (NSString *)pathCacheDocs;
+ (NSString *)pathCacheAudio;
// 用户文档
// 用户音频
// 用户DB
// 当前用户目录
+ (NSString *)dirCurrentUserCacheDocs;
+ (NSString *)pathUserCacheDocsWithUID:(NSString *)uid;
+ (NSString *)pathUserCacheAudiosWithUID:(NSString *)uid;
+ (NSString *)pathUserDBWithUID:(NSString *)uid;
+ (NSString *)pathCurrentUser;

+ (NSString *)filePathWith:(NSString *)name isDirectory:(BOOL)isDirectory;
+ (BOOL)createDirectoryIfNecessaryAtPath:(NSString *)path;
+ (BOOL)removePathAt:(NSString *)path;
// 删除文件/文件夹
+ (long long) deletefolderFilesAtPath: (NSString*)folderPath minSize:(long) minSize lastAccessTime:(long) atimes persistfolder:(BOOL) persist;
+ (BOOL)fileIfExist:(NSString *)filePath;
+ (float)fileSize:(NSString *)filePath;
+ (long long) folderSizeAtPath:(NSString*) folderPath;//用C代码实现，效率高
+ (NSString *)fileModifyDate:(NSString *)filePath;
+ (NSString*)randomFileNameWithExt:(NSString *)ext;
+ (NSString*)DataFileNameWithExt:(NSString *)ext;

//  date formate
+ (NSString*)formatRefreshTime:(NSDate *)date;
+ (NSString*)formatRelativeTime:(NSDate *)date;
+ (NSString*)formatDateTime:(NSDate *)date;
+ (NSString*)formatDateWholeYear:(NSDate *)date;
+ (NSString*)formatTime:(NSDate *)date;
+ (NSString*)format:(NSDate *)date style:(NSString*)strFmt;
+ (NSString*)formatTimeWithSecond:(float)second;
+ (NSString *)formatVideoRecordTimeWith:(NSTimeInterval)interval;
+ (NSDate *)parseSWTimeFormat:(NSString *)strTime;

//  isEmptyString
+ (BOOL)isEmptyString:(NSString *)string;

//  url encode
+ (NSString *)base64URLEncodeWith:(NSString *)urlstring;
+ (NSString *)urlEncode:(NSString *)originalString stringEncoding:(NSStringEncoding)stringEncoding;
+ (NSString *)md5Hash:(NSString *)content;

//  image manager
+ (UIImage *)imageWithName:(NSString *)imgname;
+ (UIImage *)imageButtonNavRight;
+ (UIImage *)imageWithName:(NSString *)imgname withResizeCapEdgeInset:(UIEdgeInsets)inset;
+ (UIImage *)imageWithNameAfterAutoResize:(NSString *)imageName;
+ (UIImage *)imageWithName:(NSString *)imgname ofType:(NSString *)imgtype withResizeCapEdgeInset:(UIEdgeInsets)inset;
+ (UIImage *)scaleImageWithName:(NSString*)imgname;
+ (UIImage *)imageWithName:(NSString *)imgname ofType:(NSString *)imgtype;
+ (CGGradientRef)newGradientWithColors:(UIColor**)colors locations:(CGFloat*)locations count:(int)count;
+ (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size;
+(UIImage *)scalAndClipCenterImage:(UIImage *)image targetSize:(CGSize)targetSize;
+ (CGFloat)imageWidthForUpload:(BOOL)isLandScape;
+ (CGFloat)imageQulity:(UIImage *)image;
+ (UIImage *)imgFromView:(UIView *)view;
//  rotate manager
+ (void)rotateView:(UIView *)view From:(UIInterfaceOrientation)currentOrientation To:(UIInterfaceOrientation)targetOrientation With:(BOOL)animated Delegate:(id)delegate;
+ (NSString *)platform;
+ (UIDevicePlatform)platformType;
+ (BOOL)isCurrentVersionLowerThanRequiredVersion:(NSString *)sysVersion;

+ (void)replaceDictionaryValue:(NSMutableDictionary*)dict value:(id)value forKey:(id)key;
+ (void)removeAndReleaseViewSafefly:(UIView *)aview;
+ (NSLocale*) currentLocale;

// system info
+ (NSString *) macAddress;
+ (NSString *)appVersion;
+ (BOOL)isValidNewVersionNotification:(NSString *)newVersionStr;
// Error
+ (NSInteger)intErrorCodeWith:(NSString *)codeString;
+ (NSError *)requestErrorWith:(SErrorCode)errorCode;

+ (BOOL)dictValid:(id)obj;

+ (NSInteger)randIntLessThan:(NSInteger)ceil seedObject:(NSObject *)obj;

#pragma mark - Baiying related

// 将文件 改作以URL缓存
+ (BOOL)moveFile:(NSString *)path toCache:(NSString *)targetUrl type:(BOOL)isImage;
+ (BOOL)isLocalPath:(NSString *)str;
+ (BOOL)isUrlHasThumbnail:(NSString *)url;
+ (NSString *)randomFileNameWithPrefix:(NSString *)path;

//是否支持相机
+ (BOOL)isSupportCamera;

//根据文字计算所占宽高
+(CGSize)sizeForText:(NSString*)text width:(CGFloat)width fontHeight:(CGFloat)fontHeight;

+(CGFloat)heightOfText:(CGSize)size fontHeight:(CGFloat)fontHeight;

+(CGRect)compatibilityCGRectMakeOrignX:(CGFloat)x orignY:(CGFloat)y width:(CGFloat)width height:(CGFloat)height;
+(CGRect)compatibilityCGrectOffSet:(CGRect)frame deltaX:(CGFloat)x deltaY:(CGFloat)y;

+ (NSString *)dataFilePath:(NSString *)fileName;

+ (NSString *)trim:(NSString *)str;


+ (BOOL)string:(NSMutableString *)string shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text maxNumber:(NSInteger)maxNumber willChange:(BOOL *)change ;

+ (BOOL)isMobilePhoneNumber:(NSString *)mobile;
+ (NSString *)mobilePhoneNumberBelong:(NSString *)mobile;

+(UIWindow *)windowWithLevel:(UIWindowLevel)windowLevel;
+ (NSString *)append_t_toStr:(NSString *)strUrl;

/*
 * 将一个网络url，替换其后缀名为制定格式
 *
 */
+ (NSString *)replaceSuffixTo:(NSString *)strSuffix inStr:(NSString *)originStr;

/**
 * 键盘弹起时获得键盘的高度
 */
+ (CGFloat)keyboardHeightInNotification:(NSNotification *) notification;

/**
 * 键盘弹起时获得动画时间
 */
+ (NSTimeInterval) keyboardDurationInNotification:(NSNotification *) notification;

+ (CGRect) layoutView:(UIView *)view byChangeHeight:(CGFloat) newHeight;
/**
 * 通过改变view.frame.orignal.y来改变view的frame
 * @param deltaY view.frame.original.y += deltaY
 */
+ (CGRect) layoutView:(UIView *)view byChangeY:(CGFloat)deltaY;

+ (long long) fileSizeAtPath:(NSString*) filePath;

+ (NSString *)decimalTOBinary:(uint16_t)tmpid backLength:(int)length;

+ (NSString *)generateUUID;

+ (BOOL)isIphone4AndIOS6;
@end

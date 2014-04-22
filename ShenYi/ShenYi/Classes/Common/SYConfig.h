//
//  SYConfig.h
//  SohuWeibo
//
//  Created SY hujinzang on 22-04-2014.
//  Copyright (c) 2014年 SuperKingKong All rights reserved.
//


/*
 ------------------------------------------------------------------------------------
 百应用到的公用设置
 ------------------------------------------------------------------------------------
 */

#pragma mark - File Path
#define kDirCommonCacheAudio    @"common/cache/audios"              //  Audio缓存文件夹
#define kDirCommonCacheImage    @"common/cache/imgs"                //  图片缓存文件夹
#define kDirCommonCacheDocument @"common/cache/docs"                //  文档缓存文件夹
#define kDirCommonDocument      @"common/docs"                      //  程序全局文档文件夹
#define kDirCommonExpression    @"common/expression"                //  表情文件夹

#define kDirUserCacheDocument   @"docs"                             //  当前用户文档缓存文件夹
#define kDirUserCacheAudio      @"audios"                           //  当前用户Audio缓存文件夹
#define kDirUserCacheDB         @"DB"                               //  当前用户DB

#pragma mark - URL Request
#define kBaseURL @"http://api.lanmei.fm"
//#define kBaseURL @"172.16.17.165"

#define kCDNURL @"http://pp.mtc.sohu.com"                       //  cdn加速
//#define kCDNURL
#define kAPPKey @"j8YdUT6GjJnwrNKS6123"                         //  平台标识 key
#define kPicture @"DS*kdl)2s34lstm;;vnb!"                       //  图片接口 key
#define kAPPSecret @"P$0ab$qIzu%ZEZiv!Hhe-(mX0H)^Hzk5I4H$17^)"  //  XAuth认证用 secret
#define kRegisterCodeKey @"EM)jxhIp=ky#5Q8=2r)jX672GwmpUc"      //  一键注册用key
#define kDataAlt @"json"                                        //  服务器支持的response数据类型 json/xml
#define	kSafariUserAgent  @"SohuWeiboIPhone"
#define kWeixinKey @"wx9bcde75604307198"
//跳到应用首页
#define kSohuWeiboiTunesURL @"http://itunes.apple.com/cn/app/id378043162?mt=8"
//@"http://itunes.apple.com/cn/app/id378043162?mt=8" //跳到应用首页

//直接跳到撰写评论界面
#define kSohuWeiboCommentItunesURL @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=378043162"

#define kInvalidCoordinateDegree 181
#define kAPNsToken  @"apnsToken"

#pragma mark - Error Manager

#define KLimiteImageSizeWhenSingleImage
#define KLimiteImageSizeWhenSingleGIF

#define KLimiteImageSizeWhenMultiImages
#define KLimiteImageSizeWhenMutiImagesHasGIF

#pragma mark - Error Manager
#define kErrorDomain @"SohuWeiboIPadErrorDomain"
#define kSResponseErrorObj @"error"                                     //  服务器返回的错误对象本身
#define kSResponseErrorKey @"error"                                      //  服务器返回的错误对象key
#define kSResponseErrorCode @"code"                                     //  服务器返回的错误code 
#define kSResponseErrorMsg  @"msg"                                      //  服务器返回的错误message
#define kSResponseErrorOriginalCodeString @"originalErrorCodeString"    //  解析后的错误对象内保存的服务器原始code字符串
//  ErrorCode < SErrorDefault 为程序内部错误；ErrorCode > SErrorDefault 为服务器或网络错误；ErrorCode = SErrorDefault 为默认未知错误
//  具体的错误描述，可以由SUtil内+requestErrorWith:方法实现
#define Max_Network_ErrorCode 310
typedef enum {
    SErrorNotLogin = 10000,                 //  尚未登录
    SErrorHadLogin,                         //  已经登录
    SErrorInvalidUserWhileChangeActiveUser, //  切换账户时提供的账户信息无效
    SErrorNoneOauthTokenWhileChangeActiveUser,  //  切换帐号时，为basic认证的用户，无oauthToken，需要重新登录
    SErrorDeleteInvalidItem,                //  要删除的数据无效
    SErrorSaveGIF,
    SErrorReadGIF,
    SErrorDefault,
    SErrorOperationCouldNotComplate = 101,  //  操作不能完成
    SErrorLogonFail = 10401,                //  登录失败
    SErrorStatusDeleted = 10407,            //  微博已删除
    SErrorNetworkConnetFail = -1009,        //  网络连接失败
    SErrorNetworkConnetTimeOut = -1001,     //  网络连接超时
    SErrorUrlNotExits = -1002,              //  url不存在
    SErrorPostStatusTimeOut = 19999,        //  上传微博图片，时间超时
    SErrorWillShowPicTooMuch = 999999,      //  显示的图片太大
    SErrorLoginNetWorkFail = 306            //登录web代理无网络
}SErrorCode;


typedef enum {
    USettingsUploadImageQualityHigh,        //  高＝wifi
    USettingsUploadImageQualityMiddle,      //  中＝3G
    USettingsUploadImageQualityLow,         //  低＝GPRS
    USettingsUploadImageQualityAuto         //  自动
}USettingsUploadImageQuality;



#pragma mark - Notification Center
#define kNotificationMoveRight              @"moveRight"                   //侧滑

#define kNotificationSendProgress           @"sendProgress"                //顶部状态栏消息发送进度提示
#define kNotificationPlayStateChanged       @"playStatusChanged"




#define kScreenHeight                       [[UIScreen mainScreen ] bounds].size.height
#define kScreenWidth                        [[UIScreen mainScreen ] bounds].size.width


#define kXmppSYPort                         80                  //非5222

#define k_SY_Error_Domain                   @"SY_Error_Domon"

#define kMsgCountDefault                    50
#define kSubscribeCount                     200

#define kWifiImageSize                      640.0 //原始图最大是1000
#define kWifiImageSizeLS                    640.0 //landScape

#define k3GImageSize                        kWifiImageSize//480.0 //鉴于微博服务器裁剪的大图最大尺寸是 500
#define k3GImageSizeLS                      kWifiImageSizeLS//640.0 //landScape


#define kSmallImage                         220*220 //鉴于网页F_图：160宽，220高，超出截取
#define kCompressRateHigh                   0.3   //高清图压缩参数，适用于WIFI
#define kCompressRateLow                    0.3   //GPRS上传压缩参数



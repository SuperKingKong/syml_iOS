//
//  TTNetworkExtral.m
//  SohuColor
//
//  Created by tengsong on 11-3-29.
//  Copyright 2011 sohu.com. All rights reserved.
//

#import "SThree20Extral.h"

#import <CommonCrypto/CommonDigest.h>
#import <objc/runtime.h>

#import "TTURLCache.h"
#import "Util.h"
#import "SYConfig.h"

const CGFloat ttkDefaultTransitionDuration      = 0.3;

///////////////////////////////////////////////////////////////////////////////////////////////////
CGAffineTransform TTRotateTransformForOrientation(UIInterfaceOrientation orientation) {
	if (orientation == UIInterfaceOrientationLandscapeLeft) {
		return CGAffineTransformMakeRotation(M_PI*1.5);
		
	} else if (orientation == UIInterfaceOrientationLandscapeRight) {
		return CGAffineTransformMakeRotation(M_PI/2);
		
	} else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
		return CGAffineTransformMakeRotation(-M_PI);
		
	} else {
		return CGAffineTransformIdentity;
	}
}



// No-ops for non-retaining objects.
static const void* TTRetainNoOp(CFAllocatorRef allocator, const void *value) { return value; }
static void TTReleaseNoOp(CFAllocatorRef allocator, const void *value) { }

NSMutableArray* TTCreateNonRetainingArray() 
{
	CFArrayCallBacks callbacks = kCFTypeArrayCallBacks;
	callbacks.retain = TTRetainNoOp;
	callbacks.release = TTReleaseNoOp;
	return (NSMutableArray*)CFArrayCreateMutable(nil, 0, &callbacks);
}


@implementation SThree20Extral

+ (NSString*)md5Hash:(NSString*)strCnt 
{
	const char* str = [strCnt UTF8String];
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	CC_MD5(str, strlen(str), result);
	
	return [NSString stringWithFormat:
			@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
			result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
			result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]
			];
}

+ (NSString*)cachePathWithName:(NSString*)name
{
    return [Util filePathWith:name isDirectory:YES];
}
+ (TTURLCache *)sharedDocsCache
{
    TTURLCache *cache = [TTURLCache cacheWithName:kDirCommonCacheDocument];
    cache.disableImageCache = YES;
    return cache;
}

+ (TTURLCache *)sharedAudioCache
{
    TTURLCache *cache = [TTURLCache cacheWithName:kDirCommonCacheAudio];
    cache.disableImageCache = YES;
    return cache;
}

+ (TTURLCache *)sharedImgsCache
{
    TTURLCache *cache = [TTURLCache cacheWithName:kDirCommonCacheImage];
    cache.disableImageCache = YES;
    return cache;
}

+ (TTURLCache *)sharedUsrCache
{    
    TTURLCache *cache = [TTURLCache cacheWithName:[Util dirCurrentUserCacheDocs]];
    cache.disableImageCache = YES;
    return cache;
}
@end

//
//  TTNetworkExtral.h
//  SohuColor
//
//  Created by tengsong on 11-3-29.
//  Copyright 2011 sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark -
#pragma mark TTDebug
/**
 *
 * Provided in this header are a set of debugging tools. This is meant quite literally, in that
 * all of the macros below will only function when the DEBUG preprocessor macro is specified.
 *
 * TTDASSERT(<statement>);
 * If <statement> is false, the statement will be written to the log and if you are running in
 * the simulator with a debugger attached, the app will break on the assertion line.
 *
 * TTDPRINT(@"formatted log text %d", param1);
 * Print the given formatted text to the log.
 *
 * TTDPRINTMETHODNAME();
 * Print the current method name to the log.
 *
 * TTDCONDITIONLOG(<statement>, @"formatted log text %d", param1);
 * If <statement> is true, then the formatted text will be written to the log.
 *
 * TTDINFO/TTDWARNING/TTDERROR(@"formatted log text %d", param1);
 * Will only write the formatted text to the log if TTMAXLOGLEVEL is greater than the respective
 * TTD* method's log level. See below for log levels.
 *
 * The default maximum log level is TTLOGLEVEL_WARNING.
 *
 **/
#define TTLOGLEVEL_WARNING  3

#ifndef TTMAXLOGLEVEL
#define TTMAXLOGLEVEL TTLOGLEVEL_WARNING
#endif

// The general purpose logger. This ignores logging levels.

#ifdef TARGET_IPHONE_DEBUG
#define TTDPRINT(xx, ...)  NSLog(@"%s(%d): " xx, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define TTDPRINT(xx, ...)  ((void)0)
#endif // #ifdef DEBUG

// Prints the current method's name.
#define TTDPRINTMETHODNAME() TTDPRINT(@"%s", __PRETTY_FUNCTION__)

// Debug-only assertions.
#ifdef S_TARGET_DEBUG

#define TTDASSERT(xx) { if(!(xx)) { TTDPRINT(@"TTDASSERT failed: %s", #xx); } } ((void)0)

#else
#define TTDASSERT(xx) ((void)0)
#endif // #ifdef DEBUG


#ifdef S_TARGET_DEBUG
#define TTDCONDITIONLOG(condition, xx, ...) { if ((condition)) { \
TTDPRINT(xx, ##__VA_ARGS__); \
} \
} ((void)0)
#else
#define TTDCONDITIONLOG(condition, xx, ...) ((void)0)
#endif // #ifdef DEBUG

#if TTLOGLEVEL_WARNING <= TTMAXLOGLEVEL
#define TTDWARNING(xx, ...)  TTDPRINT(xx, ##__VA_ARGS__)
#else
#define TTDWARNING(xx, ...)  ((void)0)
#endif // #if TTLOGLEVEL_WARNING <= TTMAXLOGLEVEL



#pragma mark -
#pragma mark TTUtil
/**
 * Borrowed from Apple's AvailabiltyInternal.h header. There's no reason why we shouldn't be
 * able to use this macro, as it's a gcc-supported flag.
 * Here's what we based it off of.
 * __AVAILABILITY_INTERNAL_DEPRECATED         __attribute__((deprecated))
 */
#define __TTDEPRECATED_METHOD __attribute__((deprecated))

///////////////////////////////////////////////////////////////////////////////////////////////////
// Errors

#define TT_ERROR_DOMAIN @"sohu.com"

#define TT_EC_INVALID_IMAGE 101


///////////////////////////////////////////////////////////////////////////////////////////////////
// Flags

/**
 * For when the flag might be a set of bits, this will ensure that the exact set of bits in
 * the flag have been set in the value.
 */
#define IS_MASK_SET(value, flag)  (((value) & (flag)) == (flag))


///////////////////////////////////////////////////////////////////////////////////////////////////
// Time

#define TT_MINUTE 60
#define TT_HOUR   (60 * TT_MINUTE)
#define TT_DAY    (24 * TT_HOUR)
#define TT_5_DAYS (5 * TT_DAY)
#define TT_WEEK   (7 * TT_DAY)
#define TT_MONTH  (30.5 * TT_DAY)
#define TT_YEAR   (365 * TT_DAY)

///////////////////////////////////////////////////////////////////////////////////////////////////
// Safe releases

#define TT_RELEASE_SAFELY(__POINTER) { [__POINTER release]; __POINTER = nil; }
#define BY_RELEASE_SAFELY(__POINTER) { __POINTER = nil; }
#define TT_INVALIDATE_TIMER(__TIMER) { [__TIMER invalidate]; __TIMER = nil; }

// Release a CoreFoundation object safely.
#define TT_RELEASE_CF_SAFELY(__REF) { if (nil != (__REF)) { CFRelease(__REF); __REF = nil; } }

#define RGBCOLOR(r,g,b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

NSMutableArray* TTCreateNonRetainingArray();


#pragma mark -
#pragma mark TTGlobalUICommon
/**
 * @return the rotation transform for a given orientation.
 */
CGAffineTransform TTRotateTransformForOrientation(UIInterfaceOrientation orientation);

/**
 * The standard duration length for a transition.
 * @const 0.3 seconds
 */
extern const CGFloat ttkDefaultTransitionDuration;

/**
 * Deprecated macros for common constants.
 */
#define TT_TRANSITION_DURATION      ttkDefaultTransitionDuration

typedef enum URLRequestType_E
{
    URLRequestDocument,
    URLRequestImage,
}URLRequestType;

@class TTURLCache;
@interface SThree20Extral: NSObject {
	
}

+ (NSString *)md5Hash:(NSString *)strCnt;

+ (NSString*)cachePathWithName:(NSString*)name;
+ (TTURLCache *)sharedDocsCache;
+ (TTURLCache *)sharedUsrCache;
+ (TTURLCache *)sharedImgsCache;
+ (TTURLCache *)sharedAudioCache;

@end




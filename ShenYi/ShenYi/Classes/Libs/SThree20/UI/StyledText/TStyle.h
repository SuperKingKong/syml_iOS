//
//  TStyle.h
//  app10
//
//  Created by wang fei on 10-12-9.
//  Copyright 2010 sohu.inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kGroupAddressFontSize	15.0					// group 正文字体大小
#define kTextLinkColor			RGBCOLOR(82,119,135)	// feed连接颜色

@interface TStyle : NSObject {

	UIFont*		_font;
	UIColor*	_color;
	BOOL		_bhighlighted;
}
@property(nonatomic,retain)UIFont* font;
@property(nonatomic,retain)UIColor* color;
@property BOOL highlighted;

+ (TStyle*)styleWithFont:(UIFont*)font color:(UIColor*)color;
+ (TStyle*)styleWithText;
+ (TStyle*)styleWithBoxText;

- (void)drawBoxStyle:(CGRect)rect context:(CGContextRef)ctf;

@end

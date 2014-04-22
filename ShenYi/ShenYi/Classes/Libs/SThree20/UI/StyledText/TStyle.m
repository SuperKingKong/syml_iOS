//
//  TStyle.m
//  app10
//
//  Created by wang fei on 10-12-9.
//  Copyright 2010 sohu.inc. All rights reserved.
//

#import "TStyle.h"
#import "SThree20Global.h"

@implementation TStyle

@synthesize font = _font, color = _color, highlighted = _bHighlighted;

+ (TStyle*)styleWithFont:(UIFont*)font color:(UIColor*)color
{
	TStyle* style = [[self alloc] init];
	style.font = font;
	style.color = color;
	return style;
}

+ (TStyle*)styleWithText
{
	return [self styleWithFont:[UIFont systemFontOfSize:kGroupAddressFontSize] color:[UIColor blackColor]];
}


+ (TStyle*)styleWithBoxText
{
	return [self styleWithFont:[UIFont systemFontOfSize:kGroupAddressFontSize] color:kTextLinkColor];
}

- (id)init
{
	if (self = [super init]) {
		_bHighlighted = NO;
	}
	return self;
}

- (void)drawBoxStyle:(CGRect)rect context:(CGContextRef)ctf
{
	if (_bHighlighted == NO)
		return;
	
	CGRect rcBox = CGRectInset(rect, -3, 0);
	CGContextSaveGState(ctf);
	float radius = 3.0f;
    
    CGContextBeginPath(ctf);
	CGContextSetGrayFillColor(ctf, 0.5, 0.6);
	
	CGContextMoveToPoint(ctf, CGRectGetMinX(rcBox) + radius, CGRectGetMinY(rcBox));
    CGContextAddArc(ctf, CGRectGetMaxX(rcBox) - radius, CGRectGetMinY(rcBox) + radius, radius, 3 * M_PI / 2, 0, 0);
    CGContextAddArc(ctf, CGRectGetMaxX(rcBox) - radius, CGRectGetMaxY(rcBox) - radius, radius, 0, M_PI / 2, 0);
    CGContextAddArc(ctf, CGRectGetMinX(rcBox) + radius, CGRectGetMaxY(rcBox) - radius, radius, M_PI / 2, M_PI, 0);
    CGContextAddArc(ctf, CGRectGetMinX(rcBox) + radius, CGRectGetMinY(rcBox) + radius, radius, M_PI, 3 * M_PI / 2, 0);
	
    CGContextClosePath(ctf);
    CGContextFillPath(ctf);
	
	CGContextRestoreGState(ctf);
}

- (void)dealloc {
	[_font release];
	[_color release];
    [super dealloc];
}

@end

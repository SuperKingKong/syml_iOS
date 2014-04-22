//
//  TTStyledNodeAdditions.m
//  TwitterIphone20
//
//  Created by tengsong on 10-12-26.
//  Copyright 2010 Sohu MTC. All rights reserved.
//

#import "TTStyledNodeAdditions.h"

@implementation TTStyledLinkNode(LinkType)

- (TTStyledLinkType)linkType
{
	if ([self.URL hasPrefix:@"@"]) {
		return TTStyledLinkUser;
	}
	if ([self.URL hasPrefix:@"#"]) {
		return TTStyledLinkTopic;
	}
	if ([self.URL hasPrefix:@"*"]) {
		return TTStyledLinkTransImage;
	}    
	return TTStyledLinkURL;
}

@end

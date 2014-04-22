//
// Copyright 2009-2010 Facebook
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "SThree20Global.h"
#import "TTStyledTextLabel.h"
#import "TTStyledNode.h"
#import "TTStyledFrame.h"
//#import "UIViewAdditions.h"

///////////////////////////////////////////////////////////////////////////////////////////////////
// global

//static const CGFloat kCancelHighlightThreshold = 4;

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTStyledTextLabel

@synthesize text = _text, font = _font, textColor = _textColor,
            highlightedTextColor = _highlightedTextColor, textAlignment = _textAlignment,
            contentInset = _contentInset, highlighted = _highlighted,
            highlightedNode = _highlightedNode, delegate = _delegate,lineMarge = _lineMarge;

///////////////////////////////////////////////////////////////////////////////////////////////////
// private

// UITableView looks for this function and crashes if it is not found when you select a cell
- (BOOL)isHighlighted {
  return _highlighted;
}

- (void)setHighlightedFrame:(TTStyledBoxFrame*)frame{
  if (frame != _highlightedFrame) {

    TTStyledBoxFrame* affectFrame = frame ? frame : _highlightedFrame;
    NSString* className = affectFrame.element.className;
    if (!className && [affectFrame.element isKindOfClass:[TTStyledLinkNode class]]) {
      className = @"linkText:";
    }
    
    if (className && [className rangeOfString:@":"].location != NSNotFound) 
	{
      if (frame) {
        
		  frame.style.highlighted = YES;
        [_highlightedFrame release];
        _highlightedFrame = [frame retain];
        [_highlightedNode release];
        _highlightedNode = [frame.element retain];
      } else {

		  _highlightedFrame.style.highlighted = NO;
		  
		  if (_delegate && [_highlightedFrame.element isKindOfClass:[TTStyledLinkNode class]])
		  {
			  // 该link有link文本和真实url的区别
			  //
			  TTStyledLinkNode* node = (TTStyledLinkNode*)_highlightedFrame.element;
			  TTStyledLinkType sltype = [node linkType];
              if (node.URL != nil && node.URL.length > 1) {
                  NSString *txt = sltype == TTStyledLinkURL ? node.URL : [node.URL substringFromIndex:1];
                  NSString *topic = [txt stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                  if (_delegate && [(NSObject *)_delegate respondsToSelector:@selector(tstyledTextLabel:didSelectedText:Type:)]) {
                      [_delegate tstyledTextLabel:self didSelectedText:topic Type:sltype];
                  }
              }
		  }
        TT_RELEASE_SAFELY(_highlightedFrame);
        TT_RELEASE_SAFELY(_highlightedNode);
      }

      [self setNeedsDisplay];
    }
  }
}

- (NSString*)combineTextFromFrame:(TTStyledTextFrame*)fromFrame toFrame:(TTStyledTextFrame*)toFrame {
  NSMutableArray* strings = [NSMutableArray array];
  for (TTStyledTextFrame* frame = fromFrame; frame && frame != toFrame;
       frame = (TTStyledTextFrame*)frame.nextFrame) {
    [strings addObject:frame.text];
  }
  return [strings componentsJoinedByString:@""];
}

- (void)addAccessibilityElementFromFrame:(TTStyledTextFrame*)fromFrame
        toFrame:(TTStyledTextFrame*)toFrame withEdges:(UIEdgeInsets)edges {

}

- (UIEdgeInsets)edgesForRect:(CGRect)rect {
  return UIEdgeInsetsMake(rect.origin.y, rect.origin.x,
                          rect.origin.y+rect.size.height,
                          rect.origin.x+rect.size.width);
}

- (void)addAccessibilityElementsForNode:(TTStyledNode*)node {
}

- (NSMutableArray*)accessibilityElements {
  if (!_accessibilityElements) {
    _accessibilityElements = [[NSMutableArray alloc] init];
    [self addAccessibilityElementsForNode:_text.rootNode];
  }
  return _accessibilityElements;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    _text = nil;
    _font = nil;
    _textColor = nil;
    _highlightedTextColor = nil;
    _textAlignment = UITextAlignmentLeft;
    _contentInset = UIEdgeInsetsZero;
    _highlighted = NO;
    _highlightedNode = nil;
    _highlightedFrame = nil;
    _accessibilityElements = nil;
	  
	  _lineMarge = 0;
    
	  self.font = [UIFont systemFontOfSize:kGroupAddressFontSize];
    self.backgroundColor = [UIColor whiteColor];
    self.contentMode = UIViewContentModeRedraw;
	  _longPress = NO;
  }
  return self;
}

- (void)dealloc {
  _text.delegate = nil;
  TT_RELEASE_SAFELY(_text);
  TT_RELEASE_SAFELY(_font);
  TT_RELEASE_SAFELY(_textColor);
  TT_RELEASE_SAFELY(_highlightedTextColor);
  TT_RELEASE_SAFELY(_highlightedNode);
  TT_RELEASE_SAFELY(_highlightedFrame);
  TT_RELEASE_SAFELY(_accessibilityElements);
  [super dealloc];
}
////////////////////////////////////////////
//Action
-(void)showActionSheet
{
	if (_delegate && [(NSObject *)_delegate respondsToSelector:@selector(tstyledTextLabelLongPress:)]) {
		_longPress =YES;
		[_delegate tstyledTextLabelLongPress:self];
	}
	_highlightedFrame.style.highlighted = NO;
	TT_RELEASE_SAFELY(_highlightedFrame);
	TT_RELEASE_SAFELY(_highlightedNode);
	 [self setNeedsDisplay];
}
- (void)cancelAutoLongPress
{
	[TTStyledTextLabel cancelPreviousPerformRequestsWithTarget:self selector:@selector(showActionSheet) object:nil];
}
-(void)autoLongPress
{
	[self cancelAutoLongPress];
	[self performSelector:@selector(showActionSheet) withObject:nil afterDelay:1];
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// UIResponder

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
  UITouch* touch = [touches anyObject];
  CGPoint point = [touch locationInView:self];
  point.x -= _contentInset.left;
  point.y -= _contentInset.top;
  
  TTStyledBoxFrame* frame = [_text hitTest:point];
  if (frame) 
  {
    [self setHighlightedFrame:frame];
      return;
  }
  
	[self autoLongPress];
	_longPress = NO;
  [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
  [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {

    if (_highlightedNode) {
      [_highlightedNode performDefaultAction];  
		if (_longPress) {
			_longPress = NO;
		}
		else
		{
			[self setHighlightedFrame:nil];
            return;
		}
  }
	[self cancelAutoLongPress];
  // We definitely don't want to call this if the label is inside a TTTableView, because
  // it winds up calling touchesEnded on the table twice, triggering the link twice
  [super touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
	[self cancelAutoLongPress];
  [super touchesCancelled:touches withEvent:event];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIView

- (void)drawRect:(CGRect)rect {
	
  if (_highlighted) {
    [self.highlightedTextColor setFill];
  } else {
    [self.textColor setFill];
  }
  
  CGPoint origin = CGPointMake(rect.origin.x + _contentInset.left,
                               rect.origin.y + _contentInset.top);
  [_text drawAtPoint:origin highlighted:_highlighted];
}

- (void)layoutSubviews {
  [super layoutSubviews];
  CGFloat newWidth = self.frame.size.width - (_contentInset.left + _contentInset.right);
  if (newWidth != _text.width) {
    // Remove the highlighted node+frame when resizing the text
    self.highlightedNode = nil;
  }
  
  _text.width = newWidth;
}

- (CGSize)sizeThatFits:(CGSize)size {
  [self layoutIfNeeded];
  return CGSizeMake(_text.width + (_contentInset.left + _contentInset.right),
                    _text.height+ (_contentInset.top + _contentInset.bottom));
}


//////////////////////////////////////////////////////////////////////////////////////////////////
// UIAccessibilityContainer

- (id)accessibilityElementAtIndex:(NSInteger)index {
  return [[self accessibilityElements] objectAtIndex:index];
}

- (NSInteger)accessibilityElementCount {
  return [self accessibilityElements].count;
}

- (NSInteger)indexOfAccessibilityElement:(id)element {
  return [[self accessibilityElements] indexOfObject:element];
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// UIResponderStandardEditActions

- (void)copy:(id)sender {
  NSString* text = _text.rootNode.outerText;
  UIPasteboard* pasteboard = [UIPasteboard generalPasteboard];
  [pasteboard setValue:text forPasteboardType:@"public.utf8-plain-text"];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTStyledTextDelegate

- (void)styledTextNeedsDisplay:(TTStyledText*)text {
  [self setNeedsDisplay];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (void)setText:(TTStyledText*)text {
  if (text != _text) {
    _text.delegate = nil;
    [_text release];
    TT_RELEASE_SAFELY(_accessibilityElements);
    _text = [text retain];
    _text.delegate = self;
    _text.font = _font;
    [self setNeedsLayout];
    [self setNeedsDisplay];
  }
}

- (NSString*)html {
  return [_text description];
}

- (void)setHtml:(NSString*)html {
  self.text = [TTStyledText textFromXHTML:html];
	self.text.lineMarge = _lineMarge;
}

- (void)setFont:(UIFont*)font {
  if (font != _font) {
    [_font release];
    _font = [font retain];
    _text.font = _font;
    [self setNeedsLayout];
  }
}

/*
- (void) setLineMarge:(CGFloat)line
{
	_text.lineMarge = line;
	_lineMarge = line;
}
*/
- (UIColor*)textColor {
  if (!_textColor) {
    _textColor = [[UIColor blackColor] retain];
  }
  return _textColor;
}

- (void)setTextColor:(UIColor*)textColor {
  if (textColor != _textColor) {
    [_textColor release];
    _textColor = [textColor retain];
    [self setNeedsDisplay];
  }
}

- (UIColor*)highlightedTextColor {
  if (!_highlightedTextColor) {
    _highlightedTextColor = [[UIColor blackColor] retain];
  }
  return _highlightedTextColor;
}

- (void)setHighlightedNode:(TTStyledElement*)node {
  if (node != _highlightedNode) {
    if (!node) {
      [self setHighlightedFrame:nil];
    } else {
      [_highlightedNode release];
      _highlightedNode = [node retain];
    }
  }  
}

@end

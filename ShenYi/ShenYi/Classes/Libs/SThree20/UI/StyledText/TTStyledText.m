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

#import "TTStyledText.h"
#import "TTStyledNode.h"
#import "TTStyledFrame.h"
#import "TTStyledLayout.h"
#import "TTStyledTextParser.h"
#import "SThree20Global.h"

//////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TTStyledText

@synthesize delegate = _delegate, rootNode = _rootNode, font = _font, width = _width,
            height = _height, lineMarge = _lineMarge;

//////////////////////////////////////////////////////////////////////////////////////////////////
// class public

+ (TTStyledText*)textFromXHTML:(NSString*)source {
  return [self textFromXHTML:source lineBreaks:NO URLs:YES];
}

+ (TTStyledText*)textFromXHTML:(NSString*)source lineBreaks:(BOOL)lineBreaks URLs:(BOOL)URLs {
  TTStyledTextParser* parser = [[[TTStyledTextParser alloc] init] autorelease];
  parser.parseLineBreaks = lineBreaks;
  parser.parseURLs = URLs;
  [parser parseXHTML:source];
  if (parser.rootNode) {
    return [[[TTStyledText alloc] initWithNode:parser.rootNode] autorelease];
  } else {
    return nil;
  }
}

+ (TTStyledText*)textWithURLs:(NSString*)source {
  return [self textWithURLs:source lineBreaks:NO];
}

+ (TTStyledText*)textWithURLs:(NSString*)source lineBreaks:(BOOL)lineBreaks {
  TTStyledTextParser* parser = [[[TTStyledTextParser alloc] init] autorelease];
  parser.parseLineBreaks = lineBreaks;
  parser.parseURLs = YES;
  [parser parseText:source];
  if (parser.rootNode) {
    return [[[TTStyledText alloc] initWithNode:parser.rootNode] autorelease];
  } else {
    return nil;
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// private


- (TTStyledFrame*)getFrameForNode:(TTStyledNode*)node inFrame:(TTStyledFrame*)frame {
  while (frame) {
    if ([frame isKindOfClass:[TTStyledBoxFrame class]]) {
      TTStyledBoxFrame* boxFrame = (TTStyledBoxFrame*)frame;
      if (boxFrame.element == node) {
        return boxFrame;
      }
      TTStyledFrame* found = [self getFrameForNode:node inFrame:boxFrame.firstChildFrame];
      if (found) {
        return found;
      }
    } else if ([frame isKindOfClass:[TTStyledTextFrame class]]) {
      TTStyledTextFrame* textFrame = (TTStyledTextFrame*)frame;
      if (textFrame.node == node) {
        return textFrame;
      }
    } 
	frame = frame.nextFrame;
  }
  return nil;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithNode:(TTStyledNode*)rootNode {
  if (self = [self init]) {
    _rootNode = [rootNode retain];
  }
  return self;
}

- (id)init {
  if (self = [super init]) {
    _rootNode = nil;
    _rootFrame = nil;
    _font = nil;
    _width = 0;
    _height = 0;
	  
	  _lineMarge = 0;
  }
  return self;
}

- (void)dealloc {

  TT_RELEASE_SAFELY(_rootNode);
  TT_RELEASE_SAFELY(_rootFrame);
  TT_RELEASE_SAFELY(_font);
  [super dealloc];
}

- (NSString*)description {
  return [self.rootNode outerText];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (void)setDelegate:(id<TTStyledTextDelegate>)delegate {
  if (_delegate != delegate) {
    _delegate = delegate;

  }
}

- (TTStyledFrame*)rootFrame {
  [self layoutIfNeeded];
  return _rootFrame;
}

- (void)setFont:(UIFont*)font {
  if (font != _font) {
    [_font release];
    _font = [font retain];
    [self setNeedsLayout];
  }
}

- (void)setWidth:(CGFloat)width {
  if (width != _width) {
    _width = width;
    [self setNeedsLayout];
  }
}

- (CGFloat)height {
  [self layoutIfNeeded];
  return _height;
}

- (BOOL)needsLayout {
  return !_rootFrame;
}

- (void)layoutFrames {
  TTStyledLayout* layout = [[TTStyledLayout alloc] initWithRootNode:_rootNode];
	layout.lineMarge = _lineMarge;
  layout.width = _width;
  layout.font = _font;
  [layout layout:_rootNode];
  
  [_rootFrame release];
  _rootFrame = [layout.rootFrame retain];
  _height = ceil(layout.height);

  [layout release];
}

- (void)layoutIfNeeded {
  if (!_rootFrame) {
    [self layoutFrames];
  }
}

- (void)setNeedsLayout {
  TT_RELEASE_SAFELY(_rootFrame);
  _height = 0;
}

- (void)drawAtPoint:(CGPoint)point {
  [self drawAtPoint:point highlighted:NO];
}

- (void)drawAtPoint:(CGPoint)point highlighted:(BOOL)highlighted {
  CGContextRef ctx = UIGraphicsGetCurrentContext();
  CGContextSaveGState(ctx);
  CGContextTranslateCTM(ctx, point.x, point.y);

  TTStyledFrame* frame = self.rootFrame;
  while (frame) {
    [frame drawInRect:frame.bounds];
    frame = frame.nextFrame;
	  
	  //NSLog(@"class:%@\n",[frame class]);
  }

  CGContextRestoreGState(ctx);
}

- (TTStyledBoxFrame*)hitTest:(CGPoint)point {
  return [self.rootFrame hitTest:point];
}

- (TTStyledFrame*)getFrameForNode:(TTStyledNode*)node {
  return [self getFrameForNode:node inFrame:_rootFrame];
}

- (void)addChild:(TTStyledNode*)child {
  if (!_rootNode) {
    self.rootNode = child;
  } else {
    TTStyledNode* previousNode = _rootNode;
    TTStyledNode* node = _rootNode.nextSibling;
    while (node) {
      previousNode = node;
      node = node.nextSibling;
    }
    previousNode.nextSibling = child;
  }
}

- (void)addText:(NSString*)text {
  [self addChild:[[[TTStyledTextNode alloc] initWithText:text] autorelease]];
}

- (void)insertChild:(TTStyledNode*)child atIndex:(NSInteger)index {
  if (!_rootNode) {
    self.rootNode = child;
  } else if (index == 0) {
    child.nextSibling = _rootNode;
    self.rootNode = child;
  } else {
    NSInteger i = 0;
    TTStyledNode* previousNode = _rootNode;
    TTStyledNode* node = _rootNode.nextSibling;
    while (node && i != index) {
      ++i;
      previousNode = node;
      node = node.nextSibling;
    }
    child.nextSibling = node;
    previousNode.nextSibling = child;
  }
}

- (TTStyledNode*)getElementByClassName:(NSString*)className {
  TTStyledNode* node = _rootNode;
  while (node) {
    if ([node isKindOfClass:[TTStyledElement class]]) {
      TTStyledElement* element = (TTStyledElement*)node;
      if ([element.className isEqualToString:className]) {
        return element;
      }

      TTStyledNode* found = [element getElementByClassName:className];
      if (found) {
        return found;
      }
    }
    node = node.nextSibling;
  }
  return nil;
}

@end

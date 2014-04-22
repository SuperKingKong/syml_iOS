//
// Copyright 2009-2011 Facebook
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

#import "TTImageView.h"
#import "UIImageAdditions.h"
#import "Util.h"

@interface TTImageView(Privated)

- (void)drawContent:(CGRect)rect;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTImageView

@synthesize urlPath             = _urlPath;
@synthesize image               = _image;
@synthesize defaultImage        = _defaultImage;
@synthesize autoresizesToImage  = _autoresizesToImage;
@synthesize showAnimated        = _showAnimated;
@synthesize clipToSize          = _clipToSize;
@synthesize delegate = _delegate;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    //_autoresizesToImage = NO;
    //_showAnimated = YES;
      self.autoresizesToImage = NO;
      self.clipToSize = NO;
      self.showAnimated = NO;
      self.urlPath = nil;
      self.image = nil;
      self.defaultImage = nil;
      self.delegate = nil;
      _request = nil;
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
    self.delegate = nil;
    [_request cancel];
    [_request release];
    _request = nil;
    self.urlPath = nil;
    self.image = nil;
    self.defaultImage = nil;
    [super dealloc];
    
//  _delegate = nil;
//  [_request cancel];
//  TT_RELEASE_SAFELY(_request);
//  TT_RELEASE_SAFELY(_urlPath);
//    TT_RELEASE_SAFELY(_image);
//    TT_RELEASE_SAFELY(_defaultImage);
//  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIView


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)drawRect:(CGRect)rect {
	[self drawContent:self.bounds];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTView


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)drawContent:(CGRect)rect {
  if (nil != self.image) {
      if (self.showAnimated) {
          self.alpha = 0.0;
          [self.image drawInRect:rect contentMode:self.contentMode];
          [UIView beginAnimations:@"ShowImageAnimation" context:nil];
          [UIView setAnimationDuration:0.3];
          self.alpha = 1.0;
          [UIView commitAnimations];
      }else {
          [self.image drawInRect:rect contentMode:self.contentMode];
      }

  } else {
//    [self.defaultImage drawInRect:rect contentMode:self.contentMode];
      // defaultImage contentModel为center
    [self.defaultImage drawInRect:rect contentMode:UIViewContentModeCenter];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTURLRequestDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)requestDidStartLoad:(TTURLRequest*)request {
  [_request release];
  _request = [request retain];

  [self imageViewDidStartLoad];
  if (self.delegate && [self.delegate respondsToSelector:@selector(imageViewDidStartLoad:)]) {
    [self.delegate imageViewDidStartLoad:self];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)requestDidFinishLoad:(TTURLRequest*)request {
  TTURLImageResponse* response = request.response;
    self.image = response.image;
    [self setNeedsDisplay];
    //[self setImage:response.image];

  TT_RELEASE_SAFELY(_request);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)request:(TTURLRequest*)request didFailLoadWithError:(NSError*)error {
  TT_RELEASE_SAFELY(_request);

  [self imageViewDidFailLoadWithError:error];
  if (self.delegate && [self.delegate respondsToSelector:@selector(imageView:didFailLoadWithError:)]) {
    [self.delegate imageView:self didFailLoadWithError:error];
  }
    
    NSLog(@"error, image load fail");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)requestDidCancelLoad:(TTURLRequest*)request {
  TT_RELEASE_SAFELY(_request);
    
//    if (self.delegate && [self.delegate respondsToSelector:@selector(imageViewDidCancelLoad:)]) {
//        [self.delegate imageViewDidCancelLoad:self];
//    }

  [self imageViewDidFailLoadWithError:nil];
  if (self.delegate && [self.delegate respondsToSelector:@selector(imageView:didFailLoadWithError:)]) {
    [self.delegate imageView:self didFailLoadWithError:nil];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTURLRequestDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isLoading {
  return !!_request;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isLoaded {
  return nil != self.image && self.image != self.defaultImage;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)reload {
  if (nil == _request && nil != self.urlPath) {
    UIImage* image = [[TTURLCache sharedImgsCache] imageForURL:self.urlPath];

    if (nil != image) {
      self.image = image;

    } else {
      TTURLRequest* request = [TTURLRequest requestWithURL:_urlPath delegate:self];
        request.requestCache = [TTURLCache sharedImgsCache];
      request.response = [[[TTURLImageResponse alloc] init] autorelease];

      if (![request send]) {
        // Put the default image in place while waiting for the request to load
        if (self.defaultImage && nil == self.image) {
            [self setNeedsDisplay];
        }
      }
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)stopLoading {
  [_request cancel];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)imageViewDidStartLoad {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)imageViewDidLoadImage:(UIImage*)image {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)imageViewDidFailLoadWithError:(NSError*)error {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark public

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setImage:(UIImage*)image {
	if (image != _image) {
		[_image release];
		_image = [image retain];
		
		CGRect frame = self.frame;
		if (self.autoresizesToImage) {
			self.width = _image.size.width;
			self.height = _image.size.height;
			
		} else {
			// Logical flow:
			// If no width or height have been specified, then autoresize to the image.
			if (!frame.size.width && !frame.size.height) {
				self.width = _image.size.width;
				self.height = _image.size.height;
				
				// If a width was specified, but no height, then resize the image with the correct aspect
				// ratio.
				
			} else if (frame.size.width && !frame.size.height) {
				self.height = floor((_image.size.height/_image.size.width) * frame.size.width);
				
				// If a height was specified, but no width, then resize the image with the correct aspect
				// ratio.
				
			} else if (frame.size.height && !frame.size.width) {
				self.width = floor((_image.size.width/_image.size.height) * frame.size.height);
			}
			
			// If both were specified, leave the frame as is.
		}
		
		if (nil == self.defaultImage || _image != self.defaultImage) {
			// Only send the notification if there's no default image or this is a new image.
			[self imageViewDidLoadImage:_image];
			if (self.delegate && [self.delegate respondsToSelector:@selector(imageView:didLoadImage:)]) {
				[self.delegate imageView:self didLoadImage:_image];
			}
		}
        if (_clipToSize) {
            UIImage *scaleImg = [Util scalAndClipCenterImage:_image targetSize:self.bounds.size];
            TT_RELEASE_SAFELY(_image);
            _image = [scaleImg retain];            
        }
		[self setNeedsDisplay];
	}
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)unsetImage {
  [self stopLoading];
  self.image = nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setUrlPath:(NSString*)urlPath {
  // Check for no changes.
  if (nil != self.image && nil != self.urlPath && [urlPath isEqualToString:self.urlPath]) {
    return;
  }

  [self stopLoading];

  {
    NSString* urlPathCopy = [urlPath copy];
    [_urlPath release];
    _urlPath = urlPathCopy; 
  }

  if (nil == self.urlPath || 0 == self.urlPath.length) {
    // Setting the url path to an empty/nil path, so let's restore the default image.
      [self setNeedsDisplay];

  } else {
    [self reload];
  }
}


@end


@implementation TTImageView(extral)

///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)width {
	return self.frame.size.width;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setWidth:(CGFloat)width {
	CGRect frame = self.frame;
	frame.size.width = width;
	self.frame = frame;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)height {
	return self.frame.size.height;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setHeight:(CGFloat)height {
	CGRect frame = self.frame;
	frame.size.height = height;
	self.frame = frame;
}

@end


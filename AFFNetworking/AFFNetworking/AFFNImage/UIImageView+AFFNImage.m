//
//  UIImageView+AFFNImage.m
//  AFFNetworking
//
//  Created by Andrew Apperley on 2013-08-20.
//  Copyright (c) 2013 AFApps. All rights reserved.
//
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

#import "UIImageView+AFFNImage.h"
#import "AFFNImageManager.h"
#import <objc/runtime.h>

@implementation UIImageView (AFFNImage)

//Used to retrieve the image url later for caching
static char imageUrlKey;

/*
 * Init function to create an image with a Placeholder image, imageURL of the end-result image, to cache it, and when it expires
 *
 * @params
 * CGRect frame
 * UIImage phImage
 * NSString imageURL
 * NSDate expiry
 * BOOL cache
 */

- (UIImageView *)initWithFrame:(CGRect)frame andPlaceholderImage:(UIImage *)phImage andImageURL:(NSString *)imageURL andExpiry:(NSDate *)expiry andToCache:(BOOL)cache
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self.frame = frame;
        [self setLimageURL:imageURL];
        self.image = [AFFNImageManager doesImageExist:imageURL] ? [AFFNImageManager returnCachedImage:imageURL] : phImage;
        
        if([self.image isEqual:phImage])
            [self callURLForImage:imageURL withExpiry:expiry andCache:cache];
    }
    return self;
}

- (NSString *)limageURL
{
    return objc_getAssociatedObject(self, &imageUrlKey);
}

- (void)setLimageURL:(NSString *)limageURL
{
    objc_setAssociatedObject(self, &imageUrlKey, limageURL, OBJC_ASSOCIATION_COPY);
}

//The Placeholder image is already present and when this method is called the activity spinner starts animating and it makes a GET call
//to hit the URL provided and then converts the byte data to a UIImage - removing the spinner from memory and switching the PH image with
//the new image. If Caching was enabled for this image it willsend the UIImage with the imageURL and expiry date over to the manager so
//it can be cached into the /CacheImage/ folder

- (void)callURLForImage:(NSString *)imageURL withExpiry:(NSDate *)expiry andCache:(BOOL)lcache
{
    __block UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    __block NSDate *_expiry = [expiry copy];
    
    __block BOOL cache = lcache;
    
    spinner.frame = CGRectMake((self.frame.size.width - spinner.frame.size.width) / 2, (self.frame.size.height - spinner.frame.size.height) / 2, spinner.frame.size.width, spinner.frame.size.height);
    
    [self addSubview:spinner];
    [spinner startAnimating];
    
    AFFNRequest *request = [AFFNRequest requestWithConnectionType:kAFFNGet andURL:imageURL andParams:nil withCompletion:^(AFFNCallbackObject *result){
        dispatch_async(dispatch_get_main_queue(), ^(){
            [UIView animateWithDuration:0.5f animations:^(){
                [spinner stopAnimating];
                spinner.alpha = 0;
            } completion:^(BOOL done){
                [spinner removeFromSuperview];
                [spinner release];
                spinner = nil;
                self.image = [UIImage imageWithData:result.data];
                if(cache)
                    [AFFNImageManager cacheImage:self.image withName:self.limageURL withExpiry:_expiry];
                [_expiry release];
                _expiry = nil;
            }];
        });
    } andFailure:^(NSError *error){
        [spinner stopAnimating];
        [spinner removeFromSuperview];
        [spinner release];
        spinner = nil;
        [_expiry release];
        _expiry = nil;
    }];
    
    [[AFFNManager sharedManager] addNetworkOperation:request];
    
}

@end
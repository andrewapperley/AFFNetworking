//
//  UIImageView+AFFNImage.m
//  AFFNetworking
//
//  Created by Andrew Apperley on 2013-08-20.
//  Copyright (c) 2013 AFApps. All rights reserved.
//

#import "UIImageView+AFFNImage.h"
#import "AFFNImageManager.h"
#import <objc/runtime.h>

@implementation UIImageView (AFFNImage)

static char imageUrlKey;

- (UIImageView *)initWithFrame:(CGRect)frame andPlaceholderImage:(UIImage *)phImage andImageURL:(NSString *)imageURL andExpiry:(NSDate *)expiry andToCache:(BOOL)cache
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self.frame = frame;
        [self setLimageURL:imageURL];
        self.image = [AFFNImageManager doesImageExist:imageURL] && cache ? [AFFNImageManager returnCachedImage:imageURL] : phImage;
        
        if([self.image isEqual:phImage])
            [self callURLForImage:imageURL withExpiry:expiry];
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

- (void)callURLForImage:(NSString *)imageURL withExpiry:(NSDate *)expiry
{
   __block UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    __block NSDate *_expiry = [expiry copy];
    
    spinner.frame = CGRectMake((self.frame.size.width - spinner.frame.size.width) / 2, (self.frame.size.height - spinner.frame.size.height) / 2, spinner.frame.size.width, spinner.frame.size.height);
    
    [self addSubview:spinner];
    [spinner startAnimating];
    
    AFFNRequest *request = [AFFNRequest requestWithConnectionType:kAFFNPost andURL:imageURL andParams:nil withCompletion:^(AFFNCallbackObject *result){
        dispatch_async(dispatch_get_main_queue(), ^(){
            [UIView animateWithDuration:0.5f animations:^(){
                [spinner stopAnimating];
                spinner.alpha = 0;
            } completion:^(BOOL done){
                [spinner removeFromSuperview];
                [spinner release];
                spinner = nil;
                self.image = [UIImage imageWithData:result.data];
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

- (void)dealloc
{
        
    [super dealloc];
}

@end
//
//  UIImageView+AFFNImage.h
//  AFFNetworking
//
//  Created by Andrew Apperley on 2013-08-20.
//  Copyright (c) 2013 AFApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (AFFNImage)

- (id)initWithFrame:(CGRect)frame andPlaceholderImage:(UIImage *)phImage andImageURL:(NSString *)imageURL;
@end
//
//  AFFNImageManager.h
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

#import <Foundation/Foundation.h>
#import <UIKit/UIImage.h>

static const NSTimeInterval kExpiryInterval = 600; // 20 minutes, change this to change the interval between expiry checks

@interface AFFNImageManager : NSObject

+ (AFFNImageManager *)sharedManager;
+ (void)cacheImage:(UIImage *)limage withName:(NSString *)lname withExpiry:(NSDate *)expiry;
+ (BOOL)doesImageExist:(NSString *)filePath;
+ (UIImage *)returnCachedImage:(NSString *)filePath;
+ (NSString *)getCacheDirectory;
- (void)saveCacheListToFile;

@property(atomic, retain)NSDictionary *imageList;
@property(nonatomic, assign)NSTimer *timer;
@end
//
//  AFFNImageManager.h
//  AFFNetworking
//
//  Created by Andrew Apperley on 2013-08-20.
//  Copyright (c) 2013 AFApps. All rights reserved.
//

#import <Foundation/Foundation.h>

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
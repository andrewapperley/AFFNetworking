//
//  AFFNImageManager.m
//  AFFNetworking
//
//  Created by Andrew Apperley on 2013-08-20.
//  Copyright (c) 2013 AFApps. All rights reserved.
//

#import "AFFNImageManager.h"
#import <CommonCrypto/CommonDigest.h>

@implementation AFFNImageManager

+ (AFFNImageManager *)sharedManager
{
    static dispatch_once_t onceToken;
    static AFFNImageManager *_sharedManager = nil;
    
    dispatch_once(&onceToken, ^{
        _sharedManager = [AFFNImageManager new];
        //creates directory for cache images, will only create it if it doesnt already exists
        [[NSFileManager defaultManager] createDirectoryAtPath:[AFFNImageManager getCacheDirectory] withIntermediateDirectories:FALSE attributes:nil error:nil];
    });
    
	return _sharedManager;
}

+ (BOOL)doesImageExist:(NSString *)filePath
{
    filePath = [AFFNImageManager createImageHash:filePath];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:[[AFFNImageManager getCacheDirectory] stringByAppendingString:[NSString stringWithFormat:@"/%@",filePath]]])
        return true;
    
    return FALSE;
}

+ (UIImage *)returnCachedImage:(NSString *)filePath
{
    return [UIImage imageWithData:[[NSFileManager defaultManager] contentsAtPath:[[AFFNImageManager getCacheDirectory] stringByAppendingString:[NSString stringWithFormat:@"/%@",[AFFNImageManager createImageHash:filePath]]]]];
}

+ (void)cacheImage:(UIImage *)limage withName:(NSString *)lname
{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
        [[NSFileManager defaultManager] createFileAtPath:[[AFFNImageManager getCacheDirectory] stringByAppendingString:[NSString stringWithFormat:@"/%@",[AFFNImageManager createImageHash:lname]]] contents:UIImagePNGRepresentation(limage) attributes:nil];
    });
}

+ (NSString *)createImageHash:(NSString *)lurl
{
    unsigned char digest[16];
    
    CC_MD5([lurl UTF8String], strlen([lurl UTF8String]), digest);
    
    NSMutableString *output = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH];
    
    for (uint i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x",digest[i]];
    }
    
    return output;
}

+ (NSString *)getCacheDirectory
{
    return [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"imageCache"];
}

@end

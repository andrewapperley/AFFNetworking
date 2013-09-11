//
//  AFFNImageManager.m
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
        if([AFFNImageManager doesCacheExist]) {
            //The cache list exists so it is brought into memory
            NSPropertyListFormat format;
            _sharedManager.imageList = (NSDictionary *)[NSPropertyListSerialization
                                        propertyListFromData:[[NSFileManager defaultManager] contentsAtPath:[[AFFNImageManager getCacheDirectory] stringByAppendingString:@"/cache.plist"]]
                                        mutabilityOption:NSPropertyListMutableContainersAndLeaves
                                        format:&format
                                        errorDescription:nil];
        } else
            //The list doesn't exist so it is created in memory
            _sharedManager.imageList = [NSDictionary dictionaryWithObject:[NSMutableArray array] forKey:@"cache"];
        
        //Expiry check time is initialized
        _sharedManager.timer = [NSTimer timerWithTimeInterval:kExpiryInterval target:_sharedManager selector:@selector(checkForExpiredImages) userInfo:nil repeats:true];
        [_sharedManager.timer fire];

    });
    
	return _sharedManager;
}

+ (BOOL)doesImageExist:(NSString *)filePath
{
    //Check if the image with the hashed name is in the Cache folder
    filePath = [AFFNImageManager createImageHash:filePath];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:[[AFFNImageManager getCacheDirectory] stringByAppendingString:[NSString stringWithFormat:@"/%@",filePath]]])
        return true;
    
    return FALSE;
}

+ (BOOL)doesCacheExist
{
    //Checks if the cache.plist file exists
    if([[NSFileManager defaultManager] fileExistsAtPath:[[AFFNImageManager getCacheDirectory] stringByAppendingString:@"/cache.plist"]])
        return true;
    
    return FALSE;
}

+ (UIImage *)returnCachedImage:(NSString *)filePath
{
    //Returns a UIImage representation of the NSData saved in the file system
    return [UIImage imageWithData:[[NSFileManager defaultManager] contentsAtPath:[[AFFNImageManager getCacheDirectory] stringByAppendingString:[NSString stringWithFormat:@"/%@",[AFFNImageManager createImageHash:filePath]]]]];
}

+ (void)cacheImage:(UIImage *)limage withName:(NSString *)lname withExpiry:(NSDate *)expiry
{
    //Saves the image as NSData and adds the image to the imageList in memory, will be synced up to the plist file when the app closes
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
        //Save image file to the directory
        [[NSFileManager defaultManager] createFileAtPath:[[AFFNImageManager getCacheDirectory] stringByAppendingString:[NSString stringWithFormat:@"/%@",[AFFNImageManager createImageHash:lname]]] contents:UIImagePNGRepresentation(limage) attributes:nil];
        //Save the image name and expiry date to the cache list in memory
        NSDictionary *image = @{@"imageName" : [AFFNImageManager createImageHash:lname], @"expiry" : expiry};
        [[[[AFFNImageManager sharedManager] imageList] objectForKey:@"cache"] addObject:image];
        
    });
}

+ (NSString *)createImageHash:(NSString *)lurl
{
    //Hashes the url to the image with MD5, used as the file name and checks later on
    unsigned char digest[16];
    
    CC_MD5([lurl UTF8String], (CC_LONG)strlen([lurl UTF8String]), digest);
    
    NSMutableString *output = [[[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH] autorelease];
    
    for (uint i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x",digest[i]];
    }
    
    return output;
}

+ (NSString *)getCacheDirectory
{
    //cache Directory in the filesystem
    return [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"imageCache"];
}

+ (BOOL)compareDate:(NSDate *)date1 andDate:(NSDate *)date2
{
    //Used to check if image has expired or not
    NSComparisonResult result = [date1 compare:date2];
    
    switch (result) {
        case NSOrderedAscending:
            return FALSE;
            break;
        case NSOrderedDescending:
            return TRUE;
            break;
        case NSOrderedSame:
            return TRUE;
            break;
    }
    
    return FALSE;
}

+ (void)deleteImageAfterExpiry:(NSString *)name
{
    //deletes the image out of the filesystem after it expired
    
    NSError *e = nil;
    [[NSFileManager defaultManager] removeItemAtPath:[[AFFNImageManager getCacheDirectory] stringByAppendingString:[NSString stringWithFormat:@"/%@",name]] error:&e];
    NSAssert(!e, @"There was an error while deleting the image");
}

- (void)saveCacheListToFile
{
    //If there is a list in memory it will sync it up to a file that can be loaded the next time the app launches
    if(!_imageList)
        return;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
        NSError *error = nil;
        NSData *imageListData = [NSPropertyListSerialization dataWithPropertyList:_imageList format:NSPropertyListXMLFormat_v1_0 options:0 error:&error];
    
        NSAssert(!error, @"Error occured when writing cache list to file");
    
        [imageListData writeToFile:[[AFFNImageManager getCacheDirectory] stringByAppendingString:@"/cache.plist"] atomically:true];
    });
}

- (void)checkForExpiredImages
{
    //Cross checks all image expiry dates with the current date and deletes them if needed
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
        NSMutableArray *destroyArray = [NSMutableArray array];
            for (NSDictionary *o in [_imageList objectForKey:@"cache"]) {
                if([AFFNImageManager compareDate:[NSDate date] andDate:[o objectForKey:@"expiry"]]) {
                    [destroyArray addObject:o];
                    [AFFNImageManager deleteImageAfterExpiry:[o objectForKey:@"imageName"]];
            }
        }
        if(destroyArray.count > 0) {
            [(NSMutableArray *)[_imageList objectForKey:@"cache"] removeObjectsInArray:destroyArray];
            [self saveCacheListToFile];
        }
    });
}

- (void)dealloc
{
    //memory clean up
    if(_imageList)
        [_imageList release];
    
    _imageList = nil;
    if(_timer)
        [_timer release];
    
    _timer = nil;
    
    [super dealloc];
}

@end

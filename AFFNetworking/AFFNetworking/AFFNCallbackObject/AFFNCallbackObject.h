//
//  AFFNCallbackObject.h
//  AFFNetworking
//
//  Created by Andrew Apperley on 2013-08-10.
//  Copyright (c) 2013 AFApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AFFNCallbackObject : NSObject

@property (nonatomic, readonly) CGFloat totalRequestTime;
@property (nonatomic, readonly) NSData *data;
@property (nonatomic, readonly) NSString *streamObjectPath;

+ (id)callbackWithData:(NSData *)data andReqestTime:(CGFloat)requestTime;
+ (id)callbackWitStreamedObjectPath:(NSString *)path andReqestTime:(CGFloat)requestTime;

@end

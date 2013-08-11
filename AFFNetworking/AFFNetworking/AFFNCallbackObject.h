//
//  AFFNCallbackObject.h
//  AFFNetworking
//
//  Created by Andrew Apperley on 2013-08-10.
//  Copyright (c) 2013 AFApps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AFFNCallbackObject : NSObject

@property (readonly) double totalRequestTime;
@property (readonly) NSData *data;

+ (id)callbackWithData:(NSData *)data andReqestTime:(double)requestTime;

@end

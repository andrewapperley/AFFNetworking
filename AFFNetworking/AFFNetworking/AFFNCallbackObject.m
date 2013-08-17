//
//  AFFNCallbackObject.m
//  AFFNetworking
//
//  Created by Andrew Apperley on 2013-08-10.
//  Copyright (c) 2013 AFApps. All rights reserved.
//

#import "AFFNCallbackObject.h"

@implementation AFFNCallbackObject
@synthesize totalRequestTime = _totalRequestTime;
@synthesize data = _data;

//Callback object that holds data associated with the request and is sent through a completion block
+ (id)callbackWithData:(NSData *)data andReqestTime:(CGFloat)requestTime
{
    return [[[self alloc] initWithData:data andReqestTime:requestTime] autorelease];
}

- (id)initWithData:(NSData *)data andReqestTime:(CGFloat)requestTime
{
    self = [super init];
    if(self)
    {
        _totalRequestTime = requestTime;
        _data = [data copy];
    }
    
    return self;
}

- (void)dealloc
{
    [_data release];
    _data = nil;
    
    [super dealloc];
}

@end
//
//  AFFNCallbackObject.m
//  AFFNetworking
//
//  Created by Andrew Apperley on 2013-08-10.
//  Copyright (c) 2013 AFApps. All rights reserved.
//

#import "AFFNCallbackObject.h"

@implementation AFFNCallbackObject

@synthesize totalRequestTime = _totalRequestTime, data = _data;

- (id)initWithData:(NSData *)data andReqestTime:(double)requestTime
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
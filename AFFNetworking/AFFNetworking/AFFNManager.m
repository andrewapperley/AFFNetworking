//
//  AFFNManager.m
//  AFFNetworking
//
//  Created by Andrew Apperley on 2013-08-07.
//  Copyright (c) 2013 AFApps. All rights reserved.
//

#import "AFFNManager.h"


@implementation AFFNManager

#define LAST_NETWORK_OPERATION [_networkOperations.operations lastObject]

static AFFNManager *sharedManager = nil;

@synthesize networkOperations = _networkOperations;
@synthesize cpuOperations = _cpuOperations;

+ (AFFNManager *)sharedManager
{
    if(sharedManager)
        return sharedManager;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[AFFNManager alloc] init];
    });
    
    return sharedManager;
}

- (void)addNetworkOperation:(AFFNRequest *)operation
{
    if(!_networkOperations) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _networkOperations = [NSOperationQueue new];
            _networkOperations.maxConcurrentOperationCount = 4;
        });
    }
    
    if(LAST_NETWORK_OPERATION)
        [operation addDependency:LAST_NETWORK_OPERATION];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
        [_networkOperations addOperation:operation];
    });
}

- (void)addCpuOperation:(AFFNRequest *)operation
{
    if(!_cpuOperations) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _cpuOperations = [NSOperationQueue new];
        });
    }
    
}

+ (id)init
{
    return [self sharedManager];
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (oneway void)release{}

- (id)retain
{
    return self;
}

- (NSUInteger)retainCount {
    return NSUIntegerMax;
}

- (id)autorelease
{
    return self;
}

@end
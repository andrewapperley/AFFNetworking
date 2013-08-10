//
//  AFFNManager.m
//  AFFNetworking
//
//  Created by Andrew Apperley on 2013-08-07.
//  Copyright (c) 2013 AFApps. All rights reserved.
//

#import "AFFNManager.h"


@implementation AFFNManager

static AFFNManager *sharedManager = nil;

@synthesize networkOperations = _networkOperations;
@synthesize cpuOperations = _cpuOperations;

+ (AFFNManager *)sharedManager
{
    if(sharedManager)
        return sharedManager;
    
    // Makes the singleton thread safe so the instance isnt created in more than one thread, same
    // instance is shared
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
            _networkOperations.maxConcurrentOperationCount = 1;
        });
    }
    
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

// Override the release, autorelease, retain count, and the alloc with zone methods
// This will never be dealloc'd so there is no need to have a dealloc method, release objects
// as they are not used, this class will be alive for the entire lifespan of the app

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
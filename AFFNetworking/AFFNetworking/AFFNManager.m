//
//  AFFNManager.m
//  AFFNetworking
//
//  Created by Andrew Apperley on 2013-08-07.
//  Copyright (c) 2013 AFApps. All rights reserved.
//

#import "AFFNManager.h"

#pragma mark - Macros
#define LAST_NETWORK_OPERATION [_networkOperations.operations lastObject]

#pragma mark - Constants
const NSUInteger __AFFNManagerDefaultConcurrentQueueCount = 4;

@implementation AFFNManager

static AFFNManager *sharedManager = nil;

@synthesize networkOperations = _networkOperations;
@synthesize cpuOperations = _cpuOperations;

//Add network bound operation to the queue, if the queue is nil then make it once. This is done on a global background queue
- (void)addNetworkOperation:(AFFNRequest *)operation
{
    if(!_networkOperations) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _networkOperations = [NSOperationQueue new];
            _networkOperations.maxConcurrentOperationCount = __AFFNManagerDefaultConcurrentQueueCount;
        });
    }
    
    if(LAST_NETWORK_OPERATION)
        [operation addDependency:LAST_NETWORK_OPERATION];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
        [_networkOperations addOperation:operation];
    });
}

//Add local bound operation to the queue, if the queue is nil then make it once. This is done on a global background queue
- (void)addCpuOperation:(AFFNRequest *)operation
{
    if(!_cpuOperations) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _cpuOperations = [NSOperationQueue new];
        });
    }
    
}

#pragma mark - Init

//Singleton sharedManager method
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

//Override methods to make the singleton class
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

#pragma mark - Properties
- (void)setMaxAmountOfConcurrentOperations:(NSUInteger)maxAmountOfConcurrentOperations
{
    if(_networkOperations)
        _networkOperations.maxConcurrentOperationCount = maxAmountOfConcurrentOperations;
}

- (NSUInteger)maxAmountOfConcurrentOperations
{
    return _networkOperations.maxConcurrentOperationCount;
}

@end
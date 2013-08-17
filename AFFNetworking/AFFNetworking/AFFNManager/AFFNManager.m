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
@synthesize networkOperations = _networkOperations;
@synthesize cpuOperations = _cpuOperations;

#pragma mark - Init
//Singleton sharedManager method
+ (AFFNManager *)sharedManager
{    
    static dispatch_once_t onceToken;
    static AFFNManager *_sharedManager = nil;
    
    dispatch_once(&onceToken, ^{
        _sharedManager = [AFFNManager new];
    });
    
	return _sharedManager;
}

#pragma mark - Networking methods
//Add network bound operation to the queue, if the queue is nil then make it once. This is done on a global background queue
- (void)addNetworkOperation:(AFFNRequest *)operation
{
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _networkOperations = [NSOperationQueue new];
        _networkOperations.maxConcurrentOperationCount = __AFFNManagerDefaultConcurrentQueueCount;
    });
    
    if(LAST_NETWORK_OPERATION)
        [operation addDependency:LAST_NETWORK_OPERATION];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
        [_networkOperations addOperation:operation];
    });
}

//Add local bound operation to the queue, if the queue is nil then make it once. This is done on a global background queue
- (void)addCpuOperation:(AFFNRequest *)operation
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _cpuOperations = [NSOperationQueue new];
    });
    
    [_cpuOperations addOperation:operation];
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
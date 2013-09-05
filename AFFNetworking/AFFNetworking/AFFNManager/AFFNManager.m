//
//  AFFNManager.m
//  AFFNetworking
//
//  Created by Andrew Apperley on 2013-08-07.
//  Copyright (c) 2013 AFApps. All rights reserved.
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

#import "AFFNManager.h"

#pragma mark - Macros
#define LAST_NETWORK_OPERATION [_networkOperations.operations lastObject]

@implementation AFFNManager
@synthesize networkOperations = _networkOperations;

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
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
        [_networkOperations addOperation:operation];
    });
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
//
//  AFFNManager.h
//  AFFNetworking
//
//  Created by Andrew Apperley on 2013-08-07.
//  Copyright (c) 2013 AFApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFFNRequest.h"

@interface AFFNManager : NSObject

- (void)addNetworkOperation:(AFFNRequest *)operation;
+ (AFFNManager *)sharedManager;

@property (nonatomic, assign) NSUInteger maxAmountOfConcurrentOperations;   //Default is 4
@property (nonatomic, readonly) NSOperationQueue *networkOperations;
@property (nonatomic, readonly) NSOperationQueue *cpuOperations;

@end
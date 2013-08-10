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
{
    @private
}

- (void)addNetworkOperation:(AFFNRequest *)operation;
+ (AFFNManager *)sharedManager;

@property(atomic, readonly)NSOperationQueue *networkOperations;
@property(atomic, readonly)NSOperationQueue *cpuOperations;

@end
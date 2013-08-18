//
//  AFFNStreamingRequest.m
//  AFFNetworking
//
//  Created by Andrew Apperley on 2013-08-17.
//  Copyright (c) 2013 AFApps. All rights reserved.
//

#import "AFFNStreamingRequest.h"

@implementation AFFNStreamingRequest

static NSString *__AFFNKeyExecuting = @"isExecuting";
static NSString *__AFFNKeyFinished = @"isFinished";

+ (AFFNStreamingRequest *)streamingRequestWithFileName:(NSString *)name andExtention:(NSString *)ext andURL:(NSString *)urlString andParams:(NSDictionary *)params withCompletion:(void (^)(AFFNCallbackObject *result))completion andFailure:(void (^)(NSError *error))failure
{
    return [[[self alloc] initStreamingRequestWithFileName:name andExtention:ext andURL:urlString andParams:params withCompletion:completion andFailure:failure] autorelease];
}

- (AFFNStreamingRequest *)initStreamingRequestWithFileName:(NSString *)name andExtention:(NSString *)ext andURL:(NSString *)urlString andParams:(NSDictionary *)params withCompletion:(void (^)(AFFNCallbackObject *result))completion andFailure:(void (^)(NSError *error))failure
{
    self = [super initWithConnectionType:kAFFNPost andURL:urlString andParams:params withCompletion:completion andFailure:failure];
    
    if(self)
    {
        if(name)
            fileName = [name copy];
        
        if(ext)
            extType = [ext copy];
        
        filePath = [[NSString stringWithFormat:@"%@/%@.%@",[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0],fileName,extType] retain];
        
        streamingFile = [[NSFileHandle fileHandleForWritingToURL:[NSURL fileURLWithPath:filePath] error:nil] retain];
        if(!streamingFile) {
            [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
            streamingFile = [[NSFileHandle fileHandleForWritingToURL:[NSURL fileURLWithPath:filePath] error:nil] retain];
        }
    }
    
    return self;
}

- (void)start
{
    [super start];
    
    //streaming the data to a file so we dont need to keep it in memory.
    [receivedData release];
    receivedData = nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if(streamingFile)
        [streamingFile writeData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [streamingFile closeFile];
    
    [self->_connection release];
    _connection = nil;
    
    NSTimeInterval totalRequestTime = [[NSDate date] timeIntervalSinceDate:requestTime];
    
    AFFNCallbackObject *callBack = [AFFNCallbackObject callbackWitStreamedObjectPath:filePath andReqestTime:totalRequestTime];
    
    [filePath release];
    filePath = nil;
    
    if(_completionBlock)
        _completionBlock(callBack);
    
    [self willChangeValueForKey:__AFFNKeyExecuting];
    self.isExecuting = FALSE;
    [self didChangeValueForKey:__AFFNKeyExecuting];
    
    [self willChangeValueForKey:__AFFNKeyFinished];
    self.isFinished = TRUE;
    [self didChangeValueForKey:__AFFNKeyFinished];
}

- (void)dealloc
{
    if(fileName){
        [fileName release];
        fileName = nil;
    }
    
    if(filePath){
        [filePath release];
        filePath = nil;
    }
    
    if(streamingFile){
        [streamingFile release];
        streamingFile = nil;
    }
    
    if(extType){
        [extType release];
        extType = nil;
    }
    
    [super dealloc];
}

@end
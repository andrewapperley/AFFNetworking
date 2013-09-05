//
//  AFFNStreamingRequest.m
//  AFFNetworking
//
//  Created by Andrew Apperley on 2013-08-17.
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



#import "AFFNStreamingRequest.h"

@implementation AFFNStreamingRequest

static NSString *__AFFNKeyExecuting = @"isExecuting";
static NSString *__AFFNKeyFinished = @"isFinished";

/*
 * Init functions for creating a streaming request
 * //Without progress blocks
 * @params
 * AFFNPostType type
 * NSString name
 * NSString ext
 * NSString urlString
 * NSDictionary params
 * void Block (AFFNCallbackObject) completion
 * void Block (NSError) failure
 *
 * //With progress blocks
 * @params
 * AFFNPostType type
 * NSString name
 * NSString ext
 * NSString urlString
 * NSDictionary params
 * void Block (AFFNCallbackObject) completion
 * void Block (NSError) failure
 * void Block (float) uploadProgressBlock
 * void Block (float) downloadProgressBlock
 */

+ (AFFNStreamingRequest *)streamingRequestWithConnectionType:(AFFNPostType)type FileName:(NSString *)name andExtention:(NSString *)ext andURL:(NSString *)urlString andParams:(NSDictionary *)params withCompletion:(void (^)(AFFNCallbackObject *result))completion andFailure:(void (^)(NSError *error))failure
{
    return [[[self alloc] initWithConnectionType:(AFFNPostType)type andStreamingRequestWithFileName:name andExtention:ext andURL:urlString andParams:params withCompletion:completion andFailure:failure andUploadProgressBlock:nil andDownloadProgressBlock:nil] autorelease];
}

+ (AFFNStreamingRequest *)streamingRequestWithConnectionType:(AFFNPostType)type FileName:(NSString *)name andExtention:(NSString *)ext andURL:(NSString *)urlString andParams:(NSDictionary *)params withCompletion:(void (^)(AFFNCallbackObject *result))completion andFailure:(void (^)(NSError *error))failure andUploadProgressBlock:(void (^)(CGFloat))uploadProgressBlock andDownloadProgressBlock:(void (^)(float))downloadProgressBlock
{
    return [[[self alloc] initWithConnectionType:(AFFNPostType)type andStreamingRequestWithFileName:name andExtention:ext andURL:urlString andParams:params withCompletion:completion andFailure:failure andUploadProgressBlock:uploadProgressBlock andDownloadProgressBlock:downloadProgressBlock] autorelease];
}

- (AFFNStreamingRequest *)initWithConnectionType:(AFFNPostType)type andStreamingRequestWithFileName:(NSString *)name andExtention:(NSString *)ext andURL:(NSString *)urlString andParams:(NSDictionary *)params withCompletion:(void (^)(AFFNCallbackObject *result))completion andFailure:(void (^)(NSError *error))failure andUploadProgressBlock:(void (^)(CGFloat))uploadProgressBlock andDownloadProgressBlock:(void (^)(float))downloadProgressBlock
{
    self = [super initWithConnectionType:type andURL:urlString andParams:params withCompletion:completion andFailure:failure];
    
    if(self)
    {
        if(uploadProgressBlock)
            _upProgressBlock = [uploadProgressBlock copy];
        
        if(downloadProgressBlock)
            _downProgressBlock = [downloadProgressBlock copy];
        
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

//Function is called once the AFFNManager announces this operation ready

- (void)start
{
    [super start];
    
    //streaming the data to a file so we dont need to keep it in memory.
    [receivedData release];
    receivedData = nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    //file is overwritten as the response has started over. This could be due to connection issues and the
    //data that is coming back is starting from the beginning so the file must be created again or it would just
    //append the new data to the old data
    [streamingFile release];
    streamingFile = nil;
    [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
    streamingFile = [[NSFileHandle fileHandleForWritingToURL:[NSURL fileURLWithPath:filePath] error:nil] retain];
    
    [super connection:connection didReceiveResponse:response];
}

//Writes to the open file with the data that is coming from the server, this can happen in small chunks or
//one chunk - it's all up to the server to determine how the data comes back; It is appended to the end of the file
//each time this function is called.

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if(streamingFile)
        [streamingFile writeData:data];
}

//Streaming file is closed and the callback block is sent the filePath to the newly created file

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

//Clean up

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
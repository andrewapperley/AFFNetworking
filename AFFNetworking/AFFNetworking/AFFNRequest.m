//
//  AFFNRequest.m
//  AFFNetworking
//
//  Created by Andrew Apperley on 2013-08-06.
//  Copyright (c) 2013 AFApps. All rights reserved.
//

#import "AFFNRequest.h"
#import "AFFNManager.h"

#pragma mark - Constants
const NSTimeInterval __AFFNDefaultTimeout = 120;
const NSURLCacheStoragePolicy __AFFNDefaultStoragePolicy = NSURLCacheStorageAllowedInMemoryOnly;

NSString *__AFFNKeyExecuting = @"isExecuting";
NSString *__AFFNKeyFinished = @"isFinished";

@implementation AFFNRequest

@synthesize progress = _progress;
@synthesize isConcurrent = _isConcurrent;
@synthesize timeoutInterval = _timeoutInterval;
@synthesize storagePolicy = _storagePolicy;

#pragma mark - Init

/*
 * Init function to create the reqest object. It takes the URL in NSString format, POST/GET type, params to be used
 * in the request in NSDictionary format, and a completion/fail block for a callback.
 *
 */
+ (AFFNRequest *)requestWithURL:(NSString *)urlString connectionType:(AFFNPostType)type andParams:(NSDictionary *)params withCompletion:(void (^)(AFFNCallbackObject *result))completion andFailBlock:(void (^)(NSError *error))failure
{
    return [[[self alloc] initWithURL:urlString connectionType:type andParams:params withCompletion:completion andFailBlock:failure] autorelease];
}

- (AFFNRequest *)initWithURL:(NSString *)urlString connectionType:(AFFNPostType)type andParams:(NSDictionary *)params withCompletion:(void (^)(AFFNCallbackObject *))completion andFailBlock:(void (^)(NSError *))failure
{
    self = [super init];
    if(self)
    {
        executing = FALSE;
        finished = FALSE;
        
        _isConcurrent = TRUE;
        _timeoutInterval = __AFFNDefaultTimeout;
        _storagePolicy = __AFFNDefaultStoragePolicy;
        
        _params = [params copy];
        _urlString = [urlString copy];
        _type = type;
        _completion = [completion copy];
        _failure = [failure copy];
    }
    
    return self;
}

#pragma mark - Properties

/*
 * BOOL returning functions that return the state of the request
 */
- (BOOL)isConcurrent
{
    return _isConcurrent;
}

- (BOOL)isExecuting
{
    return executing;
}

- (BOOL)isFinished
{
    return finished;
}

#pragma mark - Generate requests

/*
 * The main function of where the request creates the POST/GET request and the connection object, then starts the process.
 */
- (void)start
{    
    [self willChangeValueForKey:__AFFNKeyExecuting];
    executing = TRUE;
    [self didChangeValueForKey:__AFFNKeyExecuting];
    
    if(self.isCancelled) {
        [self willChangeValueForKey:__AFFNKeyExecuting];
        executing = false;
        [self didChangeValueForKey:__AFFNKeyExecuting];
        
        [self willChangeValueForKey:__AFFNKeyFinished];
        finished = true;
        [self didChangeValueForKey:__AFFNKeyFinished];
        
        //temp custom error code/string
        _failure([NSError errorWithDomain:@"operation.cancelled" code:600 userInfo:nil]);
        return;
    }

    
    [self performSelector:_type == kAFFNPost ? @selector(generatePOSTRequest) : @selector(generateGETRequest)];
    
    _connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:FALSE];
    
    if(_connection) {
        receivedData = [NSMutableData new];
        
        [_connection scheduleInRunLoop:[NSRunLoop mainRunLoop]
                               forMode:NSDefaultRunLoopMode];
        [_connection start];
        
        
        requestTime = [[NSDate date] retain];
        
        [finalURL release];
        finalURL = nil;
        
        [request release];
        request = nil;
    }
}

//Generates a POST type request
- (void)generatePOSTRequest
{
    
    finalURL = [[NSURL alloc] initWithString:_urlString];
    
    request = [[NSMutableURLRequest alloc] initWithURL:finalURL cachePolicy:_storagePolicy timeoutInterval:_timeoutInterval];
    
    [request setHTTPMethod:@"POST"];
    
    NSData *jsonData = [NSData data];
    
    NSError *error;
    
    jsonData = [NSJSONSerialization dataWithJSONObject:_params options:NSJSONWritingPrettyPrinted error:&error];
    
    if(error)
        assert(error);
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSData *data = [NSData dataWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [jsonString release];
    
    [request setHTTPBody:data];
    [request setValue:[NSString stringWithFormat:@"%d", data.length] forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"iOS" forHTTPHeaderField:@"User-Agent"];
    
   
}

//Generates a GET type request
- (void)generateGETRequest
{
   
}

#pragma mark - Connection handling

//Calculates the progress of the request
- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    _progress = (totalBytesWritten / totalBytesExpectedToWrite);
}

//Failure of the connection, returns the error through the failure block
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [_connection release];
    _connection = nil;
    
    _failure(error);
    
    [self willChangeValueForKey:__AFFNKeyExecuting];
    executing = false;
    [self didChangeValueForKey:__AFFNKeyExecuting];

    [self willChangeValueForKey:__AFFNKeyFinished];
    finished = true;
    [self didChangeValueForKey:__AFFNKeyFinished];

    if(error)
        assert(error);
}

//Sets the progress and data to 0 as a request/attempt has started
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [receivedData setLength:0];
    _progress = 0;
    
}

//Appends data to the data object
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [receivedData appendData:data];
}

//Successful request function. Returns the total request time and data to the completion block in a AFFNCallbackObject
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [_connection release];
    _connection = nil;
    
    NSTimeInterval totalRequestTime = [[NSDate date] timeIntervalSinceDate:requestTime];
    
    AFFNCallbackObject *callBack = [AFFNCallbackObject callbackWithData:receivedData andReqestTime:totalRequestTime];
    
    _completion(callBack);
        
    [self willChangeValueForKey:__AFFNKeyExecuting];
    executing = false;
    [self didChangeValueForKey:__AFFNKeyExecuting];
    
    [self willChangeValueForKey:__AFFNKeyFinished];
    finished = true;
    [self didChangeValueForKey:__AFFNKeyFinished];
}

#pragma mark - Dealloc

//Clean up memory
- (void)dealloc
{
    [_params release];
    _params = nil;
    
    [_urlString release];
    _urlString = nil;
    
    [finalURL release];
    finalURL = nil;
    
    [request release];
    request = nil;
    
    if(_connection){
        [_connection release];
        _connection = nil;
    }
    
    [_completion release];
    _completion = nil;
    
    [_failure release];
    _failure = nil;
    
    [requestTime release];
    requestTime = nil;
    
    if(receivedData){
        [receivedData release];
        receivedData = nil;
    }
    
    [super dealloc];
}

@end
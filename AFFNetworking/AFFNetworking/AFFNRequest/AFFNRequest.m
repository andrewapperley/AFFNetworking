//
//  AFFNRequest.m
//  AFFNetworking
//
//  Created by Andrew Apperley on 2013-08-06.
//  Copyright (c) 2013 AFApps. All rights reserved.
//

#import "AFFNRequest.h"

#pragma mark - Constants
const NSTimeInterval __AFFNDefaultTimeout = 120;
const NSURLCacheStoragePolicy __AFFNDefaultStoragePolicy = NSURLCacheStorageAllowedInMemoryOnly;
const NSString *__AFFNDefaultMultiSeparator = @"---------------------_AFFNBoundary_";

static NSString *__AFFNKeyExecuting = @"isExecuting";
static NSString *__AFFNKeyFinished = @"isFinished";

@implementation AFFNRequest
@synthesize multiSeparator = _multiSeparator;
@synthesize isConcurrent = _isConcurrent;
@synthesize isExecuting = _isExecuting;
@synthesize isFinished = _isFinished;
@synthesize timeoutInterval = _timeoutInterval;
@synthesize storagePolicy = _storagePolicy;

#pragma mark - Init

/*
 * Init function to create the reqest object. It takes the URL in NSString format, POST/GET type, params to be used
 * in the request in NSDictionary format, and a completion/fail block for a callback.
 *
 */
+ (AFFNRequest *)requestWithConnectionType:(AFFNPostType)type andURL:(NSString *)urlString andParams:(NSDictionary *)params withCompletion:(void (^)(AFFNCallbackObject *))completion andFailure:(void (^)(NSError *))failure
{
    return [[[self alloc] initWithConnectionType:type andURL:urlString andParams:params withCompletion:completion andFailure:failure andUploadProgressBlock:nil andDownloadProgressBlock:nil andMultiData:nil] autorelease];
}

+ (AFFNRequest *)requestWithConnectionType:(AFFNPostType)type andURL:(NSString *)urlString andParams:(NSDictionary *)params withCompletion:(void (^)(AFFNCallbackObject *))completion andFailure:(void (^)(NSError *))failure andUploadProgressBlock:(void (^)(CGFloat))uploadProgressBlock andDownloadProgressBlock:(void (^)(float))downloadProgressBlock
{
    return [[[self alloc] initWithConnectionType:type andURL:urlString andParams:params withCompletion:completion andFailure:failure andUploadProgressBlock:uploadProgressBlock andDownloadProgressBlock:downloadProgressBlock andMultiData:nil] autorelease];
}

+ (AFFNRequest *)requestWithConnectionType:(AFFNPostType)type andURL:(NSString *)urlString andParams:(NSDictionary *)params withCompletion:(void (^)(AFFNCallbackObject *))completion andFailure:(void (^)(NSError *))failure andUploadProgressBlock:(void (^)(CGFloat))uploadProgressBlock andDownloadProgressBlock:(void (^)(float))downloadProgressBlock andMultiData:(NSArray *)multiData
{
    return [[[self alloc] initWithConnectionType:type andURL:urlString andParams:params withCompletion:completion andFailure:failure andUploadProgressBlock:uploadProgressBlock andDownloadProgressBlock:downloadProgressBlock andMultiData:multiData] autorelease];
}

- (AFFNRequest *)initWithConnectionType:(AFFNPostType)type andURL:(NSString *)urlString andParams:(NSDictionary *)params withCompletion:(void (^)(AFFNCallbackObject *))completion andFailure:(void (^)(NSError *))failure
{
    return [self initWithConnectionType:type andURL:urlString andParams:params withCompletion:completion andFailure:failure andUploadProgressBlock:nil andDownloadProgressBlock:nil andMultiData:nil];
}

- (AFFNRequest *)initWithConnectionType:(AFFNPostType)type andURL:(NSString *)urlString andParams:(NSDictionary *)params withCompletion:(void (^)(AFFNCallbackObject *))completion andFailure:(void (^)(NSError *))failure andUploadProgressBlock:(void (^)(CGFloat))uploadProgressBlock andDownloadProgressBlock:(void (^)(float))downloadProgressBlock andMultiData:(NSArray *)multiData
{
    self = [super init];
    if(self)
    {
        //Set defaults
        _isExecuting = FALSE;
        _isFinished = FALSE;
        _isConcurrent = TRUE;
        _timeoutInterval = __AFFNDefaultTimeout;
        _storagePolicy = __AFFNDefaultStoragePolicy;
        _multiSeparator = (NSString *)__AFFNDefaultMultiSeparator;
        
        //Set parameters
        _type = type;

        if(urlString)
            _urlString = [urlString copy];
                
        if(params)
            _params = [params copy];
        
        if(multiData)
            _multipartData = [multiData copy];
        
        if(completion)
            _completionBlock = [completion copy];
        
        if(failure)
            _failureBlock = [failure copy];
        
        if(uploadProgressBlock)
            _upProgressBlock = [uploadProgressBlock copy];
        
        if(downloadProgressBlock)
            _downProgressBlock = [downloadProgressBlock copy];
    }
    
    return self;
}

#pragma mark - Generate requests

/*
 * The main function of where the request creates the POST/GET request and the connection object, then starts the process.
 */
- (void)start
{    
    [self willChangeValueForKey:__AFFNKeyExecuting];
    _isExecuting = TRUE;
    [self didChangeValueForKey:__AFFNKeyExecuting];
    
    if(self.isCancelled) {
        [self willChangeValueForKey:__AFFNKeyExecuting];
        _isExecuting = FALSE;
        [self didChangeValueForKey:__AFFNKeyExecuting];
        
        [self willChangeValueForKey:__AFFNKeyFinished];
        _isFinished = TRUE;
        [self didChangeValueForKey:__AFFNKeyFinished];
        
        //TODO : temp custom error code/string
        _failureBlock([NSError errorWithDomain:@"operation.cancelled" code:600 userInfo:nil]);
        return;
    }
    
    [self performSelector:_type == (kAFFNPost | kAFFNMulti) ? @selector(generatePOSTRequest) : @selector(generateGETRequest)];
    
    _connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:FALSE];
    
    if(_connection) {
        receivedData = [NSMutableData new];
        
        [_connection scheduleInRunLoop:[NSRunLoop mainRunLoop]
                               forMode:NSDefaultRunLoopMode];
        [_connection start];
        
        requestTime = [NSDate new];
        
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
    
    NSMutableData *data = [NSMutableData new];
    
    if(_type == kAFFNMulti) {
        data = [self generateMultiRequestWithData:data];
        [data appendData:[[NSString stringWithFormat:@"--%@\r\n",_multiSeparator] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSData *jsonData = [NSData data];
    
    NSError *error;
    
    jsonData = [NSJSONSerialization dataWithJSONObject:_params options:NSJSONWritingPrettyPrinted error:&error];
    
    if(error)
        assert(error);
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    [data appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"params\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];

    [data appendData:[NSData dataWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]]];
        
    [jsonString release];
    
    if(_type == kAFFNMulti) {
        [data appendData:[[NSString stringWithFormat:@"--%@--\r\n",_multiSeparator] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    [request setHTTPBody:data];
    [request setValue:[NSString stringWithFormat:@"%d", data.length] forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"" forHTTPHeaderField:@"Accept-Encoding"];//this is so you can measure download response time, without this line it has the option to compress the response, if it does compress it then you cant predict the size and the "expectedSize" will be -1
    [request setValue:@"iOS" forHTTPHeaderField:@"User-Agent"];
    
    [data release];
    data = nil;
}

//Generates a Multi POST type request
- (NSMutableData *)generateMultiRequestWithData:(NSMutableData *)data
{
    [request addValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", _multiSeparator] forHTTPHeaderField:@"Content-Type"];
    int i = 0;
    for (id item in _multipartData) {
        i++;
        if([item isKindOfClass:[NSString class]])
        {
            [data appendData:[[NSString stringWithFormat:@"--%@\r\n", _multiSeparator] dataUsingEncoding:NSUTF8StringEncoding]];
            [data appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", item] dataUsingEncoding:NSUTF8StringEncoding]];
            [data appendData:[[NSString stringWithFormat:@"%@\r\n", item] dataUsingEncoding:NSUTF8StringEncoding]];
        } else if([item isKindOfClass:[NSData class]])
        {
            [data appendData:[[NSString stringWithFormat:@"--%@\r\n", _multiSeparator] dataUsingEncoding:NSUTF8StringEncoding]];
            [data appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"data-%d\"\r\n\r\n",i] dataUsingEncoding:NSUTF8StringEncoding]];
//            [NSString stringWithFormat:@"%@-%d-%d",[((NSData *)item).description substringWithRange:NSMakeRange(1, 8)], ((NSData *)item).hash, (rand() % 1000 + 1) ]
            [data appendData:(NSData *)item];
            [data appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        } else {
            @throw [NSException
                    exceptionWithName:@"AFFNRequestTypeException"
                    reason:@"NSData or NSString only"
                    userInfo:nil];
        }
    }
    
    return data;
}

//Generates a GET type request
- (void)generateGETRequest
{
    //construct the url with the key/value pairs in the params
    NSMutableString *paramsString = [[NSMutableString alloc] initWithString:_urlString];
    [paramsString appendString:@"?"];

    for (id key in _params) {
        [paramsString appendFormat:@"%@=%@",key,[_params objectForKey:key]];
    }

    finalURL = [[NSURL alloc] initWithString:paramsString];
    
    [paramsString release];
    paramsString = nil;
    
    request = [[NSMutableURLRequest alloc] initWithURL:finalURL cachePolicy:_storagePolicy timeoutInterval:_timeoutInterval];
    
    [request setHTTPMethod:@"GET"];

    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"iOS" forHTTPHeaderField:@"User-Agent"];
}

#pragma mark - Connection handling

//Calculates the progress of the request
- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    if(_upDone || !_upProgressBlock)
        return;
    
    if( ((CGFloat)totalBytesWritten / (CGFloat)totalBytesExpectedToWrite) >= 1)
        _upDone = TRUE;
    
    _upProgressBlock(((CGFloat)totalBytesWritten / (CGFloat)totalBytesExpectedToWrite));
}

//Failure of the connection, returns the error through the failure block
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [_connection release];
    _connection = nil;
    
    if(_failureBlock)
        _failureBlock(error);
    
    [self willChangeValueForKey:__AFFNKeyExecuting];
    _isExecuting = FALSE;
    [self didChangeValueForKey:__AFFNKeyExecuting];

    [self willChangeValueForKey:__AFFNKeyFinished];
    _isFinished = TRUE;
    [self didChangeValueForKey:__AFFNKeyFinished];

    if(error)
        assert(error);
}

//Sets the progress and data to 0 as a request/attempt has started
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if(receivedData)
        [receivedData setLength:0];
    downloadDataLength = 0;
    expectedDataLength = response.expectedContentLength;
    _downDone = FALSE;
}

//Appends data to the data object
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    downloadDataLength += data.length;
    if(receivedData)
        [receivedData appendData:data];
    
    if(_downDone || _downProgressBlock)
        return;
    
    if((downloadDataLength / expectedDataLength) >= 1)
        _downDone = TRUE;
    
    _downProgressBlock((downloadDataLength / expectedDataLength));
    
}

//Successful request function. Returns the total request time and data to the completion block in a AFFNCallbackObject
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [_connection release];
    _connection = nil;
    
    NSTimeInterval totalRequestTime = [[NSDate date] timeIntervalSinceDate:requestTime];
    
    AFFNCallbackObject *callBack = [AFFNCallbackObject callbackWithData:receivedData andReqestTime:totalRequestTime];
    
    if(_completionBlock)
        _completionBlock(callBack);
        
    [self willChangeValueForKey:__AFFNKeyExecuting];
    _isExecuting = FALSE;
    [self didChangeValueForKey:__AFFNKeyExecuting];
    
    [self willChangeValueForKey:__AFFNKeyFinished];
    _isFinished = TRUE;
    [self didChangeValueForKey:__AFFNKeyFinished];
}

#pragma mark - Dealloc

//Clean up memory
- (void)dealloc
{
    if(_params)
        [_params release];
    _params = nil;
    
    if(_urlString)
        [_urlString release];
    _urlString = nil;
    
    if(finalURL)
        [finalURL release];
    finalURL = nil;
    
    if(request)
        [request release];
    request = nil;
    
    if(_connection)
        [_connection release];
    _connection = nil;
    
    if(_completionBlock)
        [_completionBlock release];
    _completionBlock = nil;
    
    if(_failureBlock)
        [_failureBlock release];
    _failureBlock = nil;
    
    if(_upProgressBlock)
        [_upProgressBlock release];
    _upProgressBlock = nil;
    
    if(_downProgressBlock)
        [_downProgressBlock release];
    _downProgressBlock = nil;
    
    if(requestTime)
        [requestTime release];
    requestTime = nil;
    
    if(_multipartData)
        [_multipartData release];
    _multipartData = nil;
    
    if(receivedData)
        [receivedData release];
    receivedData = nil;
    
    [super dealloc];
}

@end
//
//  AFFNRequest.m
//  AFFNetworking
//
//  Created by Andrew Apperley on 2013-08-06.
//  Copyright (c) 2013 AFApps. All rights reserved.
//

#import "AFFNRequest.h"
#import "AFFNManager.h"
@implementation AFFNRequest

@synthesize progress = _progress;

- (AFFNRequest *)initWithURL:(NSString *)urlString connectionType:(AFFNPostType)type andParams:(NSDictionary *)params withCompletion:(void (^)(NSDictionary *))completion andFailBlock:(void (^)(NSError *))failure
{
    self = [super init];
    if(self)
    {
        executing = FALSE;
        finished = FALSE;
        
        _params = [params copy];
        _urlString = [urlString copy];
        _type = type;
        _completion = [completion copy];
        _failure = [failure copy];
    }
    
    return self;
}

- (BOOL)isConcurrent {return TRUE;}

- (BOOL)isExecuting { return executing; }

- (BOOL)isFinished { return finished; }

- (void)start
{
    [self willChangeValueForKey: @"isExecuting"];
    executing = TRUE;
    [self didChangeValueForKey: @"isExecuting"];
    
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

- (void)generatePOSTRequest
{
    finalURL = [[NSURL alloc] initWithString:_urlString];
    
    request = [[NSMutableURLRequest alloc] initWithURL:finalURL cachePolicy:NSURLCacheStorageAllowedInMemoryOnly timeoutInterval:120];
    
    [request setHTTPMethod:@"POST"];
    
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    //this part may be wrong, would have to look into or test
    [request setValuesForKeysWithDictionary:_params];
    
}

- (void)generateGETRequest
{
   
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    _progress = (totalBytesWritten / totalBytesExpectedToWrite) * 100;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [_connection release];
    _connection = nil;
    
    _failure(error);
    
    assert(error);
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [receivedData setLength:0];
    _progress = 0;
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [_connection release];
    _connection = nil;
    
    NSTimeInterval totalRequestTime = [[NSDate date] timeIntervalSinceDate:requestTime];
    
    NSError *error;
    
    NSJSONSerialization *json = [[NSJSONSerialization JSONObjectWithData:receivedData options:NSJSONReadingAllowFragments error: &error] retain];
    
    if (error)
        assert(error);
    
    _completion([NSDictionary dictionaryWithObjectsAndKeys:
                           json, @"receivedData",
                           [NSNumber numberWithDouble:totalRequestTime], @"requestTime", nil]);
    
    [json release];
    json = nil;
    
    [self willChangeValueForKey: @"isFinished"];
    finished = true;
    [self didChangeValueForKey: @"isFinished"];
}

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
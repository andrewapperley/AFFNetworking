//
//  AFFNRequest.m
//  AFFNetworking
//
//  Created by Andrew Apperley on 2013-08-06.
//  Copyright (c) 2013 AFApps. All rights reserved.
//

#import "AFFNRequest.h"

static NSThread *backgroundThread = nil;

@implementation AFFNRequest

@synthesize progress = _progress;

- (AFFNRequest *)initWithURL:(NSString *)urlString connectionType:(postType)type andParams:(NSDictionary *)params withCompletion:(void (^)(NSDictionary *result))completion andFailBlock:(void (^)(NSError *error))failure
{
    self = [super init];
    if(self)
    {
        _params = [[params copy] retain];
        _urlString = [[urlString copy] retain];
        _type = type;
        backgroundThread = [[NSThread alloc] init];
        _completion = completion;
        _failure = failure;
    }
    
    return self;
}

- (void)start
{
    [self performSelector:_type == POST ? @selector(generatePOSTRequest) : @selector(generateGETRequest)   onThread:backgroundThread withObject:nil waitUntilDone:true];
    
    _connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    if(_connection) {
        receivedData = [NSMutableData new];
        [_connection start];
        
        requestTime = [NSDate date];
        
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
    
    assert(error);
    
    _failure(error);
    
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
    
    NSString *dataString = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
    
    _completion([NSDictionary dictionaryWithObjectsAndKeys:
                 dataString, @"receivedData",
                 totalRequestTime, @"requestTime", nil]);
    
    [dataString release];
    dataString = nil;
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
    
    [backgroundThread release];
    backgroundThread = nil;
    
    if(_connection){
        [_connection release];
        _connection = nil;
    }
    
    if(receivedData){
        [receivedData release];
        receivedData = nil;
    }
    
    [super dealloc];
}

@end
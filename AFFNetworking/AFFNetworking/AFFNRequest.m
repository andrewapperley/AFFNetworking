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

- (AFFNRequest *)initWithURL:(NSString *)urlString connectionType:(postType)type andParams:(NSDictionary *)params withCompletion:(void (^)(NSDictionary *result))completion andFailBlock:(void (^)(NSError *error))failure
{
    self = [super init];
    if(self)
    {
        _params = [[params copy] retain];
        _urlString = [[urlString copy] retain];
        _type = type;
        backgroundThread = [[NSThread alloc] init];
    }
    
    return self;
}

- (void)start
{
    [self performSelector:@selector(generateRequest) onThread:backgroundThread withObject:nil waitUntilDone:true];
}

- (void)generateRequest
{
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response
{
    
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    
}

- (void)connection:(NSURLConnection *)connection
        didSendBodyData:(NSInteger)bytesWritten
        totalBytesWritten:(NSInteger)totalBytesWritten
        totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite;
{
    
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
}

- (void)dealloc
{
    [_params release];
    _params = nil;
    
    [_urlString release];
    _urlString = nil;
    
    [backgroundThread release];
    backgroundThread = nil;
    
    [super dealloc];
}

@end
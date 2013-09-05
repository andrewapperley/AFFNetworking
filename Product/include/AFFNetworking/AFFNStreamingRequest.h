//
//  AFFNStreamingRequest.h
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



#import "AFFNRequest.h"

@interface AFFNStreamingRequest : AFFNRequest
{
    @private
    NSString *fileName;
    NSString *extType;
    NSFileHandle *streamingFile;
    NSString *filePath;
}

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


+ (AFFNStreamingRequest *)streamingRequestWithConnectionType:(AFFNPostType)type FileName:(NSString *)name andExtention:(NSString *)ext andURL:(NSString *)urlString andParams:(NSDictionary *)params withCompletion:(void (^)(AFFNCallbackObject *result))completion andFailure:(void (^)(NSError *error))failure;

+ (AFFNStreamingRequest *)streamingRequestWithConnectionType:(AFFNPostType)type FileName:(NSString *)name andExtention:(NSString *)ext andURL:(NSString *)urlString andParams:(NSDictionary *)params withCompletion:(void (^)(AFFNCallbackObject *result))completion andFailure:(void (^)(NSError *error))failure andUploadProgressBlock:(void (^)(CGFloat))uploadProgressBlock andDownloadProgressBlock:(void (^)(float))downloadProgressBlock;
@end
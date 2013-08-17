//
//  ViewController.m
//  AFFNetworkingTestHarness
//
//  Created by Andrew Apperley on 2013-08-10.
//  Copyright (c) 2013 AFApps. All rights reserved.
//

#import "AFFNRequest.h"
#import "AFFNManager.h"
#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.    
    
    for (int i = 0; i < 30; i++) {
        AFFNRequest *request = [AFFNRequest requestWithConnectionType:kAFFNPost andURL:@"http://dev.andrewapperley.ca/aff/request_dump.php" andParams:[NSDictionary dictionaryWithObjectsAndKeys:@"Andrew",@"name", nil] withCompletion:^(AFFNCallbackObject *result) {
            
//            NSLog(@"TOTAL TIME: %f",result.totalRequestTime);
//            
//            NSString *resultString = [[[NSString alloc] initWithData:result.data encoding:NSStringEncodingConversionAllowLossy] autorelease];
//            
//            NSLog(@"RESULT: %@",resultString);
            
        } andFailure:^(NSError *error) {
            NSLog(@"ERROR: %@",error);
        } andUploadProgressBlock:^(CGFloat uploadProgress) {
//            if(uploadProgress == 1)
//                NSLog(@"Upload progress: %f", uploadProgress);
        } andDownloadProgressBlock:^(CGFloat downloadProgress) {
            if(downloadProgress == 1)
                NSLog(@"Download progress: %f", downloadProgress);
        }];
        
        [[AFFNManager sharedManager] addNetworkOperation:request];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

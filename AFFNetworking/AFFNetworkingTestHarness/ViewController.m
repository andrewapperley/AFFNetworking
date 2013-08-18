//
//  ViewController.m
//  AFFNetworkingTestHarness
//
//  Created by Andrew Apperley on 2013-08-10.
//  Copyright (c) 2013 AFApps. All rights reserved.
//

#import "ViewController.h"
#import "AFFNStreamingRequest.h"
#import "AFFNManager.h"

@interface ViewController ()

@end

@implementation ViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.    
    AFFNStreamingRequest *request = [AFFNStreamingRequest streamingRequestWithFileName:@"tests" andExtention:@"txt" andURL:@"http://dev.andrewapperley.ca/aff/request_dump.php" andParams:[NSDictionary dictionaryWithObject:@"Andrew" forKey:@"name"] withCompletion:^(AFFNCallbackObject *result)
    {
        NSLog(@"file path: %@",result.streamObjectPath);
        
    } andFailure:nil];
    
    [[AFFNManager sharedManager] addNetworkOperation:request];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

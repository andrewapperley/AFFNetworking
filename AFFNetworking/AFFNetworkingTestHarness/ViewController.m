//
//  ViewController.m
//  AFFNetworkingTestHarness
//
//  Created by Andrew Apperley on 2013-08-10.
//  Copyright (c) 2013 AFApps. All rights reserved.
//

#import "ViewController.h"
#import "AFFNRequest.h"
#import "AFFNManager.h"

@interface ViewController ()

@end

@implementation ViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.    
    
    AFFNRequest *request = [AFFNRequest requestWithConnectionType:kAFFNPost andURL:@"http://dev.andrewapperley.ca/aff/request_dump.php" andParams:[NSDictionary dictionaryWithObject:@"Andrew" forKey:@"name"] withCompletion:^(AFFNCallbackObject *result){
        NSLog(@"%@",result.data);
    
    } andFailure:^(NSError *error){
        
    }];
    
    [[AFFNManager sharedManager] addNetworkOperation:request];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

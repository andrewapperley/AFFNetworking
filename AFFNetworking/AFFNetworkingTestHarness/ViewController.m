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
    
       for (int i = 0; i < 20; i++) {
        AFFNRequest *request = [AFFNRequest requestWithURL:@"http://api.openweathermap.org/data/2.5/find?q=London&type=like&mode=json" connectionType:kAFFNPost andParams:nil withCompletion:^(AFFNCallbackObject *result) {
            
            NSLog(@"TOTAL TIME: %f",result.totalRequestTime);
            
        } andFailBlock:nil ];
        
        [[AFFNManager sharedManager] addNetworkOperation:request];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

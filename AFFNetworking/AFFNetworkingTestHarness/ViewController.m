//
//  ViewController.m
//  AFFNetworkingTestHarness
//
//  Created by Andrew Apperley on 2013-08-10.
//  Copyright (c) 2013 AFApps. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()

@end

@implementation ViewController

@synthesize _completion, _failure;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    _completion = ^(NSDictionary *result){
        NSLog(@"TOTAL TIME: %f",[[result objectForKey:@"requestTime"] doubleValue]);
//        NSLog(@"%@",[result objectForKey:@"receivedData"]);
    };
    
    _failure = ^(NSError *error) {
        
    };
    
    for (int i = 0; i < 20; i++) {
        AFFNRequest *request = [[AFFNRequest alloc] initWithURL:@"http://api.openweathermap.org/data/2.5/find?q=London&type=like&mode=json" connectionType:POST andParams:nil withCompletion:_completion andFailBlock:_failure andSender:self];
        
        [[AFFNManager sharedManager] addNetworkOperation:request];
        
        [request release];
        request = nil;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

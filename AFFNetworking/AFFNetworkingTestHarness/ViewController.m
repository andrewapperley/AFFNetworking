//
//  ViewController.m
//  AFFNetworking
//
//  Created by Andrew Apperley on 2013-08-21.
//  Copyright (c) 2013 AFApps. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //Temp AFFNImage testing
        UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 300) andPlaceholderImage:[UIImage imageNamed:@"logo.png"] andImageURL:@"http://andrewapperley.ca/backend_admin/blog_images/Screen-Shot-2013-08-17-at-1.12.18-AM.jpg" andExpiry:[NSDate date] andToCache:true];
        
        UIImageView *iv1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 300) andPlaceholderImage:[UIImage imageNamed:@"logo.png"] andImageURL:@"http://andrewapperley.ca/backend_admin/blog_images/Screen-Shot-2013-08-29-at-7.27.40-PM.jpg" andExpiry:[NSDate date] andToCache:true];
        
        UIImageView *iv2 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 300) andPlaceholderImage:[UIImage imageNamed:@"logo.png"] andImageURL:@"http://andrewapperley.ca/backend_admin/blog_images/mainpic_networking.png" andExpiry:[NSDate date] andToCache:true];
        
        [self.view addSubview:iv];
        
        [self.view addSubview:iv1];

        [self.view addSubview:iv2];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

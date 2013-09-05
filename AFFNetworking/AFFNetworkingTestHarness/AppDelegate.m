//
//  AppDelegate.m
//  AFFNetworkingTestHarness
//
//  Created by Andrew Apperley on 2013-08-10.
//  Copyright (c) 2013 AFApps. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)dealloc
{
    [_window release];
    if([AFFNManager sharedManager])
        [[AFFNManager sharedManager] release];
    [super dealloc];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[AFFNImageManager sharedManager] saveCacheListToFile];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[AFFNImageManager sharedManager] saveCacheListToFile];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Method showing the AFFNetworking call/request types
    [self testingNetworking];
    // Setup for the AFFNImageManager class
    [AFFNImageManager sharedManager];
    // VC that is used to show the AFFNImage class
    self.viewController = [[ViewController alloc] initWithNibName:nil bundle:nil];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    self.window.backgroundColor = [UIColor whiteColor];
    
    return YES;
}

- (void)testingNetworking
{
    
    
    
    //Create POST Request with completion/failure/download/upload callbacks
    NSMutableDictionary *params1 = [NSMutableDictionary new];
    for (int i = 0; i < 500; i++) {
        [params1 setObject:@"randomValue" forKey:@"randomKey"];
    }
    
    AFFNRequest *request1 = [AFFNRequest requestWithConnectionType:kAFFNPost andURL:@"http://dev.andrewapperley.ca/aff/request_dump.php" andParams:params1 withCompletion:^(AFFNCallbackObject *result){
        //Callback block for completion
        
        NSString *responseText = [[[NSString alloc] initWithData:result.data encoding:NSStringEncodingConversionAllowLossy] autorelease];
        
        //Data comes back as NSData so it's up to you to parse the response into whatever object type you need
        NSLog(@"Response: %@",responseText);
        
        //All Callbacks have the total response time as well
        NSLog(@"Request Time: %f",result.totalRequestTime);
    } andFailure:^(NSError *error){
        //Callback block for failure
        NSLog(@"Error: %@",error);
            
    } andUploadProgressBlock:^(float progress){
        if(progress == 1)
            NSLog(@"upload completed: %f",progress);
    } andDownloadProgressBlock:^(float progress){
        if(progress == 1)
            NSLog(@"download completed: %f",progress);
    
    }];
    
    //The manager releases the request when completed/failed so don't call release on it or you will have a bad time.
    [[AFFNManager sharedManager] addNetworkOperation:request1];
    
    //Clean up params
    [params1 release];
    params1 = nil;
    
    
    //Create GET Request with completion/failure callbacks (It takes the params you pass in and makes key/value pairs in the URL so pass in a url that omits the '?' at the end, this is put in with the params.
    AFFNRequest *request2 = [AFFNRequest requestWithConnectionType:kAFFNGet andURL:@"http://api.openweathermap.org/data/2.5/weather" andParams:[NSDictionary dictionaryWithObject:@"Toronto" forKey:@"q"] withCompletion:^(AFFNCallbackObject *result){
        //Callback block for completion
        
        NSError *error = nil;
        
        NSJSONSerialization *response = [NSJSONSerialization JSONObjectWithData:result.data options:NSJSONReadingAllowFragments error:&error];
        
        if(error)
            NSLog(@"Error: %@",error);
        
        //Data comes back as NSData so it's up to you to parse the response into whatever object type you need
        NSLog(@"Response: %@",response);
    } andFailure:^(NSError *error){
        //Callback block for failure
        NSLog(@"Error: %@",error);
        
    }];
    
    [[AFFNManager sharedManager] addNetworkOperation:request2];

    //Create MULTI-POST Request with completion/failure callbacks - Multi-part requests can be constructed with NSData in the array or NSStrings, this example uses NSStrings as I didn't want to included any images but it is made to support that data type.
    AFFNRequest *request3 = [AFFNRequest requestWithConnectionType:kAFFNPost andURL:@"http://dev.andrewapperley.ca/aff/request_dump.php" andParams:[NSDictionary dictionaryWithObject:@"RandomCrap" forKey:@"ForKey"] withCompletion:^(AFFNCallbackObject *result){
        //Callback block for completion
        
        NSError *error = nil;
        
       NSString *responseText = [[[NSString alloc] initWithData:result.data encoding:NSStringEncodingConversionAllowLossy] autorelease];
        
        if(error)
            NSLog(@"Error: %@",error);
        
        //Data comes back as NSData so it's up to you to parse the response into whatever object type you need
        NSLog(@"Response: %@",responseText);
    } andFailure:^(NSError *error){
        //Callback block for failure
        NSLog(@"Error: %@",error);
        
    }  andUploadProgressBlock:^(float progress){
        if(progress == 1)
            NSLog(@"upload completed: %f",progress);
    } andDownloadProgressBlock:^(float progress){
        if(progress == 1)
            NSLog(@"download completed: %f",progress);
        
    }andMultiData:[NSArray arrayWithObjects:@"This", @"param1", @"is", @"param2", @"cool!", @"param3", nil]];
    
    [[AFFNManager sharedManager] addNetworkOperation:request3];

    //Create STREAMING Request - This will give you back a string of where the saved file is in the filesystem so you can use it later
    AFFNStreamingRequest *request4 = [AFFNStreamingRequest streamingRequestWithConnectionType:kAFFNGet FileName:@"Test" andExtention:@"json" andURL:@"http://api.openweathermap.org/data/2.5/weather" andParams:[NSDictionary dictionaryWithObject:@"Toronto" forKey:@"q"] withCompletion:^(AFFNCallbackObject *result){
        NSLog(@"Result - Saved File URL: %@",result.streamObjectPath);
    } andFailure:^(NSError *error){
        NSLog(@"Error: %@",error);
    }];
    
    [[AFFNManager sharedManager] addNetworkOperation:request4];
}

@end

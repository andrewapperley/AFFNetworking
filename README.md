AFFNetworking
=============

AFFNetworking is networking wrapper that provides an easy way to interface with a server using signed (oAuth) and unsigned requests.
It features support for uploading, downloading, progress, streaming data, RESTful requests. As AFFNetworking is based on NSURLConnection, NSOperation, and NSOperationQueue it
will be a fast and easy way to send/receive data from/to a server and takes away all the hassle of writing the barebones code yourself, allowing you worry about your project instead.

**oAuth will be added in the near future**

##Support

####IOS
Earliest tested and supported build and deployment target - iOS 6.0.
Latest tested and supported build and deployment target - iOS 7.0.

##ARC Compatibility
AFFNetworking is built from non-ARC and is currently not ARC friendly. Use '-fno-objc-arc' compiler flags in your project's Build Phases for AFFNetworking files when using ARC.
	
##Installation
Copy the "Product" folder or the contents of said folder into your project.
Add the current line to your <AppName>-Prefix.pch file :
	
	    objective-c
      #import "AFFNManager.h"


####Types of Requests
AFFNRequest - A request that lets you do POST, GET, and Multi-POST requests with callbacks when it fails or completes.

AFFNStreamingRequest - A request that lets you stream the data from a POST request into any file type that sits in the /Documents folder of the app bundle

####Usage - Examples

**//Create POST Request with completion/failure/download/upload callbacks**
		
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
    
    
**//Create GET Request with completion/failure callbacks (It takes the params you pass in and makes key/value pairs in the URL so pass in a url that omits the '?' at the end.**
   
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

**//Create MULTI-POST Request with completion/failure callbacks - Multi-part requests can be constructed with NSData in the array or NSStrings, this example uses NSStrings as I didn't want to included any images but it is made to support that data type.**
	
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

**//Create STREAMING Request - This will give you back a string of where the saved file is in the filesystem so you can use it later**
	
	 AFFNStreamingRequest *request4 = [AFFNStreamingRequest streamingRequestWithFileName:@"Test" andExtention:@"json" andURL:@"http://api.openweathermap.org/data/2.5/weather?q=Toronto" andParams:nil withCompletion:^(AFFNCallbackObject *result){
        NSLog(@"Result - Saved File URL: %@",result.streamObjectPath);
    } andFailure:^(NSError *error){
        NSLog(@"Error: %@",error);
    }];
    
    [[AFFNManager sharedManager] addNetworkOperation:request4];


##Changelog
August 18th, 2013 - Initial Release as a static library - 1.0.1

//
//  AppDelegate.m
//  RTCatDemo1v1
//
//  Created by chencong on 2/19/16.
//  Copyright © 2016 shishimao. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


- (void)getP2PServerToken
{

    NSURLSessionConfiguration* sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];

    NSURLSession* session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:nil delegateQueue:nil];
    

    NSURL* URL = [NSURL URLWithString:@"https://api.realtimecat.com/v0.1/tokens"];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"POST";
    
    
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    [request addValue:@"apikey" forHTTPHeaderField:@"X-RTCAT-APIKEY"];
    [request addValue:@"secret" forHTTPHeaderField:@"X-RTCAT-SECRET"];
    
    // JSON Body
    NSDictionary* bodyObject = @{
                                 @"type": @"pub",
                                 @"session_id": @"session_id"
                                 };
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:bodyObject options:kNilOptions error:NULL];
    
    /* Start a new Task */
    NSURLSessionDataTask* task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error == nil) {

            NSString *resStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            NSData *jsondata = [resStr dataUsingEncoding:NSUTF8StringEncoding];
            
            NSDictionary *resDic = [NSJSONSerialization JSONObjectWithData:jsondata options:NSJSONReadingMutableLeaves error:nil];
            
            resStr = [resDic objectForKey:@"token"];
            printf("Token: %s\n",resStr.UTF8String);
            _tokenServer = resStr;
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"tokenServer" object:nil];
        }
        else {
            // Failure
            NSLog(@"URL Session Task Failed: %@", [error localizedDescription]);
            _tokenServer = nil;
        }
    }];
    [task resume];
}



@end

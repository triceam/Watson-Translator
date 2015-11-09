//
//  AppDelegate.m
//  Watson Translator
//
//  Created by Andrew Trice on 9/9/15.
//  Copyright (c) 2015 Andrew Trice. All rights reserved.
//

#import "AppDelegate.h"
#import <IMFCore/IMFCore.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    
    IMFClient *imfClient = [IMFClient sharedInstance];
    [imfClient initializeWithBackendRoute:@"app route" backendGUID:@"app guid"];
    
    // capture and record uncaught exceptions (crashes)
    [IMFLogger captureUncaughtExceptions];
    
    // change the verbosity filter to "debug and above"
    [IMFLogger setLogLevel:IMFLogLevelInfo];
    
    //create logger instance
    IMFLogger *logger = [IMFLogger loggerForName:@"AppDelegate"];
    [logger logDebugWithMessages:@"didFinishLaunchingWithOptions"];
    
    //start recording operational analytics
    [[IMFAnalytics sharedInstance] startRecordingApplicationLifecycleEvents];
    
    [self verifyConnection];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    
    
    [IMFLogger send];
    [[IMFAnalytics sharedInstance] sendPersistedLogs];
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



- (void) verifyConnection {
    
    IMFLogger *logger = [IMFLogger loggerForName:@"AppDelegate"];
    
    //verify connection to bluemix and send logs
    IMFAuthorizationManager *authManager = [IMFAuthorizationManager sharedInstance];
    [authManager obtainAuthorizationHeaderWithCompletionHandler:^(IMFResponse *response, NSError *error) {
        if (error==nil)
        {
            [logger logInfoWithMessages:@"You have connected to Bluemix successfully"];
            
            [IMFLogger send];
            [[IMFAnalytics sharedInstance] sendPersistedLogs];
            
        } else {
            [logger logErrorWithMessages:@"%@",error ];
        }
    }];
}


@end

//
//  ShareBoxAppDelegate.m
//  ShareBox
//
//  Created by Ryan Wang on 11-4-11.
//  Copyright 2011 DDMap. All rights reserved.
//

#import "ShareBoxAppDelegate.h"
#import "RootViewController.h"
#import "OAuthConstants.h"

@implementation ShareBoxAppDelegate

@synthesize window;
@synthesize navigationController;


#pragma mark -
#pragma mark Application lifecycle

//- (void)awakeFromNib {    
//    
//    RootViewController *rootViewController = (RootViewController *)[navigationController topViewController];
//    rootViewController.managedObjectContext = self.managedObjectContext;
//}
//- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {

    NIF_INFO(@"back url -- %@", url);

    NIF_INFO(@"schema : %@",[url scheme]);
    if ([[url scheme] isEqualToString:@"ddsharebox"]) {
      
        // Sina
        NSRange range = [[url absoluteString] rangeOfString:kSinaOAuthCallBackNotification];
            if (range.length > 0) {

                NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[url absoluteString] forKey:kSinaOAuthCallBackNotification];
                [[NSNotificationCenter defaultCenter] postNotificationName:kSinaOAuthCallBackNotification object:nil userInfo:userInfo];
                
                return YES;
        }
        
        // QQ
        
        
    
            
    }
    
    return YES;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after application launch.

    // Add the navigation controller's view to the window and display.
    [self.window addSubview:navigationController.view];
    [self.window makeKeyAndVisible];

    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
//    [self saveContext];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


/**
 applicationWillTerminate: saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application {
 //   [self saveContext];
}


- (void)dealloc {
        
    [navigationController release];
    [window release];
    [super dealloc];
}


@end


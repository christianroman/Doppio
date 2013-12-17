//
//  AppDelegate.m
//  Coffee Me
//
//  Created by Christian Roman on 17/12/13.
//  Copyright (c) 2013 Christian Roman. All rights reserved.
//

#import "AppDelegate.h"
#import "CRGradientNavigationBar.h"
#import "MainViewController.h"
#import "UIColor+Utilities.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window setTintColor:[UIColor colorWithHex:0x24CA8A]];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithNavigationBarClass:[CRGradientNavigationBar class] toolbarClass:nil];
    
    UIColor *firstColor = [UIColor colorWithHex:0x24CA8A];
    UIColor *secondColor = [UIColor colorWithHex:0x24CA8A];
    
    NSArray *colors = [NSArray arrayWithObjects:firstColor, secondColor, nil];
    
    [[CRGradientNavigationBar appearance] setBarTintGradientColors:colors];
    [[navigationController navigationBar] setTranslucent:NO];
    
    [[CRGradientNavigationBar appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor whiteColor] }];
    
    MainViewController *viewController = [[MainViewController alloc] init];
    [navigationController setViewControllers:@[viewController]];
    
    [self.window setRootViewController:navigationController];
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

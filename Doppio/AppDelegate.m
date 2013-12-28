//
//  AppDelegate.m
// Doppio
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
    
    UIColor *tintColor = [UIColor colorWithHex:0x5ED897];
    [self.window setTintColor:tintColor];

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithNavigationBarClass:[CRGradientNavigationBar class] toolbarClass:nil];
    
    NSArray *colors = @[[UIColor colorWithHex:0x9EEDBF], tintColor];
    [[CRGradientNavigationBar appearance] setBarTintGradientColors:colors];
    [[CRGradientNavigationBar appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor whiteColor] }];
    [[CRGradientNavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[navigationController navigationBar] setTranslucent:NO];
    
    MainViewController *mainViewController = [[MainViewController alloc] init];
    [navigationController setViewControllers:@[mainViewController]];
    [self.window setRootViewController:navigationController];
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    
}

@end

//
//  MainViewController.m
//  Coffee Me
//
//  Created by Christian Roman on 17/12/13.
//  Copyright (c) 2013 Christian Roman. All rights reserved.
//

#import "MainViewController.h"
#import "CoffeeMeClient.h"
#import "StoreItems.h"

@interface MainViewController ()

@end

@implementation MainViewController

#pragma mark - UINavigationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    self.title = @"Coffee Me";
    
    CoffeeMeClient *client = [[CoffeeMeClient alloc] init];
    
    [client enqueueUserRequestWithMethod:@"GET" relativePath:@"stores" parameters:nil resultClass:StoreItems.class];
    
    [[[client enqueueRequestWithMethod:@"GET" path:@"user" parameters:nil resultClass:StoreItems.class]
      deliverOn:RACScheduler.mainThreadScheduler]
     subscribeNext:^(GHGitHubUser *user) {
         // Do something with the fetched user here.
     } error:^(NSError *error) {
         // Handle errors here.
     }];
}

/*
- (NSString *)title
{
    return @"Home";
}
 */

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

@end

//
//  StoresViewController.h
// Doppio
//
//  Created by Christian Roman on 22/12/13.
//  Copyright (c) 2013 Christian Roman. All rights reserved.
//

#import <UIKit/UIKit.h>

@import CoreLocation;

@interface StoresViewController : UIViewController

@property (nonatomic, strong) NSArray *stores;
@property (nonatomic, strong) CLLocation *location;
@property (nonatomic, assign) BOOL includeUserLocation;

@end

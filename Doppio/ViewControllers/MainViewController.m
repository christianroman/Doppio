//
//  MainViewController.m
// Doppio
//
//  Created by Christian Roman on 17/12/13.
//  Copyright (c) 2013 Christian Roman. All rights reserved.
//

#import "MainViewController.h"
#import "StoresViewController.h"
#import "CRClient+Stores.h"
#import "UIColor+Utilities.h"
#import "MRProgress.h"

@import CoreLocation;

@interface MainViewController () <CLLocationManagerDelegate, UITextFieldDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *currentLocation;

@property (nonatomic, weak) IBOutlet UITextField *searchTextField;
@property (nonatomic, weak) IBOutlet UIButton *searchButton;
@property (nonatomic, weak) IBOutlet UIImageView *cofffeeImage;

@end

@implementation MainViewController

#pragma mark - UIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.currentLocation = [[CLLocation alloc] init];
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.distanceFilter = kCLDistanceFilterNone;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        [self.locationManager startUpdatingLocation];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    self.title = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
    
    [self.searchButton setTitleColor:self.navigationController.view.window.tintColor forState:UIControlStateNormal];
    [self.searchButton setTitleColor:[UIColor darkerColorForColor:self.navigationController.view.window.tintColor] forState:UIControlStateHighlighted];
    [self.searchButton.layer setCornerRadius:4.0f];
    [self.searchTextField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

#pragma mark - Class methods

- (IBAction)search:(id)sender
{
    if ((![CLLocationManager locationServicesEnabled])
        || ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted)
        || ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Location services must be enabled in Settings.", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        
    } else {
        
        [MRProgressOverlayView showOverlayAddedTo:self.navigationController.view animated:YES];
        
        [[CRClient sharedClient] getNearbyStoresFromLatitude:self.currentLocation.coordinate.latitude longitude:self.currentLocation.coordinate.longitude completion:^(NSArray *stores, NSError *error) {
            if (!error){
                
                [MRProgressOverlayView dismissOverlayForView:self.navigationController.view animated:YES];
                
                StoresViewController *storesViewController = [[StoresViewController alloc] init];
                [storesViewController setStores:stores];
                [self.navigationController pushViewController:storesViewController animated:YES];
                
            } else {
                
                [MRProgressOverlayView dismissOverlayForView:self.navigationController.view animated:YES];
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alertView show];
                
            }
        }];
        
    }
}

- (void)forwardGeocoding:(NSString *)address
{
    [MRProgressOverlayView showOverlayAddedTo:self.navigationController.view animated:YES];
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:address completionHandler:^(NSArray *placemarks, NSError *error) {
        
        if (!error) {
            
            if (placemarks && [placemarks count]) {
                
                CLPlacemark *placemark = [placemarks firstObject];
                
                [[CRClient sharedClient] getNearbyStoresFromLatitude:placemark.location.coordinate.latitude longitude:placemark.location.coordinate.longitude completion:^(NSArray *stores, NSError *error) {
                    if (!error){
                        
                        [MRProgressOverlayView dismissOverlayForView:self.navigationController.view animated:YES];
                        
                        StoresViewController *storesViewController = [[StoresViewController alloc] init];
                        [storesViewController setStores:stores];
                        [storesViewController setIncludeUserLocation:NO];
                        [storesViewController setLocation:placemark.location];
                        [self.navigationController pushViewController:storesViewController animated:YES];
                        
                    } else {
                        
                        [MRProgressOverlayView dismissOverlayForView:self.navigationController.view animated:YES];
                        
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                        [alertView show];
                        
                    }
                }];
                
            } else {
                [MRProgressOverlayView dismissOverlayForView:self.navigationController.view animated:YES];
            }
            
        } else {
            
            [MRProgressOverlayView dismissOverlayForView:self.navigationController.view animated:YES];
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertView show];
        }
    }];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    self.currentLocation = [locations lastObject];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.searchTextField) {
        [textField resignFirstResponder];
        
        if (![textField.text isEqualToString:@""]) {
            [self forwardGeocoding:textField.text];
        }
        
    }
    return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [UIView animateWithDuration:0.3 animations:^{
        
        CGRect viewFrame = self.view.frame;
        viewFrame.origin.y -= 80;
        self.view.frame = viewFrame;
        
        CGRect coffeeImageFrame = self.cofffeeImage.frame;
        coffeeImageFrame.origin.y += 50;
        self.cofffeeImage.frame = coffeeImageFrame;
        
    } completion:nil];
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [UIView animateWithDuration:0.3 animations:^{
        
        CGRect viewFrame = self.view.frame;
        viewFrame.origin.y += 80;
        self.view.frame = viewFrame;
        
        CGRect coffeeImageFrame = self.cofffeeImage.frame;
        coffeeImageFrame.origin.y -= 50;
        self.cofffeeImage.frame = coffeeImageFrame;
        
    } completion:nil];
}

@end

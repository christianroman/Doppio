//
//  DetailViewController.m
// Doppio
//
//  Created by Christian Roman on 23/12/13.
//  Copyright (c) 2013 Christian Roman. All rights reserved.
//

#import "DetailViewController.h"
#import "WilcardGestureRecognizer.h"
#import "StoreAnnotation.h"
#import "Store.h"
#import "UIColor+Utilities.h"
#import "UIImage+Circle.h"

@import MapKit;
@import CoreLocation;
@import CoreGraphics;

@interface DetailViewController () <MKMapViewDelegate, CLLocationManagerDelegate, UIActionSheetDelegate>

@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, weak) IBOutlet UIView *dataView;
@property (nonatomic, weak) IBOutlet UILabel *addressLabel;
@property (nonatomic, weak) IBOutlet UILabel *open24HrsTodayLabel;
@property (nonatomic, weak) IBOutlet UILabel *openNowLabel;
@property (nonatomic, weak) IBOutlet UILabel *phoneLabel;
@property (nonatomic, weak) IBOutlet UILabel *featuresLabel;
@property (nonatomic, weak) IBOutlet UIButton *phoneButtonValue;
@property (nonatomic, weak) IBOutlet UILabel *featuresLabelValue;

@property (nonatomic, weak) UIButton *userLocationButton;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *userLocation;
@property (nonatomic, strong) WildcardGestureRecognizer *_tapInterceptor;

@property (nonatomic, assign) CGRect dataFrame;
@property (nonatomic, assign) CGRect mapViewFrame;

@end

@implementation DetailViewController

#pragma mark - UIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.userLocation = [[CLLocation alloc] init];
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
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(getDirections)];
    
    [self.navigationItem setRightBarButtonItem:rightButton animated:YES];
    
    self.title = self.store.name;
    
    NSString *address = [NSString stringWithFormat:@"%@\n%@", self.store.address1, self.store.address2];
    
    [self.addressLabel setText:address];
    [self.open24HrsTodayLabel setText:[self.store.open24HrsToday intValue] ? NSLocalizedString(@"Yes", nil) : NSLocalizedString(@"No", nil)];
    [self.openNowLabel setText:[self.store.openNow intValue] ? NSLocalizedString(@"Open", nil) : NSLocalizedString(@"Closed", nil)];
    
    if (self.store.phone && ![self.store.phone isEqualToString:@""]) {
        [self.phoneLabel setHidden:NO];
        [self.phoneButtonValue setHidden:NO];
        [self.phoneButtonValue setEnabled:YES];
         [self.phoneButtonValue setTitle:self.store.phone forState:UIControlStateNormal];
    } else if (self.store.features && ![self.store.features isEqualToString:@""]) {
        
        CGRect featuresFrame = self.featuresLabel.frame;
        CGRect featuresValueFrame = self.featuresLabelValue.frame;
        
        featuresFrame.origin.y = self.phoneLabel.frame.origin.y;
        featuresValueFrame.origin.y = self.phoneButtonValue.frame.origin.y;
        
        [self.featuresLabel setFrame:featuresFrame];
        [self.featuresLabelValue setFrame:featuresValueFrame];
        
    }
    
    if (self.store.features && ![self.store.features isEqualToString:@""]) {
        [self.featuresLabel setHidden:NO];
        [self.featuresLabelValue setHidden:NO];
        
        NSString *features = [self.store.features stringByReplacingOccurrencesOfString:@"," withString:@", "];
        [self.featuresLabelValue setText:features];
    }
    
    [self.openNowLabel.layer setCornerRadius:3.0f];
    [self.openNowLabel setBackgroundColor:[self.store.openNow intValue] ? self.navigationController.view.window.tintColor : [UIColor lightGrayColor]];
    
	MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake([self.store.lat doubleValue], [self.store.lng doubleValue]), 500, 500);
    [self.mapView setRegion:region animated:NO];
    
    StoreAnnotation *annotation = [[StoreAnnotation alloc] init];
    [annotation setTitle:self.store.name];
    [annotation setSubtitle:self.store.address1];
    [annotation setIsOpen:[self.store.openNow intValue]];
    
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([self.store.lat doubleValue], [self.store.lng doubleValue]);
    [annotation setCoordinate:coordinate];
    [self.mapView addAnnotation:annotation];
    
    self._tapInterceptor = [[WildcardGestureRecognizer alloc] init];
    __weak WildcardGestureRecognizer *tapInterceptor = self._tapInterceptor;
    __weak typeof(self) weakSelf = self;
    tapInterceptor.touchesBeganCallback = ^(NSSet * touches, UIEvent * event) {
        typeof(self) strongSelf = weakSelf;
        [strongSelf.mapView removeGestureRecognizer:tapInterceptor];
        strongSelf._tapInterceptor = nil;
        [strongSelf openMapView];
    };
    [self.mapView addGestureRecognizer:tapInterceptor];
}

#pragma mark - Class methods

- (IBAction)tapPhoneNumber:(id)sender
{
    if (![self.phoneButtonValue.currentTitle isEqualToString:@""]) {
        NSString *url = [NSString stringWithFormat:@"%@%@", @"tel://", self.phoneButtonValue.currentTitle];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }
}

- (void)openMapView
{
    [UIView animateWithDuration:0.5f
                     animations:^{
                         
                         self.dataFrame = self.dataView.frame;
                         self.dataView.frame = CGRectMake(self.dataView.frame.origin.x, self.view.frame.size.height, self.dataView.frame.size.width, self.dataView.frame.size.height);
                         
                         self.mapViewFrame = self.mapView.frame;
                         
                         CGRect selfViewFrame = self.view.frame;
                         selfViewFrame.origin.y = 0;
                         self.mapView.frame = selfViewFrame;
                         
                     } completion:^(BOOL finished) {
                         
                         self.userLocationButton = [UIButton buttonWithType:UIButtonTypeCustom];
                         [self.userLocationButton addTarget:self action:@selector(centerMapUserLocation) forControlEvents:UIControlEventTouchUpInside];
                         [self.userLocationButton setFrame:CGRectMake(self.mapView.frame.origin.x + 10, self.mapView.frame.origin.y + 10, 32, 32)];
                         [self.userLocationButton setBackgroundImage:[UIImage imageNamed:@"userLocation"] forState:UIControlStateNormal];
                         [self.userLocationButton setAlpha:0.0];
                         [self.mapView addSubview:self.userLocationButton];
                         
                         /* Close left button */
                         UIBarButtonItem *close = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", nil) style:UIBarButtonItemStyleDone target:self action:@selector(closeMapView)];
                         
                         [self.navigationItem setLeftBarButtonItem:close animated:YES];
                         
                         self.navigationItem.title  = NSLocalizedString(@"Location", nil);
                         self.navigationItem.titleView = nil;
                         
                         [UIView animateWithDuration:0.5f animations:^{
                             
                             [self.userLocationButton setAlpha:0.8];
                             [self zoomMapViewToFitAnnotations];
                             
                         } completion:^(BOOL finished) {
                             
                             [self.mapView setUserInteractionEnabled:YES];
                             [self.mapView setZoomEnabled:YES];
                             [self.mapView setScrollEnabled:YES];
                             
                         }];
                         
                     }];
}

- (void)closeMapView
{
    [self.mapView setUserInteractionEnabled:NO];
    [self.mapView setZoomEnabled:NO];
    [self.mapView setScrollEnabled:NO];
    
    [self.navigationItem setLeftBarButtonItem:nil animated:NO];
    
    self.navigationItem.title = self.store.name;
    
    [UIView animateWithDuration:0.5f
                     animations:^{
                         
                         /* hide User location button */
                         self.userLocationButton.alpha = 0;
                         self.dataView.frame = self.dataFrame;
                         self.mapView.frame = self.mapViewFrame;
                         self.navigationItem.titleView.alpha = 1.0f;
                         
                     } completion:^(BOOL finished){
                         
                         MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake([self.store.lat doubleValue], [self.store.lng doubleValue]), 500, 500);
                         [self.mapView setRegion:region animated:YES];
                         
                         [self.userLocationButton removeFromSuperview];
                         self.userLocationButton = nil;
                         
                         self._tapInterceptor = [[WildcardGestureRecognizer alloc] init];
                         __weak WildcardGestureRecognizer *tapInterceptor = self._tapInterceptor;
                         __weak typeof(self) weakSelf = self;
                         tapInterceptor.touchesBeganCallback = ^(NSSet * touches, UIEvent * event) {
                             typeof(self) strongSelf = weakSelf;
                             [strongSelf.mapView removeGestureRecognizer:tapInterceptor];
                             strongSelf._tapInterceptor = nil;
                             [strongSelf openMapView];
                         };
                         [self.mapView addGestureRecognizer:tapInterceptor];
                         
                     }];
    
}

- (void)getDirections
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Directions", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:@"Apple Maps", @"Google Maps", @"Waze", nil];
    [actionSheet showInView:self.view];
}

- (void)zoomMapViewToFitAnnotations
{
    CLLocation *storeLocation = [[CLLocation alloc] initWithLatitude:[self.store.lat doubleValue] longitude:[self.store.lng doubleValue]];
    CLLocationDistance meters = [self.userLocation distanceFromLocation:storeLocation];
    
    MKCoordinateRegion region;
    
    if (meters < 12000) {
        NSArray *annotations = self.mapView.annotations;
        int count = [self.mapView.annotations count];
        
        MKMapPoint points[count];
        for(int i = 0; i < count; i++) {
            CLLocationCoordinate2D coordinate = [(id <MKAnnotation>)[annotations objectAtIndex:i] coordinate];
            points[i] = MKMapPointForCoordinate(coordinate);
        }
        
        MKMapRect mapRect = [[MKPolygon polygonWithPoints:points count:count] boundingMapRect];
        region = MKCoordinateRegionForMapRect(mapRect);
        
        float minimumZoomArc = 0.01; //0.014;
        
        region.span.latitudeDelta  *= 1.15;
        region.span.longitudeDelta *= 1.15;
        
        if(region.span.latitudeDelta > 360) { region.span.latitudeDelta  = 360; }
        if(region.span.longitudeDelta > 360) { region.span.longitudeDelta = 360; }
        
        if(region.span.latitudeDelta  < minimumZoomArc) { region.span.latitudeDelta  = minimumZoomArc; }
        if(region.span.longitudeDelta < minimumZoomArc) { region.span.longitudeDelta = minimumZoomArc; }
        
    } else {
        region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake([self.store.lat doubleValue], [self.store.lng doubleValue]), 500, 500);
    }
    
    [self.mapView setRegion:region animated:YES];
    
}

- (void)centerMapUserLocation
{
    [self.mapView setCenterCoordinate:self.userLocation.coordinate animated:YES];
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    static NSString *AnnotationViewID = @"annotationViewID";
    
    MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
    if (!annotationView) {
        
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
        annotationView.canShowCallout = YES;
        annotationView.draggable = NO;
        
    } else {
        annotationView.annotation = annotation;
    }
    
    StoreAnnotation *ann = (StoreAnnotation *)annotation;
    
    BOOL isOpen = ann.isOpen;
    
    [annotationView setImage:[UIImage imageNamed: isOpen ? @"pinOn" : @"pinOff"]];
    
    UIImage *leftImage = [UIImage circleImageWithSize:32 color: isOpen ? self.navigationController.view.tintColor : [UIColor lightGrayColor]];
    UIImageView *leftIconView = [[UIImageView alloc] initWithImage:leftImage];
    
    annotationView.centerOffset = CGPointMake(0, - (annotationView.image.size.height / 2));
    annotationView.leftCalloutAccessoryView = leftIconView;
    
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    MKAnnotationView *aV;
    for (aV in views) {
        if ([aV.annotation isKindOfClass:[MKUserLocation class]]) {
            continue;
        }
        MKMapPoint point =  MKMapPointForCoordinate(aV.annotation.coordinate);
        if (!MKMapRectContainsPoint(self.mapView.visibleMapRect, point)) {
            continue;
        }
        CGRect endFrame = aV.frame;
        aV.frame = CGRectMake(aV.frame.origin.x, aV.frame.origin.y - self.view.frame.size.height, aV.frame.size.width, aV.frame.size.height);
        [UIView animateWithDuration:0.5 delay:0.04 * [views indexOfObject:aV] options:UIViewAnimationOptionCurveLinear animations:^{
            aV.frame = endFrame;
        } completion:^(BOOL finished) {
            if (finished) {
                [UIView animateWithDuration:0.05 animations:^{
                    aV.transform = CGAffineTransformMakeScale(1.0, 0.8);
                } completion:^(BOOL finished) {
                    if (finished) {
                        [UIView animateWithDuration:0.1 animations:^{
                            aV.transform = CGAffineTransformIdentity;
                        }];
                    }
                }];
            }
        }];
    }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    CLLocationCoordinate2D storeCoordinate = CLLocationCoordinate2DMake([self.store.lat doubleValue], [self.store.lng doubleValue]);
    NSString *url = nil;
    
    switch (buttonIndex) {
        case 0:
        {
            MKPlacemark* place = [[MKPlacemark alloc] initWithCoordinate:storeCoordinate addressDictionary:nil];
            MKMapItem* destination = [[MKMapItem alloc] initWithPlacemark: place];
            destination.name = self.store.name;
            NSArray* items = [[NSArray alloc] initWithObjects: destination, nil];
            NSDictionary* options = [[NSDictionary alloc] initWithObjectsAndKeys:
                                     MKLaunchOptionsDirectionsModeDriving,
                                     MKLaunchOptionsDirectionsModeKey, nil];
            [MKMapItem openMapsWithItems: items launchOptions: options];
            break;
        }
        case 1:
            url = [NSString stringWithFormat:@"comgooglemaps://?saddr=%f,%f&daddr=%f,%f&zoom=10", storeCoordinate.latitude, storeCoordinate.longitude, self.userLocation.coordinate.latitude, self.userLocation.coordinate.longitude];
            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:url]]) {
                [[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
            }
            break;
        case 2:
            url = [NSString stringWithFormat:@"waze://?ll=%f,%f&navigate=yes", storeCoordinate.latitude, storeCoordinate.longitude];
            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:url]]) {
                [[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
            }
            break;
        default:
            break;
    }
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    self.userLocation = [locations lastObject];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
}

@end

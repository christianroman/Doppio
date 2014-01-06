//
//  StoresViewController.m
// Doppio
//
//  Created by Christian Roman on 22/12/13.
//  Copyright (c) 2013 Christian Roman. All rights reserved.
//

#import "StoresViewController.h"
#import "StoreAnnotation.h"
#import "Store.h"
#import "CRClient+Stores.h"
#import "DetailViewController.h"
#import "StoreCell.h"
#import "WilcardGestureRecognizer.h"
#import "UIColor+Utilities.h"
#import "UIImage+Circle.h"
#import "MRProgress.h"

#define METERS_TO_FEET  3.2808399
#define METERS_TO_MILES 0.000621371192
#define METERS_CUTOFF   1000
#define FEET_CUTOFF     3281
#define FEET_IN_MILES   5280

@import MapKit;
@import CoreLocation;
@import CoreGraphics;

@interface StoresViewController () <MKMapViewDelegate, CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *userLocation;

@property (nonatomic, assign) BOOL mapViewIsOpen;

@property (nonatomic, assign) CGRect mapViewFrame;
@property (nonatomic, assign) CGRect resultsTableViewFrame;

@property (nonatomic, weak) UIButton *searchHereButton;
@property (nonatomic, weak) UIButton *userLocationButton;
@property (nonatomic, weak) UIButton *refreshButton;
@property (nonatomic, weak) UIButton *filterButton;
@property (nonatomic, weak) UIView *filterView;

@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, weak) IBOutlet UITableView *resultsTableView;

@property (nonatomic, strong) WildcardGestureRecognizer *_tapInterceptor;

@end

@implementation StoresViewController

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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Results";
    self.mapViewIsOpen = NO;
    
    self.mapView.frame = CGRectMake(self.mapView.frame.origin.x, self.mapView.frame.origin.y, self.mapView.frame.size.width, 115);
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(self.location.coordinate.latitude, self.location.coordinate.longitude), 2000, 2000);
	[self.mapView setRegion:region animated:NO];
    
    for (Store *store in self.stores) {
        
        StoreAnnotation *annotation = [[StoreAnnotation alloc] init];
        [annotation setTitle:store.name];
        [annotation setSubtitle:store.address1];
        [annotation setIsOpen:[store.openNow boolValue]];
        [annotation setIndex:[self.stores indexOfObject:store]];
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([store.lat doubleValue], [store.lng doubleValue]);
        [annotation setCoordinate:coordinate];
        [self.mapView addAnnotation:annotation];
        
    }
    
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
    
    if(![self.stores count]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:NSLocalizedString(@"Empty results", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    }
    
    [self zoomMapViewToFitAnnotationsWithUserLocation:self.includeUserLocation];
}

#pragma mark - Class methods

- (void)openMapView
{
    [UIView animateWithDuration:0.5f
                     animations:^{
                         
                         self.mapViewFrame = self.mapView.frame;
                         self.resultsTableViewFrame = self.resultsTableView.frame;
                         [self.mapView setFrame:CGRectMake(self.mapView.frame.origin.x, self.mapView.frame.origin.y, self.mapView.frame.size.width, self.view.frame.size.height - self.mapView.frame.origin.x)];
                         [self.resultsTableView setFrame:CGRectMake(self.resultsTableView.frame.origin.x, self.view.frame.size.height, self.resultsTableView.frame.size.width, self.resultsTableView.frame.size.height)];
                         
                     } completion:^(BOOL finished) {
                         
                         self.userLocationButton = [UIButton buttonWithType:UIButtonTypeCustom];
                         [self.userLocationButton addTarget:self action:@selector(centerMapUserLocation) forControlEvents:UIControlEventTouchUpInside];
                         [self.userLocationButton setFrame:CGRectMake( self.mapView.frame.origin.x + 10, self.mapView.frame.origin.y + 10, 32, 32)];
                         [self.userLocationButton setBackgroundImage:[UIImage imageNamed:@"userLocation"] forState:UIControlStateNormal];
                         [self.userLocationButton setAlpha:0.0];
                         [self.mapView addSubview:self.userLocationButton];
                         
                         UIBarButtonItem *close = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", nil) style:UIBarButtonItemStyleDone target:self action:@selector(closeMapView)];
                         [close setTintColor:[UIColor whiteColor]];
                         
                         UIBarButtonItem *refreshBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(searchOnMapViewRegion)];
                         
                         [self.navigationItem setRightBarButtonItem:refreshBarButtonItem animated:YES];
                         [self.navigationItem setLeftBarButtonItem:close animated:YES];
                         
                         if (!self.searchHereButton) {
                             self.searchHereButton = [UIButton buttonWithType:UIButtonTypeCustom];
                             [self.searchHereButton addTarget:self action:@selector(searchOnMapViewRegion) forControlEvents:UIControlEventTouchUpInside];
                             [self.searchHereButton setFrame:CGRectMake(self.mapView.frame.size.width / 2 - 116 , self.mapView.frame.size.height - 90, 232, 47)];
                             [self.searchHereButton.layer setCornerRadius:4.0f];
                             [self.searchHereButton setBackgroundColor:self.navigationController.view.tintColor];
                             self.searchHereButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
                             [self.searchHereButton setTitle:NSLocalizedString(@"Search here", nil) forState:UIControlStateNormal];
                             [self.searchHereButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                             [self.searchHereButton setAlpha:0.0];
                             [self.mapView addSubview:self.searchHereButton];
                         }
                         
                         [UIView animateWithDuration:0.5f animations:^{
                             
                             [self.searchHereButton setAlpha:0.8];
                             [self.userLocationButton setAlpha:0.8];
                             [self zoomMapViewToFitAnnotationsWithUserLocation:self.includeUserLocation];
                             
                         } completion:^(BOOL finished) {
                             
                             [self.searchHereButton setUserInteractionEnabled:YES];
                             [self.mapView setZoomEnabled:YES];
                             [self.mapView setScrollEnabled:YES];
                             self.mapViewIsOpen = YES;
                             
                         }];
                         
                     }];
}

- (void)closeMapView
{
    [self closeMapViewWithCompletion:nil];
}

- (void)closeMapViewWithCompletion:(void (^)(void))completion
{
    [self.mapView setZoomEnabled:NO];
    [self.mapView setScrollEnabled:NO];
    
    [self.navigationItem setRightBarButtonItems:nil animated:YES];
    [self.navigationItem setLeftBarButtonItem:nil animated:NO];
    
    for (NSObject<MKAnnotation> *annotation in [self.mapView selectedAnnotations])
        [self.mapView deselectAnnotation:(id <MKAnnotation>)annotation animated:NO];
    
    [UIView animateWithDuration:0.5f
                     animations:^{
                         
                         self.userLocationButton.alpha = 0;
                         self.searchHereButton.alpha = 0;
                         
                         self.mapView.frame = self.mapViewFrame;
                         self.resultsTableView.frame = self.resultsTableViewFrame;
                         
                     } completion:^(BOOL finished){
                         
                         [self zoomMapViewToFitAnnotationsWithUserLocation:NO];
                         
                         [self.userLocationButton removeFromSuperview];
                         self.userLocationButton = nil;
                         
                         if([self.searchHereButton isDescendantOfView:self.mapView]){
                             [self.searchHereButton removeFromSuperview];
                             self.searchHereButton = nil;
                         }
                         
                         self.mapViewIsOpen = NO;
                         
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
                         
                         if (completion) {
                             completion();
                         }
                         
                     }];
}

- (void)searchOnMapViewRegion
{
    [MRProgressOverlayView showOverlayAddedTo:self.navigationController.view animated:YES];
    
    [[CRClient sharedClient] getNearbyStoresFromLatitude:self.mapView.centerCoordinate.latitude longitude:self.mapView.centerCoordinate.longitude completion:^(NSArray *stores, NSError *error) {
        
        if (!error) {
            if (stores) {
                
                self.stores = nil;
                self.stores = [[NSMutableArray alloc] initWithArray:stores];
                
                if(![self.stores count]) {
                    
                    [MRProgressOverlayView dismissOverlayForView:self.navigationController.view animated:YES];
                    
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:NSLocalizedString(@"Empty results", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alertView show];
                } else {
                    [self.resultsTableView reloadData];
                    [self refreshMapView];
                    self.location = [[CLLocation alloc] initWithLatitude:self.mapView.centerCoordinate.latitude longitude:self.mapView.centerCoordinate.longitude];
                    
                    [MRProgressOverlayView dismissOverlayForView:self.navigationController.view animated:YES];
                }
                
            }
        }
        
    }];
}

- (void)centerMapUserLocation
{
    [self.mapView setCenterCoordinate:self.userLocation.coordinate animated:YES];
}

- (void)zoomMapViewToFitAnnotationsWithUserLocation:(BOOL)fitToUserLocation
{
    if([self.mapView.annotations count] > 1) {
        MKMapRect zoomRect = MKMapRectNull;
        for (id <MKAnnotation> annotation in self.mapView.annotations) {
            if(fitToUserLocation) {
                MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
                MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.2, 0.2);
                if (MKMapRectIsNull(zoomRect)) {
                    zoomRect = pointRect;
                } else {
                    zoomRect = MKMapRectUnion(zoomRect, pointRect);
                }
            } else {
                if (![annotation isKindOfClass:[MKUserLocation class]] ) {
                    MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
                    MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.2, 0.2);
                    if (MKMapRectIsNull(zoomRect)) {
                        zoomRect = pointRect;
                    } else {
                        zoomRect = MKMapRectUnion(zoomRect, pointRect);
                    }
                }
            }
        }
        [self.mapView setVisibleMapRect:zoomRect animated:YES];
    }
}

- (void)refreshMapView
{
    id userAnnotation = self.mapView.userLocation;
    
    NSMutableArray *annotations = [NSMutableArray arrayWithArray:self.mapView.annotations];
    [annotations removeObject:userAnnotation];
    
    [self.mapView removeAnnotations:annotations];
    
    for (Store *store in self.stores) {
        
        StoreAnnotation *annotation = [[StoreAnnotation alloc] init];
        [annotation setTitle:store.name];
        [annotation setSubtitle:store.address1];
        [annotation setIndex:[self.stores indexOfObject:store]];
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([store.lat doubleValue], [store.lng doubleValue]);
        [annotation setCoordinate:coordinate];
        [self.mapView addAnnotation:annotation];
        
    }
    
    if (self.mapViewIsOpen) {
        [self zoomMapViewToFitAnnotationsWithUserLocation:self.includeUserLocation];
    }
}

- (NSString *)convertDistanceToString:(double)distance
{
    BOOL isMetric = [[[NSLocale currentLocale] objectForKey:NSLocaleUsesMetricSystem] boolValue];
    
    NSString *format;
    
    if (isMetric) {
        if (distance < METERS_CUTOFF) {
            format = @"%@ m";
        } else {
            format = @"%@ km";
            distance = distance / 1000;
        }
    } else {
        distance = distance * METERS_TO_FEET;
        if (distance < FEET_CUTOFF) {
            format = @"%@ ft";
        } else {
            format = @"%@ mi";
            distance = distance / FEET_IN_MILES;
        }
    }
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setLocale:[NSLocale currentLocale]];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [numberFormatter setMaximumFractionDigits:1];
    return [NSString stringWithFormat:format, [numberFormatter stringFromNumber:[NSNumber numberWithDouble:distance]]];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.stores count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    static NSString *cellIdentifier = @"cellIdentifier";
    StoreCell *cell = (StoreCell *) [self.resultsTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"StoreCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    Store *store = [self.stores objectAtIndex:indexPath.row];
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:[store.lat doubleValue] longitude:[store.lng doubleValue]];
    double distance = [location distanceFromLocation:self.userLocation];
    [store setDistance:@(distance)];
    
    int open = [store.openNow intValue];
    
    [cell.name setText:store.name];
    [cell.address setText:store.address1];
    [cell.status.layer setCornerRadius:3.0f];
    [cell.status setBackgroundColor: open ? self.navigationController.view.window.tintColor : [UIColor lightGrayColor]];
    [cell.status setText: open ? NSLocalizedString(@"Open", nil) : NSLocalizedString(@"Closed", nil)];
    [cell.distance setText:[self convertDistanceToString:[store.distance doubleValue]]];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Store *store = [self.stores objectAtIndex:indexPath.row];
    DetailViewController *detailViewController = [[DetailViewController alloc] init];
    [detailViewController setStore:store];
    [self.navigationController pushViewController:detailViewController animated:YES];
    [self.resultsTableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
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
    
    annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    annotationView.leftCalloutAccessoryView = leftIconView;
    
    return annotationView;
}

- (void)mapView:(MKMapView *)mv annotationView:(MKAnnotationView *)pin calloutAccessoryControlTapped:(UIControl *)control
{
    __weak typeof(self) weakSelf = self;
    [self closeMapViewWithCompletion:^{
        
        typeof(self) strongSelf = weakSelf;
        StoreAnnotation *annotation = (StoreAnnotation *)pin.annotation;
        Store *store = [self.stores objectAtIndex:annotation.index];
        DetailViewController *detailViewController = [[DetailViewController alloc] init];
        [detailViewController setStore:store];
        [strongSelf.navigationController pushViewController:detailViewController animated:YES];
        
    }];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    self.userLocation = [locations lastObject];
    [self.resultsTableView reloadData];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
}

@end

//
//  SecondViewController.m
//  FreeFood
//
//  Created by Hao Ge on 4/23/14.
//  Copyright (c) 2014 Hao Ge. All rights reserved.
//

#import "SecondViewController.h"
#import "GeoQueryAnnotation.h"
#import "GeoPointAnnotation.h"
#import "FoodDetailViewController.h"


enum PinAnnotationTypeTag {
    PinAnnotationTypeTagGeoPoint = 0,
    PinAnnotationTypeTagGeoQuery = 1
};

@interface SecondViewController ()

@end

@implementation SecondViewController {
    BOOL initRegion;
}

- (void)viewDidLoad
{
    
    [self.mapView setDelegate:self];
    [self.mapView setShowsUserLocation:YES];
    [super viewDidLoad];
    MKUserTrackingBarButtonItem *trackButton = [[MKUserTrackingBarButtonItem alloc] initWithMapView:self.mapView];
    self.navigationItem.rightBarButtonItem = trackButton;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    NSLog(@"position updated");
    CLLocationCoordinate2D loc = [userLocation coordinate];
    if (!initRegion) {
//        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(loc, 100, 100);
//        [self.mapView setRegion:region animated:YES];
        initRegion = YES;
        [self setInitialLocation:[userLocation location]];
        self.mapView.region = MKCoordinateRegionMake(self.location.coordinate, MKCoordinateSpanMake(0.02f, 0.02));
        [self configureOverlay];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    static NSString *GeoPointAnnotationIdentifier = @"RedPinAnnotation";
    static NSString *GeoQueryAnnotationIdentifier = @"PurplePinAnnotation";
    
    if ([annotation isKindOfClass:[GeoQueryAnnotation class]]) {
        MKPinAnnotationView *annotationView =
        (MKPinAnnotationView *)[mapView
                                dequeueReusableAnnotationViewWithIdentifier:GeoQueryAnnotationIdentifier];
        
        if (!annotationView) {
            annotationView = [[MKPinAnnotationView alloc]
                              initWithAnnotation:annotation
                              reuseIdentifier:GeoQueryAnnotationIdentifier];
            annotationView.tag = PinAnnotationTypeTagGeoQuery;
            annotationView.canShowCallout = YES;
            annotationView.pinColor = MKPinAnnotationColorPurple;
            annotationView.animatesDrop = NO;
            annotationView.draggable = YES;
        }
        
        return annotationView;
    } else if ([annotation isKindOfClass:[GeoPointAnnotation class]]) {
        MKPinAnnotationView *annotationView =
        (MKPinAnnotationView *)[mapView
                                dequeueReusableAnnotationViewWithIdentifier:GeoPointAnnotationIdentifier];
        
        if (!annotationView) {
            annotationView = [[MKPinAnnotationView alloc]
                              initWithAnnotation:annotation
                              reuseIdentifier:GeoPointAnnotationIdentifier];
            annotationView.tag = PinAnnotationTypeTagGeoPoint;
            annotationView.canShowCallout = YES;
            annotationView.pinColor = MKPinAnnotationColorRed;
            annotationView.animatesDrop = YES;
            annotationView.draggable = NO;
            annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];

        }
        
        return annotationView;
    }
    
    return nil;
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay {
    static NSString *CircleOverlayIdentifier = @"Circle";
    
    if ([overlay isKindOfClass:[CircleOverlay class]]) {
        CircleOverlay *circleOverlay = (CircleOverlay *)overlay;
        
        MKCircleView *annotationView =
        (MKCircleView *)[mapView dequeueReusableAnnotationViewWithIdentifier:CircleOverlayIdentifier];
        
        if (!annotationView) {
            MKCircle *circle = [MKCircle
                                circleWithCenterCoordinate:circleOverlay.coordinate
                                radius:circleOverlay.radius];
            annotationView = [[MKCircleView alloc] initWithCircle:circle];
        }
        
        if (overlay == self.targetOverlay) {
            annotationView.fillColor = [UIColor colorWithRed:1.0f green:0.0f blue:0.0f alpha:0.3f];
            annotationView.strokeColor = [UIColor redColor];
            annotationView.lineWidth = 1.0f;
        } else {
            annotationView.fillColor = [UIColor colorWithWhite:0.3f alpha:0.3f];
            annotationView.strokeColor = [UIColor purpleColor];
            annotationView.lineWidth = 2.0f;
        }
        
        return annotationView;
    }
    
    return nil;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view
calloutAccessoryControlTapped:(UIControl *)control
{
    [self performSegueWithIdentifier:@"detail" sender:view];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    FoodDetailViewController *destViewController = segue.destinationViewController;
    
    MKAnnotationView *annotationView = sender;
    GeoPointAnnotation *geoPointAnnotation = [annotationView annotation];
    PFObject *object = geoPointAnnotation.object;
    EventBean *event = [[EventBean alloc] init];
    
    event.description = [object objectForKey:@"description"];
    event.image = [object objectForKey:@"image"];
    event.building =[object objectForKey:@"building"];
    event.place = [object objectForKey:@"place"];
    
    event.startTime = [object objectForKey:@"startTime"];
    event.endTime = [object objectForKey:@"endTime"];
    
    event.coordinate = [object objectForKey:@"coordinate"];
    
    destViewController.hidesBottomBarWhenPushed = YES;
    destViewController.event = event;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {
    if (![view isKindOfClass:[MKPinAnnotationView class]] || view.tag != PinAnnotationTypeTagGeoQuery) {
        return;
    }
    
    if (MKAnnotationViewDragStateStarting == newState) {
        [self.mapView removeOverlays:self.mapView.overlays];
    } else if (MKAnnotationViewDragStateNone == newState && MKAnnotationViewDragStateEnding == oldState) {
        MKPinAnnotationView *pinAnnotationView = (MKPinAnnotationView *)view;
        GeoQueryAnnotation *geoQueryAnnotation = (GeoQueryAnnotation *)pinAnnotationView.annotation;
        self.location = [[CLLocation alloc] initWithLatitude:geoQueryAnnotation.coordinate.latitude longitude:geoQueryAnnotation.coordinate.longitude];
        [self configureOverlay];
    }
}

- (void)setInitialLocation:(CLLocation *)aLocation {
    self.location = aLocation;
    self.radius = 500;
}


- (IBAction)sliderDidTouchUp:(UISlider *)aSlider {
    if (self.targetOverlay) {
        [self.mapView removeOverlay:self.targetOverlay];
    }
    
    [self configureOverlay];
}


- (IBAction)sliderValueChanged:(UISlider *)aSlider {
    self.radius = aSlider.value;
    
    if (self.targetOverlay) {
        [self.mapView removeOverlay:self.targetOverlay];
    }
    
    self.targetOverlay = [[CircleOverlay alloc] initWithCoordinate:self.location.coordinate radius:self.radius];
    [self.mapView addOverlay:self.targetOverlay];
}


- (void)configureOverlay {
    if (self.location) {
        [self.mapView removeAnnotations:self.mapView.annotations];
        [self.mapView removeOverlays:self.mapView.overlays];
        
        CircleOverlay *overlay = [[CircleOverlay alloc] initWithCoordinate:self.location.coordinate radius:self.radius];
        [self.mapView addOverlay:overlay];
        
        GeoQueryAnnotation *annotation = [[GeoQueryAnnotation alloc] initWithCoordinate:self.location.coordinate radius:self.radius];
        [self.mapView addAnnotation:annotation];
        
        [self updateLocations];
    }
}


- (void)updateLocations {
    CGFloat kilometers = self.radius/1000.0f;
    NSLog(@"update Locations");
    
    PFQuery *query = [PFQuery queryWithClassName:@"event"];
    [query setLimit:1000];
    [query whereKey:@"coordinate"
       nearGeoPoint:[PFGeoPoint geoPointWithLatitude:self.location.coordinate.latitude longitude:self.location.coordinate.longitude] withinKilometers:kilometers];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for (PFObject *object in objects) {
                GeoPointAnnotation *geoPointAnnotation = [[GeoPointAnnotation alloc] initWithObject:object];
                [self.mapView addAnnotation:geoPointAnnotation];
            }
        }
    }];
}

@end

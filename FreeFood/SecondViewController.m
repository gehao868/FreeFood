//
//  SecondViewController.m
//  FreeFood
//
//  Created by Hao Ge on 4/23/14.
//  Copyright (c) 2014 Hao Ge. All rights reserved.
//

#import "SecondViewController.h"

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
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(loc, 250, 250);
        [self.mapView setRegion:region animated:YES];
        initRegion = YES;
    }
}

@end

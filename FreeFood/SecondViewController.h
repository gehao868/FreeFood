//
//  SecondViewController.h
//  FreeFood
//
//  Created by Hao Ge on 4/23/14.
//  Copyright (c) 2014 Hao Ge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <Parse/Parse.h>

@interface SecondViewController : UIViewController <MKMapViewDelegate, UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet MKMapView *mapView;

@end

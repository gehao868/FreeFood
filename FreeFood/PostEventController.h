//
//  PostEventController.h
//  Test3
//
//  Created by Yiye Zeng on 4/25/14.
//  Copyright (c) 2014 Yiye Zeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <Parse/Parse.h>

@interface PostEventController : UITableViewController <UIPickerViewDataSource,UIPickerViewDelegate,CLLocationManagerDelegate>

- (IBAction)addPhoto:(id)sender;
- (IBAction)positionSwitchChange:(id)sender;
- (IBAction)cancelPressed:(id)sender;
- (IBAction)sendPressed:(id)sender;

@property (strong, nonatomic) IBOutlet UISwitch *positionSwitch;
@property NSDate *startDateTime;
@property NSDate *endDateTime;
@property (nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UITextField *room;
@property (strong, nonatomic) IBOutlet UITextField *description;
@property (strong, nonatomic) IBOutlet UILabel *startDateLabel;
@property (strong, nonatomic) IBOutlet UILabel *endDateLabel;
@property (strong, nonatomic) IBOutlet UIDatePicker *startDatePicker;
@property (strong, nonatomic) IBOutlet UIDatePicker *endDatePicker;
@property (strong, nonatomic) IBOutlet UIPickerView *locationPicker;
@property (strong, nonatomic) IBOutlet UILabel *locationLabel;
@property (nonatomic) NSArray *locationArray;
@property (strong, nonatomic) IBOutlet UILabel *startLabel;
@property (strong, nonatomic) IBOutlet UILabel *endLabel;
@property (nonatomic) float longitude;
@property (nonatomic) float latitude;

@end

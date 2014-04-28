//
//  PostEventController.m
//  Test3
//
//  Created by Yiye Zeng on 4/25/14.
//  Copyright (c) 2014 Yiye Zeng. All rights reserved.
//

#import "PostEventController.h"
#import "EventBean.h"
#include <stdlib.h>

@interface PostEventController ()

@end

@implementation PostEventController {
    UIImage *originalImage;
    BOOL editingStartTime;
    BOOL editingEndTime;
    BOOL editingLocation;
    BOOL locationSelected;
    BOOL haveRealLocation;
    NSDateFormatter *df;
    NSTimeZone *zone;
    CLLocationManager *locationManager;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{

    [super viewDidLoad];
    [_room setDelegate:self];
    [_description setDelegate:self];
    
    
    self.locationArray = [[NSArray alloc] initWithObjects:@"Select Location",@"GHC",@"NSH",@"DH",@"HBH",@"UC",@"Hunt",@"417 S. Craig",@"EDSH",@"Cut",@"WH",@"PH",@"BH",@"SH",@"CFA",@"Tepper",nil];
    self.latArray = [[NSArray alloc] initWithObjects:@0,@40.443637f,@40.443531f,@40.442347f,@40.444265f,@40.443661f,@40.441017f,@40.444584f,@40.443947f,@40.442559,@40.442722f,@40.44181f,@40.441444f,@40.441787f,@40.441395f,@40.441433f,nil];
    self.lonArray = [[NSArray alloc] initWithObjects:@0,@-79.944466f,@-79.9457f,@-79.944209f,@-79.945371f,@-79.942351f,@-79.943731f,@-79.948489f,@-79.945554f,@-79.943296f,@-79.945817f,@-79.946273f,@-79.944869f,@-79.947331f,@-79.942935f,@-79.942139f,nil];
    
    NSDate *date = [NSDate date];
    df = [[NSDateFormatter alloc] init];
    zone = [NSTimeZone localTimeZone];
    [df setTimeZone:zone];
    [df setDateFormat:@"yyyy/MM/dd HH:mm"];
    [self.startDateLabel setText:[df stringFromDate:date]];
    [_endDateLabel setText:[df stringFromDate:[NSDate dateWithTimeInterval:3600 sinceDate:date]]];
    self.startDateTime = date;
    self.endDateTime = [NSDate dateWithTimeInterval:3600 sinceDate:date];
    
    [self.startDatePicker addTarget:self action:@selector(startDateChanged:) forControlEvents:UIControlEventValueChanged];
    [self.endDatePicker addTarget:self action:@selector(endDateChanged:) forControlEvents:UIControlEventValueChanged];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


- (void) startDateChanged:(id)sender{
    NSLog(@"%@", [df stringFromDate:[self.startDatePicker date]]);
    self.startDateTime = [self.startDatePicker date];
    [self.startDateLabel setText:[df stringFromDate:[self.startDatePicker date]]];
}

- (void) endDateChanged:(id)sender{
    NSLog(@"%@", [df stringFromDate:[self.endDatePicker date]]);
    self.endDateTime = [self.endDatePicker date];
    [self.endDateLabel setText:[df stringFromDate:[self.endDatePicker date]]];
}

- (IBAction)takePhoto:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = NO;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        [self presentViewController:picker animated:YES completion:NULL];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Sorry"
                                  message:@"Your device does not have a camera."
                                  delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
}

- (IBAction)pickPhoto:(UIButton *)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.allowsEditing = NO;
    picker.delegate = self;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

- (IBAction)addPhoto:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo", @"Select From Gallery", nil];
    
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault; [actionSheet showInView:self.view.window];
}

- (IBAction)positionSwitchChange:(id)sender {
    if (self.positionSwitch.on) {
        [self getCurrentLocation:nil];
    } else {
        self.latitude = 0;
        self.longitude = 0;
    }
}

- (IBAction)cancelPressed:(id)sender {
    NSLog(@"cancel pressed");
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (IBAction)sendPressed:(id)sender {
    NSLog(@"send pressed");
    if ([self validateInput]) {
        NSLog(@"input validate success");
        [self postEvent];
    }
}

- (void) postEvent {
    originalImage = [self.imageView image];
    
    PFObject *event = [PFObject objectWithClassName:@"event"];
    [event setObject:_description.text forKey:@"description"];
    [event setObject:_locationLabel.text forKey:@"building"];
    [event setObject:_room.text forKey:@"place"];
    [event setObject:_startDateTime forKey:@"startTime"];
    [event setObject:_endDateTime forKey:@"endTime"];
    PFGeoPoint *geoPoint;
    if (self.positionSwitch.on) {
        geoPoint = [PFGeoPoint geoPointWithLatitude:_latitude longitude:_longitude];
    } else {
        geoPoint = [PFGeoPoint geoPointWithLatitude:_rawLatitude longitude:_rawLongitude];
    }
    [event setObject:geoPoint forKey:@"coordinate"];
    
    // Recipe image
    NSData *imageData = UIImageJPEGRepresentation(originalImage, 0.8);
    NSString *filename = [NSString stringWithFormat:@"%f.png", [[NSDate date] timeIntervalSince1970]];
    PFFile *imageFile = [PFFile fileWithName:filename data:imageData];
    [event setObject:imageFile forKey:@"image"];
    
    // Show progress
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicator.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
    indicator.center = self.view.center;
    [self.view addSubview:indicator];
    [indicator bringSubviewToFront:self.view];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;
    [indicator startAnimating];
    
    // Upload recipe to Parse
    [event saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//        [hud hide:YES];
        [indicator stopAnimating];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
        if (succeeded) {
            NSLog(@"post succeeded");
        } else {
            NSLog(@"%@",[error localizedDescription]);
        }
        if (!error) {
            // Show success message
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Upload Complete" message:@"Successfully posted the event" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            
            // Notify table view to reload the recipes from Parse cloud
            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshTable" object:self];
            
            // Dismiss the controller
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Upload Failure" message:@"Post failed. Please check your network connection and try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
        
    }];
    
    //send local notification
    
    // Schedule the notification
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = _startDateTime;
    localNotification.alertBody = [NSString stringWithFormat:@"%@ at %@ %@", _description.text, _locationLabel.text, _room.text];
    localNotification.alertAction = @"Show me the free food event";
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    
    // Request to reload table view data
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadData" object:self];
    
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if([[alertView title] isEqualToString:@"Upload Complete"]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (BOOL) validateInput {
    if ([[self.description text] isEqual: @""]) {
        UIAlertView *errorAlert = [[UIAlertView alloc]
                                   initWithTitle:@"Error" message:@"Description cannot be empty." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [errorAlert show];
        return NO;
    }
    if ([[self.room text] isEqual: @""]) {
        UIAlertView *errorAlert = [[UIAlertView alloc]
                                   initWithTitle:@"Error" message:@"Room number cannot be empty." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [errorAlert show];
        return NO;
    }
    if ([self.startDateTime compare:self.endDateTime] == NSOrderedDescending) {
        NSLog(@"%@",[df stringFromDate:self.startDateTime]);
        NSLog(@"%@",[df stringFromDate:self.endDateTime]);
        UIAlertView *errorAlert = [[UIAlertView alloc]
                                   initWithTitle:@"Error" message:@"End time must be later than start time." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [errorAlert show];
        return NO;
    }
    if ([self.endDateTime compare:[NSDate date]] == NSOrderedAscending) {
        NSLog(@"%@",[df stringFromDate:self.startDateTime]);
        NSLog(@"%@",[df stringFromDate:self.endDateTime]);
        UIAlertView *errorAlert = [[UIAlertView alloc]
                                   initWithTitle:@"Error" message:@"End time must be no later than current time." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [errorAlert show];
        return NO;
    }
    if (locationSelected == NO) {
        UIAlertView *errorAlert = [[UIAlertView alloc]
                                   initWithTitle:@"Error" message:@"Please select location of the event." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [errorAlert show];
        return NO;
    }
    if ([[self.description text] length] > 140) {
        UIAlertView *errorAlert = [[UIAlertView alloc]
                                   initWithTitle:@"Error" message:@"Description cannot be longer than 140 characters." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [errorAlert show];
        return NO;
    }
    if ([[self.room text] length] > 20) {
        UIAlertView *errorAlert = [[UIAlertView alloc]
                                   initWithTitle:@"Error" message:@"Room number cannot be longer than 20 characters." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [errorAlert show];
        return NO;
    }
    return YES;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            [self takePhoto:nil];
            break;
        case 1:
            [self pickPhoto:nil];
            break;
    }
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *) picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    originalImage = (UIImage *) [info objectForKey:UIImagePickerControllerOriginalImage];
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    // resize photo
    float width = 480.0f;
    float height = width / [originalImage size].width * [originalImage size].height;
    CGSize newSize = CGSizeMake(width, height);
    UIGraphicsBeginImageContext(newSize);
    [originalImage drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    originalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    // display photo
    [self.imageView setImage:originalImage];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // location picker
    if (indexPath.section == 3 && indexPath.row == 0) {
        if (editingLocation == NO) {
            editingStartTime = NO;
            editingEndTime = NO;
            editingLocation = YES;
            [self.locationPicker setHidden:NO];
            self.endDateLabel.textColor = [UIColor blackColor];
            self.endLabel.textColor = [UIColor blackColor];
            self.startLabel.textColor = [UIColor blackColor];
            self.startDateLabel.textColor = [UIColor blackColor];
        } else {
            editingLocation = NO;
        }
        [UIView animateWithDuration:.4 animations:^{
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:3 inSection:2]] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:2]] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:3]] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView reloadData];
        }];
        if (editingLocation == YES) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:3];
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
//        else {
//            [self.locationPicker setHidden:YES];
//        }
    }
    // end time picker
    if (indexPath.section == 2 && indexPath.row == 2) { // this is my date cell above the picker cell
        if (editingEndTime == NO) {
            editingEndTime = YES;
            editingStartTime = NO;
            editingLocation = NO;
            [self.endDatePicker setHidden:NO];
            self.endDateLabel.textColor = [UIColor redColor];
            self.endLabel.textColor = [UIColor redColor];
            self.startLabel.textColor = [UIColor blackColor];
            self.startDateLabel.textColor = [UIColor blackColor];
            // scroll to focus
        } else {
            editingEndTime = NO;
            self.endDateLabel.textColor = [UIColor blackColor];
            self.endLabel.textColor = [UIColor blackColor];
        }
        [UIView animateWithDuration:.4 animations:^{
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:3 inSection:2]] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:2]] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:3]] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView reloadData];
        }];
        if (editingEndTime == YES) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:2];
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
    }
    // start time picker
    if (indexPath.section == 2 && indexPath.row == 0) { // this is my date cell above the picker cell
        if (editingStartTime == NO) {
            editingStartTime = YES;
            editingEndTime = NO;
            editingLocation = NO;
            [self.startDatePicker setHidden:NO];
            self.startDateLabel.textColor = [UIColor redColor];
            self.startLabel.textColor = [UIColor redColor];
            self.endDateLabel.textColor = [UIColor blackColor];
            self.endLabel.textColor = [UIColor blackColor];
            // scroll to focus
        } else {
            editingStartTime = NO;
            self.startDateLabel.textColor = [UIColor blackColor];
            self.startLabel.textColor = [UIColor blackColor];
        }
        [UIView animateWithDuration:.4 animations:^{
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:3 inSection:2]] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:2]] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:3]] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView reloadData];
        }];
        if (editingStartTime == YES) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:2];
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
    }
    if (indexPath.section == 1 && indexPath.row == 0) {
        [self.description becomeFirstResponder];
    }
    if (indexPath.section == 0 && indexPath.row == 1) {
        [self addPhoto:nil];
    }
    if (indexPath.section == 3 && indexPath.row == 2) {
        [self.room becomeFirstResponder];
    }
    if (indexPath.section == 0 && indexPath.row == 0) {
        [self addPhoto:nil];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2 && indexPath.row == 1) { // this is my picker cell
        if (editingStartTime) {
            return 219;
        } else {
            return 0;
        }
    } else if (indexPath.section == 2 && indexPath.row == 3) {
        if (editingEndTime) {
            return 219;
        } else {
            return 0;
        }
    } else if (indexPath.section == 0 && indexPath.row == 0) {
        return 231;
    } else if (indexPath.section == 3 && indexPath.row == 1) {
        if (editingLocation) {
            return 180;
        } else {
            return 0;
        }
    } else {
        return self.tableView.rowHeight;
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [_room resignFirstResponder];
    [_description resignFirstResponder];
    return YES;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent: (NSInteger)component
{
    return [self.locationArray count];
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [self.locationArray objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [self.locationLabel setText:[self.locationArray objectAtIndex:row]];
    if (row == 0) {
        locationSelected = NO;
        self.locationLabel.textColor = [UIColor lightGrayColor];
    } else {
        locationSelected = YES;
        self.locationLabel.textColor = [UIColor blackColor];
    }
    int r = arc4random() % 50;
    self.rawLatitude = [[self.latArray objectAtIndex:row] floatValue] + r * 0.000001;
    r = arc4random() % 74;
    self.rawLongitude = [[self.lonArray objectAtIndex:row] floatValue] + r * 0.000001;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    editingLocation = NO;
    editingEndTime = NO;
    editingStartTime = NO;
    self.endDateLabel.textColor = [UIColor blackColor];
    self.endLabel.textColor = [UIColor blackColor];
    self.startLabel.textColor = [UIColor blackColor];
    self.startDateLabel.textColor = [UIColor blackColor];
    [UIView animateWithDuration:.4 animations:^{
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:3 inSection:2]] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:2]] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:3]] withRowAnimation:UITableViewRowAnimationFade];
//        [self.tableView reloadData];
    }];
}

- (IBAction)getCurrentLocation:(id)sender {
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != nil) {
        self.longitude = currentLocation.coordinate.longitude;
        self.latitude = currentLocation.coordinate.latitude;
        haveRealLocation = YES;
    }
    [locationManager stopUpdatingLocation];
}

@end

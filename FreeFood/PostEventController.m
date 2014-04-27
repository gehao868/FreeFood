//
//  PostEventController.m
//  Test3
//
//  Created by Yiye Zeng on 4/25/14.
//  Copyright (c) 2014 Yiye Zeng. All rights reserved.
//

#import "PostEventController.h"

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
    originalImage = [self.imageView image];
    [_room setDelegate:self];
    [_description setDelegate:self];
    
    locationManager = [[CLLocationManager alloc] init];
    
    self.locationArray = [[NSArray alloc] initWithObjects:@"Select Location",@"GHC",@"NSH",@"DH",@"HBH",@"UC",@"Hunt", nil];
    
    NSDate *date = [NSDate date];
    df = [[NSDateFormatter alloc] init];
    zone = [NSTimeZone localTimeZone];
    [df setTimeZone:zone];
    [df setDateFormat:@"yyyy/MM/dd HH:mm"];
    [self.startDateLabel setText:[df stringFromDate:date]];
    [_endDateLabel setText:[df stringFromDate:[NSDate dateWithTimeInterval:3600 sinceDate:date]]];
    self.startDateTime = date;
    self.endDateTime = [NSDate dateWithTimeInterval:3600 sinceDate:date];
    self.longitude = 0;
    self.latitude = 0;
    
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
        if ([self postEvent]) {
            UIAlertView *errorAlert = [[UIAlertView alloc]
                                       initWithTitle:@"Success" message:@"Event Posted" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [errorAlert show];
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            UIAlertView *errorAlert = [[UIAlertView alloc]
                                       initWithTitle:@"Error" message:@"Post failed. Please check your network connection and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [errorAlert show];
        }
    }
}

- (BOOL) postEvent {
    return NO;
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

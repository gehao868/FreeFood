//
//  FoodDetailViewController.m
//  FreeFood
//
//  Created by Hao Ge on 4/25/14.
//  Copyright (c) 2014 Hao Ge. All rights reserved.
//

#import "FoodDetailViewController.h"
#import <Social/Social.h>
#import <EventKit/EventKit.h>

@interface FoodDetailViewController () <MFMessageComposeViewControllerDelegate>

@end

@implementation FoodDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _isFullScreen = false;
    
    self.bigImage.file = self.event.image;
    [self.bigImage loadInBackground];
    
    self.eventName.text = self.event.description;
    
    self.eventPlace.text = [NSString stringWithFormat:@"%@ %@",self.event.building, self.event.place];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy/MM/dd HH:mm"];
    self.startTime.text = [formatter stringFromDate:self.event.startTime];
    self.endTime.text = [formatter stringFromDate:self.event.endTime];
    
}

- (IBAction)tapDetected:(id)sender {
    if (!_isFullScreen) {
        [UIView animateWithDuration:0.5 delay:0 options:0 animations:^{
            //save previous frame
            _prevFrame = _bigImage.frame;
            [_bigImage setFrame:[[UIScreen mainScreen] bounds]];
            _bigImage.backgroundColor = [UIColor blackColor];
        }completion:^(BOOL finished){
            _isFullScreen = YES;
        }];
        return;
    }
    else{
        [UIView animateWithDuration:0.5 delay:0 options:0 animations:^{
            [_bigImage setFrame:_prevFrame];
        }completion:^(BOOL finished){
            _isFullScreen = NO;;
        }];
        return;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)shareButton:(id)sender {
    self.standardIBAS = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Facebook", @"Twitter", @"Email", @"Text Message", nil];
    
    [self.standardIBAS showInView:self.view.window];
}

- (IBAction)saveToCal:(id)sender {
    EKEventStore *eventStore = [[EKEventStore alloc] init];
    if ([eventStore respondsToSelector:@selector(requestAccessToEntityType:completion:)]){
        [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error)
                {
                    // display error message here
                }
                else if (!granted)
                {
                    // display access denied error message here
                }
                else
                {
                    // access granted
                    EKEvent *event  = [EKEvent eventWithEventStore:eventStore];
                    event.title     = self.event.description;
                    event.location =[NSString stringWithFormat:@"%@ %@", self.event.building, self.event.place];
                    
                    NSDateFormatter *tempFormatter = [[NSDateFormatter alloc]init];
                    [tempFormatter setDateFormat:@"dd.MM.yyyy HH:mm"];
                    
                    event.startDate = self.event.startTime;
                    event.endDate   = self.event.endTime;
                    event.allDay = NO;
                    
                    [event addAlarm:[EKAlarm alarmWithRelativeOffset:60.0f * -60.0f * 24]];
                    [event addAlarm:[EKAlarm alarmWithRelativeOffset:60.0f * -15.0f]];
                    
                    [event setCalendar:[eventStore defaultCalendarForNewEvents]];
                    NSError *err;
                    [eventStore saveEvent:event span:EKSpanThisEvent error:&err];
                    
                
                    UIAlertView *alert = [[UIAlertView alloc]
                                          initWithTitle:@"Event Created"
                                          message:@"Successfully mark to calendar"
                                          delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
                    [alert show];
                }
            });
        }];
    }
    
}

- (IBAction)getDirection:(id)sender {
    
    CLLocationCoordinate2D endCoor = (CLLocationCoordinate2D){self.event.coordinate.latitude, self.event.coordinate.longitude};
    
    MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];
    MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark: [[MKPlacemark alloc] initWithCoordinate:endCoor addressDictionary:nil]];
    toLocation.name = [NSString stringWithFormat:@"%@ %@", self.event.building, self.event.place];
    [MKMapItem openMapsWithItems:@[currentLocation, toLocation]
                   launchOptions:@{MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving,MKLaunchOptionsShowsTrafficKey: [NSNumber numberWithBool:YES]}];
}

- (IBAction)follow:(id)sender {
    
    [self.followButton setImage:[UIImage imageNamed:@"starfull"]];
    
    
    // Schedule the notification
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    
    localNotification.fireDate = self.event.startTime;
    
    localNotification.alertBody = [NSString stringWithFormat:@"%@ at %@ %@", self.event.description, self.event.building, self.event.place];
    localNotification.alertAction = @"Show me the free food event";
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    
    // Request to reload table view data
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadData" object:self];
    
    
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSDateFormatter *tempFormatter = [[NSDateFormatter alloc]init];
    [tempFormatter setDateFormat:@"MM/dd/yyyy HH:mm"];
    NSString *txt = [NSString stringWithFormat:@"Free food event: %@ in %@ %@. Start at %@. Share from FreeFood app", self.event.description, self.event.building, self.event.place, [tempFormatter stringFromDate:self.event.startTime]];

    if (buttonIndex == 0) {
        
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [controller setInitialText:txt];
        [self.event.image getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                UIImage *image = [UIImage imageWithData:data];
                // image can now be set on a UIImageView
                [controller addImage:image];
            }
        }];
        
        [self presentViewController:controller animated:YES completion:Nil];
        
    } else if (buttonIndex == 1) {
        SLComposeViewController *tweetSheet = [SLComposeViewController
                                               composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetSheet setInitialText:txt];
        
        [self.event.image getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                UIImage *image = [UIImage imageWithData:data];
                // image can now be set on a UIImageView
                [tweetSheet addImage:image];
            }
        }];
        [self presentViewController:tweetSheet animated:YES completion:nil];
    } else if (buttonIndex == 2) {
        if (![MFMailComposeViewController canSendMail]){
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device doesn't support Email!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            return;
        }
        
        NSString *title = @"Free food event";
        NSString *messageBody = txt;
        MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
        mc.mailComposeDelegate = self;
        [mc setSubject:title];
        [mc setMessageBody:messageBody isHTML:YES];
        [self.event.image getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                UIImage *image = [UIImage imageWithData:data];
                NSData *data = UIImageJPEGRepresentation(image, 1.0);
                [mc addAttachmentData:data mimeType:@"image/jpeg" fileName:@"FreeFood Event"];
            }
        }];
        
        [self presentViewController:mc animated:YES completion:NULL];
        
        
    } else if (buttonIndex == 3) {
        if(![MFMessageComposeViewController canSendText]) {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device doesn't support SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            return;
        }
        
        MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
        messageController.messageComposeDelegate = self;
        [messageController setBody:txt];
        
        // Present message view controller on screen
        [self presentViewController:messageController animated:YES completion:nil];
    }
    
    //NSLog(@"Button at index: %d clicked\nIt's title is '%@'", buttonIndex, [actionSheet buttonTitleAtIndex:buttonIndex]);
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    switch (result) {
        case MessageComposeResultCancelled:
            break;
            
        case MessageComposeResultFailed:
        {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to send SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            break;
        }
            
        case MessageComposeResultSent:
            break;
            
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error;
{
    if (result == MFMailComposeResultSent) {
        NSLog(@"It's away!");
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end

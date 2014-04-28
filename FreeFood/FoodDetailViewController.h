//
//  FoodDetailViewController.h
//  FreeFood
//
//  Created by Hao Ge on 4/25/14.
//  Copyright (c) 2014 Hao Ge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "EventBean.h"
#import <MessageUI/MessageUI.h>

@interface FoodDetailViewController : UIViewController <UIActionSheetDelegate, MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *eventName;
@property (weak, nonatomic) IBOutlet UILabel *eventPlace;
@property (weak, nonatomic) IBOutlet UILabel *startTime;
@property (weak, nonatomic) IBOutlet UILabel *endTime;
@property (weak, nonatomic) IBOutlet PFImageView *bigImage;

- (IBAction)shareButton:(id)sender;
- (IBAction)saveToCal:(id)sender;

@property UIActionSheet *standardIBAS;

@property (nonatomic, strong) EventBean *event;


@end

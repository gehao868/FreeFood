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

@interface FoodDetailViewController : UIViewController <UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UILabel *eventName;

- (IBAction)shareButton:(id)sender;
- (IBAction)saveToCal:(id)sender;

@property UIActionSheet *standardIBAS;

@property (nonatomic, strong) EventBean *event;


@end
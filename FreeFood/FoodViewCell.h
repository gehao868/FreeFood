//
//  FoodViewCell.h
//  FreeFood
//
//  Created by Hao Ge on 4/25/14.
//  Copyright (c) 2014 Hao Ge. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FoodViewCell : UITableViewCell

@property(nonatomic, weak) IBOutlet UILabel *eventLabel;

@property(nonatomic, weak) IBOutlet UILabel *eventPlace;
@property(nonatomic, weak) IBOutlet UILabel *eventTime;
@property(nonatomic, weak) IBOutlet UIImageView *eventImage;

@end

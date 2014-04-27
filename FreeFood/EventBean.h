//
//  EventBean.h
//  FreeFood
//
//  Created by Hao Ge on 4/25/14.
//  Copyright (c) 2014 Hao Ge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>


@interface EventBean : NSObject

@property (strong, nonatomic) NSString *description;
@property (strong, nonatomic) PFFile *image;
@property (strong, nonatomic) NSString *building;
@property (strong, nonatomic) NSString *place;
@property (strong, nonatomic) NSString *coordinate;
@property (strong, nonatomic) NSDate *startTime;
@property (strong, nonatomic) NSDate *endTime;

@end

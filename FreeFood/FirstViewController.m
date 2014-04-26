//
//  FirstViewController.m
//  FreeFood
//
//  Created by Hao Ge on 4/23/14.
//  Copyright (c) 2014 Hao Ge. All rights reserved.
//

#import "FirstViewController.h"
#import "FoodViewCell.h"
#import "FoodDetailViewController.h"

@interface FirstViewController ()

@end

@implementation FirstViewController
{
    NSArray *tableData;
    NSArray *thumbnails;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    tableData = [NSMutableArray arrayWithObjects:@"Egg Benedict", @"Mushroom Risotto", nil];
    thumbnails = [NSMutableArray arrayWithObjects:@"ham_and_egg_sandwich.jpg", @"full_breakfast.jpg", nil];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [tableData count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FoodViewCell";
    
    FoodViewCell *cell = (FoodViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[FoodViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier: CellIdentifier];
    }
    
    cell.eventLabel.text = [tableData objectAtIndex:indexPath.row];
    cell.eventImage.image = [UIImage imageNamed:[thumbnails objectAtIndex: indexPath.row]];
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showdetail"]) {
        NSIndexPath *indexPath = nil;
        
        indexPath = [self.tableView indexPathForSelectedRow];
        FoodDetailViewController *destViewController = segue.destinationViewController;
        destViewController.ename = [tableData objectAtIndex:indexPath.row];
    }
}

@end

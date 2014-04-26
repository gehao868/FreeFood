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
#import "EventBean.h"

@interface FirstViewController ()

@end

@implementation FirstViewController
{
    NSArray *events;
    NSArray *searchResults;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    EventBean *event1 = [EventBean new];
    event1.title = @"Egg Benedict";
    event1.imgUrl = @"ham_and_egg_sandwich.jpg";
    
    EventBean *event2 = [EventBean new];
    event2.title = @"Mushroom Risotto";
    event2.imgUrl = @"full_breakfast.jpg";
    
    events = [NSArray arrayWithObjects:event1, event2, nil];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [searchResults count];
    } else {
        return [events count];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 85;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FoodViewCell";
    
    FoodViewCell *cell = (FoodViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[FoodViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier: CellIdentifier];
    }
    
    EventBean *event = nil;
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        event = [searchResults objectAtIndex:indexPath.row];
    } else {
        event = [events objectAtIndex:indexPath.row];
    }
    cell.eventLabel.text = event.title;
    cell.eventImage.image = [UIImage imageNamed:event.imgUrl];
    
    return cell;
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showdetail"]) {
        NSIndexPath *indexPath = nil;
        EventBean *event = nil;
        
        if (self.searchDisplayController.active) {
            indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
            event = [searchResults objectAtIndex:indexPath.row];
        } else {
            indexPath = [self.tableView indexPathForSelectedRow];
            event = [events objectAtIndex:indexPath.row];
        }
        
        indexPath = [self.tableView indexPathForSelectedRow];
        FoodDetailViewController *destViewController = segue.destinationViewController;
        destViewController.hidesBottomBarWhenPushed = YES;
        destViewController.event = event;
    }
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"title contains[c] %@", searchText];
    searchResults = [events filteredArrayUsingPredicate:resultPredicate];
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self filterContentForSearchText:searchString scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                                        objectAtIndex:[self.searchDisplayController.searchBar
                                                                       selectedScopeButtonIndex]]];
    return YES;
}

@end

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
#import "PostEventController.h"

#define SERVER @"http://mobile.yiye.im:8080/"

@interface FirstViewController ()

@end

@implementation FirstViewController
{
    NSMutableArray *events;
    NSArray *searchResults;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self retrieveData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)retrieveData {
    NSError *error;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://mobile.yiye.im:8080/mobile/queryAll.do"]];
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSDictionary *eventDic = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableLeaves error:&error];
    
    events = [[NSMutableArray alloc] init];
    
    for (id eventInfo in eventDic) {
        EventBean *event = [EventBean new];
        event.title = [eventInfo objectForKey:@"title"];
        event.place = [eventInfo objectForKey:@"place"];
        event.building = [eventInfo objectForKey:@"building"];
        event.coordinate = [eventInfo objectForKey:@"coordinate"];
        event.detail = [eventInfo objectForKey:@"detail"];
        event.imgUrl = [eventInfo objectForKey:@"imgUrl"];
        
        //event.endTime = [eventInfo objectForKey:@"endTime"];
        //event.time = [eventInfo objectForKey:@"time"];
        
        [events addObject:event];
    }
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
    
    NSData * imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString:[NSString stringWithFormat:@"http://mobile.yiye.im:8080/%@", event.imgUrl]]];
    cell.eventImage.image = [UIImage imageWithData: imageData];
    cell.eventPlace.text = [NSString stringWithFormat:@"%@ %@", event.building, event.place];
   // cell.eventTime.text
    
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
    
    if ([segue.identifier isEqualToString:@"postEvent"]) {
        PostEventController *destViewController = segue.destinationViewController;
        destViewController.hidesBottomBarWhenPushed = YES;
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

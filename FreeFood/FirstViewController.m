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
//    NSMutableArray *events;
//    NSArray *searchResults;
}

-(id)initWithCoder:(NSCoder *)aCoder {
    self = [super initWithCoder:aCoder];
    if (self) {
        self.parseClassName = @"event";
        self.textKey = @"description";
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = NO;
    }
    
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshTable:)
                                                 name:@"refreshTable"
                                               object:nil];
}

- (void)refreshTable:(NSNotification *) notification
{
    // Reload the recipes
    [self loadObjects];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"refreshTable" object:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

-(PFQuery *)queryForTable {
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    return query;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

/*
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
 
*/


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 85;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
    static NSString *CellIdentifier = @"FoodViewCell";
    
    FoodViewCell *cell = (FoodViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[FoodViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier: CellIdentifier];
    }
    

    
//    if (tableView == self.searchDisplayController.searchResultsTableView) {
//        event = [searchResults objectAtIndex:indexPath.row];
//    } else {
        cell.eventLabel.text = [object objectForKey:@"description"];
        PFFile *thumbnail = [object objectForKey:@"image"];
        PFImageView *thumbnailImageView = (PFImageView*)[cell viewWithTag:100];
        thumbnailImageView.file = thumbnail;
        [thumbnailImageView loadInBackground];
        cell.eventPlace.text = [object objectForKey:@"building"];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MM-dd-yyyy"];
        cell.eventTime.text = [formatter stringFromDate:[object objectForKey:@"startTime"]];
        //[NSString stringWithFormat:@"%@ %@", event.building, event.place];
//    }
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Remove the row from data model
    PFObject *object = [self.objects objectAtIndex:indexPath.row];
    [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [self refreshTable:nil];
    }];
}

- (void) objectsDidLoad:(NSError *)error
{
    [super objectsDidLoad:error];
    
    NSLog(@"error: %@", [error localizedDescription]);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showdetail"]) {
        NSIndexPath *indexPath = nil;
        EventBean *event = nil;
        
        if (self.searchDisplayController.active) {
            indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
            //event = [searchResults objectAtIndex:indexPath.row];
        } else {
            indexPath = [self.tableView indexPathForSelectedRow];
           // event = [events objectAtIndex:indexPath.row];
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
  //  searchResults = [events filteredArrayUsingPredicate:resultPredicate];
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self filterContentForSearchText:searchString scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                                        objectAtIndex:[self.searchDisplayController.searchBar
                                                                       selectedScopeButtonIndex]]];
    return YES;
}

@end

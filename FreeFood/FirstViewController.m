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
    BOOL isSearch;
    NSString *searchTerm;
    NSMutableArray *searchResults;
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
    searchResults = [NSMutableArray array];
    
}

- (void)refreshTable:(NSNotification *) notification
{
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
    [query orderByAscending:@"startTime"];
    
    [query whereKey:@"endTime" greaterThanOrEqualTo:[NSDate date]];
    query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    return query;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 85;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.tableView) {
        
        return self.objects.count;
    } else {
        return searchResults.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
    static NSString *CellIdentifier = @"FoodViewCell";
    
    FoodViewCell *cell = (FoodViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[FoodViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier: CellIdentifier];
    }
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        PFObject *newObject = [searchResults objectAtIndex:indexPath.row];
        cell.eventLabel.text = [newObject objectForKey:@"description"];
        PFFile *thumbnail = [newObject objectForKey:@"image"];
        PFImageView *thumbnailImageView = (PFImageView*)[cell viewWithTag:100];
        thumbnailImageView.file = thumbnail;
        [thumbnailImageView loadInBackground];
        
        cell.eventPlace.text = [NSString stringWithFormat:@"%@ %@", [newObject objectForKey:@"building"], [newObject objectForKey:@"place"]];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy/MM/dd HH:mm"];
        cell.eventTime.text = [formatter stringFromDate:[newObject objectForKey:@"startTime"]];
        NSLog(@"%@", [newObject objectForKey:@"description"]);
    } else {
        cell.eventLabel.text = [object objectForKey:@"description"];
        PFFile *thumbnail = [object objectForKey:@"image"];
        PFImageView *thumbnailImageView = (PFImageView*)[cell viewWithTag:100];
        thumbnailImageView.file = thumbnail;
        [thumbnailImageView loadInBackground];
        
        cell.eventPlace.text = [NSString stringWithFormat:@"%@ %@", [object objectForKey:@"building"], [object objectForKey:@"place"]];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy/MM/dd HH:mm"];
        cell.eventTime.text = [formatter stringFromDate:[object objectForKey:@"startTime"]];
    }
    return cell;
}

- (void) objectsDidLoad:(NSError *)error
{
    [super objectsDidLoad:error];
    
    NSLog(@"error: %@", [error localizedDescription]);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showdetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        FoodDetailViewController *destViewController = segue.destinationViewController;
        PFObject *object;
        if (self.searchDisplayController.active) {
            NSIndexPath *indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
            NSLog(@"%li", indexPath.row);
            object = [searchResults objectAtIndex:indexPath.row];
        } else {
            NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
            object = [self.objects objectAtIndex:indexPath.row];
        }
        EventBean *event = [[EventBean alloc] init];
        
        event.description = [object objectForKey:@"description"];
        event.image = [object objectForKey:@"image"];
        event.building =[object objectForKey:@"building"];
        event.place = [object objectForKey:@"place"];
        
        event.startTime = [object objectForKey:@"startTime"];
        event.endTime = [object objectForKey:@"endTime"];
        
        event.coordinate = [object objectForKey:@"coordinate"];
        
        indexPath = [self.tableView indexPathForSelectedRow];
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
    if ([searchText isEqualToString:@""]) {
        isSearch = NO;
    } else {
        isSearch = YES;
        searchTerm = searchText;
    }
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    [query orderByAscending:@"startTime"];
    
    [query whereKey:@"endTime" greaterThanOrEqualTo:[NSDate date]];
    if (isSearch) {
        [query whereKey:@"description" containsString:searchTerm];
        isSearch = NO;
    }
    [query findObjectsInBackgroundWithTarget:self selector:@selector(callbackWithResult:error:)];
    //    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"title contains[c] %@", searchText];
    //  searchResults = [events filteredArrayUsingPredicate:resultPredicate];
}

- (void)callbackWithResult:(NSArray *)celebrities error:(NSError *)error
{
    if(!error) {
        [searchResults removeAllObjects];
        [searchResults addObjectsFromArray:celebrities];
        [self.searchDisplayController.searchResultsTableView reloadData];
    }
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self filterContentForSearchText:searchString scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                                         objectAtIndex:[self.searchDisplayController.searchBar
                                                                        selectedScopeButtonIndex]]];
    return YES;
}

@end

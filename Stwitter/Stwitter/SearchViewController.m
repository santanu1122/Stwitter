//
//  SearchViewController.m
//  Stwitter
//
//  Created by Andrew Long on 5/18/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import "SearchViewController.h"
#import "FilteredTwitterStream.h"
#import "Trend.h"

@class StreamTableViewController;

@interface SearchViewController ()

@property (strong, nonatomic) NSMutableArray *trends;

- (void)loadTrends;
- (void)configureView;

@end

@implementation SearchViewController

@synthesize account = _account;
@synthesize searchBar = _searchBar;
@synthesize tableView = _tableView;
@synthesize trends = _trends;

#pragma mark - Managing the detail item

- (void)setAccount:(ACAccount *)newAccount
{
    if (_account != newAccount) {
        _account = newAccount;
        
        // Update the view.
        [self configureView];
    }
}

- (void)configureView
{
    self.trends = [NSMutableArray array];
    [self loadTrends];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self.searchBar becomeFirstResponder];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.searchBar = nil;
    self.tableView = nil;
}

- (void)loadTrends
{
    TrendsFetcher *trendsFetcher = [[[TrendsFetcher alloc] initWithTwitterAccount:self.account
                                                                         delegate:self] autorelease];
    
    [trendsFetcher fetch];
}

- (void)fetcherReceivedTrends:(TrendsFetcher *)fetcher trends:(NSArray *)trends;
{
    self.trends = [trends copy];
    [self.tableView reloadData];
}

- (void)fetcherDidFailConnection:(TrendsFetcher *)fetcher
{
    NSLog(@"Trend fetcher failed connection");
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.trends count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Top Trends";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    Trend *trend = [self.trends objectAtIndex:indexPath.row];
    cell.textLabel.text = trend.name;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Trend *trend = [self.trends objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"showStream" sender:[NSArray arrayWithObject:trend.query]];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self performSegueWithIdentifier:@"showStream" sender:[self.searchBar.text componentsSeparatedByString:@" "]];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)keywords
{
    if ([[segue identifier] isEqualToString:@"showStream"]) {
        FilteredTwitterStream *stream = [[[FilteredTwitterStream alloc] initWithKeywords:[(NSArray *)keywords copy] 
                                                                                 account:self.account
                                                                                delegate:[segue destinationViewController]] autorelease];
        
        id destinationViewController = [segue destinationViewController];
        if ([destinationViewController respondsToSelector:@selector(setStream:)]) {
            [destinationViewController performSelector:@selector(setStream:) withObject:stream];
        }
    }
}

@end

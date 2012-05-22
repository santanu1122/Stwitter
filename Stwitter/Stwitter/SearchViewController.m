//
//  SearchViewController.m
//  Stwitter
//
//  Created by Andrew Long on 5/18/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import "SearchViewController.h"
#import "FilteredTwitterStream.h"

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
    // Load trends from twitter in a background thread
    [NSThread detachNewThreadSelector:@selector(loadTrends) toTarget:self withObject:self];
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
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];    
    
    // Update the user interface for the detail item.
    NSString *trends = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"https://api.twitter.com/1/trends/daily.json"]
                                                encoding:NSStringEncodingConversionAllowLossy
                                                   error:nil];
    NSDictionary *trendsDict = [NSJSONSerialization JSONObjectWithData:[trends dataUsingEncoding:NSUTF8StringEncoding] 
                                                               options:0
                                                                 error:nil];
    NSDictionary *allTrends = [trendsDict objectForKey:@"trends"];
    NSArray *theTrends = [allTrends objectForKey:[[allTrends allKeys] objectAtIndex:0]];
    
//    NSLog(@"%@", theTrends);
    self.trends = [theTrends mutableCopy];
    [self.tableView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
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
    
    NSDictionary *trend = [self.trends objectAtIndex:indexPath.row];
    cell.textLabel.text = [trend objectForKey:@"name"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *trend = [self.trends objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"showStream" sender:[NSArray arrayWithObject:[trend objectForKey:@"query"]]];
}

@end

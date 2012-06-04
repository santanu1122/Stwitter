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
{
    UINavigationBar *navBar;
    SlidingMenuViewController *_slidingMenuViewController;
}

@property (retain) NSArray *trends;
@property (nonatomic, retain) TrendsFetcher *trendsFetcher;
@property (nonatomic, retain) SlidingMenuViewController *slidingMenuViewController;
@property (nonatomic, retain) UISearchBar *searchBar;
@property (nonatomic, retain) UITableView *tableView;

- (void)loadTrends;
- (void)configureView;

@end

@implementation SearchViewController

@synthesize account = _account;
@synthesize searchBar = _searchBar;
@synthesize tableView = _tableView;
@synthesize trends = _trends;
@synthesize trendsFetcher = _trendsFetcher;
@synthesize slidingMenuViewController = _slidingMenuViewController;

#pragma mark - Managing the detail item

- (id)initWithSlidingMenu:(SlidingMenuViewController *)slidingMenuViewController
{
    self = [super init];
    if (self) {
        CGRect fullScreen = [[UIScreen mainScreen] bounds];
        self.view.frame = CGRectMake(0, 20, fullScreen.size.width, fullScreen.size.height);
        self.view.backgroundColor = [UIColor blueColor];
        self.slidingMenuViewController = slidingMenuViewController;
        self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
        
        navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, fullScreen.size.width, 45)];
        UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"Accounts" 
                                                                        style:UIBarButtonSystemItemDone 
                                                                       target:self 
                                                                       action:@selector(slideMenu)];
        UINavigationItem *item = [[UINavigationItem alloc] initWithTitle:@"Search"];
        item.leftBarButtonItem = leftButton;
        item.hidesBackButton = YES;
        [navBar pushNavigationItem:item animated:NO];
        [leftButton release];
        [item release];
        
        [self.view addSubview:navBar];
    }
    
    return self;
}

- (void)setAccount:(ACAccount *)newAccount
{
    if (_account != newAccount) {
        _account = newAccount;
        
        // Update the view.
        [self configureView];
        [self.slidingMenuViewController slide];
    }
}

- (void)configureView
{
    self.trends = [NSArray array];
    [self loadTrends];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self.view addSubview:self.searchBar];
    //[self.searchBar becomeFirstResponder];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.searchBar = nil;
    self.tableView = nil;
    
    [self.trendsFetcher cancel];
    self.trendsFetcher = nil;
    self.trends = nil;
}

- (void)slideMenu
{
    [self.slidingMenuViewController slide];
}

- (void)loadTrends
{
    self.trendsFetcher = [[TrendsFetcher alloc] initWithTwitterAccount:self.account
                                                              delegate:self];
    
    [self.trendsFetcher fetch];
    [self.trendsFetcher release];
}

- (void)fetcherReceivedTrends:(TrendsFetcher *)fetcher trends:(NSArray *)trends;
{
    self.trends = trends;
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
        FilteredTwitterStream *stream = [[[FilteredTwitterStream alloc] initWithKeywords:(NSArray *)keywords 
                                                                                 account:self.account
                                                                                delegate:[segue destinationViewController]] autorelease];
        
        id destinationViewController = [segue destinationViewController];
        if ([destinationViewController respondsToSelector:@selector(setStream:)]) {
            [destinationViewController performSelector:@selector(setStream:) withObject:stream];
        }
    }
}

- (void)dealloc
{
    self.searchBar = nil;
    self.tableView = nil;
    self.trends = nil;
    self.trendsFetcher = nil;
    
    [super dealloc];
}

@end

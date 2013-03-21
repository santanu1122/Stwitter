//
//  SearchViewController.m
//  Stwitter
//
//  Created by Andrew Long on 5/18/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import "TrendsViewController.h"
#import "FilteredTwitterStream.h"
#import "Trend.h"
#import "StreamTableViewController.h"
#import "TrendsTableViewController.h"

@class StreamTableViewController;

@interface TrendsViewController ()
{
    SlidingMenuViewController *_slidingMenuViewController;
}

@property (retain) NSArray *trends;
@property (nonatomic, retain) TrendsFetcher *trendsFetcher;
@property (nonatomic, retain) SlidingMenuViewController *slidingMenuViewController;
@property (nonatomic, retain) TrendsTableViewController *trendsTableView;

- (void)loadTrends;
- (void)configureView;

@end

@implementation TrendsViewController

@synthesize account = _account;
@synthesize trendsTableView = _trendsTableView;
@synthesize trends = _trends;
@synthesize trendsFetcher = _trendsFetcher;
@synthesize slidingMenuViewController = _slidingMenuViewController;

#pragma mark - Managing the detail item

- (id)initWithSlidingMenu:(SlidingMenuViewController *)slidingMenuViewController
{
    self = [super init];
    if (self) {
        CGRect fullScreen = [[UIScreen mainScreen] bounds];
        self.view.frame = CGRectMake(0, 100, fullScreen.size.width, fullScreen.size.height);
        self.view.backgroundColor = [UIColor blueColor];
        
        self.tabBarItem = [[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemFeatured tag:1] autorelease];

        
        self.slidingMenuViewController = slidingMenuViewController;

        self.trendsTableView = [[TrendsTableViewController alloc] initWithDelegate:self];
        
        UINavigationController *appNavigationController = [[UINavigationController alloc] initWithRootViewController:self.trendsTableView];
        [self.view addSubview:appNavigationController.view];
        
        self.title = @"Trends";
                
        UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"Accounts" 
                                                                        style:UIBarButtonSystemItemDone 
                                                                       target:self 
                                                                       action:@selector(slideMenu)];
        [self.navigationItem setLeftBarButtonItem:leftButton];
        [self.navigationItem setHidesBackButton:YES];
        [leftButton release];
        
        
        //[self.view addSubview:self.trendsTableView.view];
       // [viewContainer addSubview:self.tableView];
    }
    
    return self;
}

- (void)setAccount:(ACAccount *)newAccount
{
    if (_account != newAccount) {
        _account = newAccount;
        
        // Update the view.
        [self configureView];
    }
    [self.slidingMenuViewController slide];
}

- (void)configureView
{
    self.trends = [NSArray array];
    self.trendsTableView.trends = self.trends;
    [self loadTrends];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    if (self.navigationController.navigationBar.frame.origin.y > 0.0) {
        self.navigationController.navigationBar.frame = CGRectOffset(self.navigationController.navigationBar.frame, 0.0, -20.0);
    }    
}

- (void)viewDidAppear:(BOOL)animated
{
    if (self.view.superview.frame.origin.y > 44.0) {
        UIView *container = self.view.superview;
        container.frame = CGRectMake(container.frame.origin.x, container.frame.origin.y - 20.0, container.frame.size.width, container.frame.size.height + 20.0);
    }

    [super viewDidAppear:animated];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.trendsTableView = nil;
    
    [self.trendsFetcher cancel];
    self.trendsFetcher = nil;
    self.trends = nil;
    self.trendsTableView.trends = self.trends;
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
    self.trendsTableView.trends = self.trends;
}

- (void)fetcherDidFailConnection:(TrendsFetcher *)fetcher
{
    NSLog(@"Trend fetcher failed connection");
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
//    if (UIInterfaceOrientationIsLandscape(fromInterfaceOrientation)) {
//        CGRect frame = self.view.frame;
//        frame.origin.y = 60;
//        self.view.frame = frame;
//    } else {
//        CGRect frame = self.view.frame;
//        frame.origin.y = 90;
//        self.view.frame = frame;
//    }
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

- (void)tappedOnTrend:(Trend *)trend
{
    [self pushStreamViewWithKeywords:[NSArray arrayWithObject:trend.query]];
}

- (void)pushStreamViewWithKeywords:(NSArray *)keywords
{
    StreamTableViewController *streamViewController = [[[StreamTableViewController alloc] init] autorelease];
    FilteredTwitterStream *stream = [[[FilteredTwitterStream alloc] initWithKeywords:(NSArray *)keywords 
                                                                             account:self.account
                                                                            delegate:streamViewController] autorelease];
    
    id destinationViewController = streamViewController;
    if ([destinationViewController respondsToSelector:@selector(setStream:)]) {
        [destinationViewController performSelector:@selector(setStream:) withObject:stream];
        [self.trendsTableView.navigationController pushViewController:destinationViewController animated:YES];
    }
}

- (void)dealloc
{
    self.trendsTableView = nil;
    self.trends = nil;
    self.trendsFetcher = nil;
    
    [super dealloc];
}

@end

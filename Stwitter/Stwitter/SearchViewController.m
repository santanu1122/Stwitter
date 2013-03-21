//
//  SearchView2Controller.m
//  Stwitter
//
//  Created by Andrew Long on 6/16/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import "SearchViewController.h"
#import "StreamTableViewController.h"
#import "FilteredTwitterStream.h"

@interface SearchViewController ()
{
    UIButton *_dismissBackground;
}

@property (nonatomic, retain) UISearchBar *searchBar;
@property (nonatomic, retain) FilteredTwitterStream *stream;
@property (nonatomic, retain) UIButton *dismissBackground;

- (void)pushStreamViewWithKeywords:(NSArray *)keywords;
- (void)dismissKeyboard;

@end

@implementation SearchViewController

@synthesize searchBar = _searchBar;
@synthesize delegate = _delegate;
@synthesize stream = _stream;
@synthesize dismissBackground = _dismissBackground;

- (id)initWithDelegate:(id<SearchViewDelegate>)delegate
{
    self = [super init];
    if (self) {
        self.view.backgroundColor = [UIColor whiteColor];
        // Custom initialization
        CGRect fullScreen = [[UIScreen mainScreen] bounds];
        self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, fullScreen.size.width, 45)];
        self.dismissBackground  = [UIButton buttonWithType:UIButtonTypeCustom];
        self.dismissBackground.frame = CGRectMake(0, 45, fullScreen.size.width, fullScreen.size.height);
        [self.dismissBackground addTarget:self action:@selector(dismissKeyboard) forControlEvents:UIControlEventTouchUpInside];
        self.searchBar.delegate = self;
        self.delegate = delegate;
        self.stream = nil;
        self.title = @"Search";
        [self.view addSubview:self.searchBar];
        [self.view addSubview:self.dismissBackground];
        self.tabBarItem = [[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemSearch tag:0] autorelease];
    }
    return self;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self pushStreamViewWithKeywords:[self.searchBar.text componentsSeparatedByString:@" "]];
    [self.dismissBackground setHidden:YES];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [self.dismissBackground setHidden:NO];
    [self.stream stop];
    
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.stream stop];
    [self.dismissBackground setHidden:NO];
}

- (void)dismissKeyboard
{
    [self.searchBar resignFirstResponder];
    [self.dismissBackground setHidden:YES];
}

- (void)pushStreamViewWithKeywords:(NSArray *)keywords
{
    [self.searchBar resignFirstResponder];
    StreamTableViewController *streamViewController = [[StreamTableViewController alloc] init];
    self.stream = nil;
    self.stream = [[FilteredTwitterStream alloc] initWithKeywords:(NSArray *)keywords 
                                                                             account:self.delegate.account
                                                                            delegate:streamViewController];
    
    [streamViewController setStream:self.stream];
    CGRect frame = streamViewController.view.frame;
    frame.origin.y += 25;
    frame.size.height -= 95;
    streamViewController.view.frame = frame;
    
    [self.view insertSubview:streamViewController.view belowSubview:self.searchBar];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.view addSubview:self.searchBar];
    //[self.searchBar becomeFirstResponder];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.searchBar = nil;

}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:animated];

    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    
    [super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc
{
    self.searchBar = nil;
    [super dealloc];
}

@end

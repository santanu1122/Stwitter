//
//  SearchTabBarViewController.m
//  Stwitter
//
//  Created by Andrew Long on 6/16/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import "SearchTabBarViewController.h"
#import "SearchViewController.h"

@interface SearchTabBarViewController ()
{
    SlidingMenuViewController *_slidingMenuViewController;
}

@property (nonatomic, retain) UITabBarController *tabBarController;
@property (nonatomic, retain) SlidingMenuViewController *slidingMenuViewController;

@end

@implementation SearchTabBarViewController

@synthesize tabBarController = _tabBarController;
@synthesize slidingMenuViewController = _slidingMenuViewController;

- (id)initWithControllers:(NSArray *)controllers andSlidingMenuViewController:(SlidingMenuViewController *)slidingMenu
{
    self = [super init];
    if (self) {

        self.wantsFullScreenLayout = YES;
        // Custom initialization
        _tabBarController = [[UITabBarController alloc] init];
        UINavigationController *searchController = [[UINavigationController alloc] initWithRootViewController:[controllers objectAtIndex:1]];
        
        [_tabBarController setViewControllers:[NSArray arrayWithObjects:[controllers objectAtIndex:0], searchController, nil]];
        
        [self.view addSubview:_tabBarController.view];
        self.slidingMenuViewController = slidingMenu;
        self.title = @"Stwitter";


    }
    return self;
}

- (void)slideMenu
{
    [self.slidingMenuViewController slide];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (NO);
}

@end

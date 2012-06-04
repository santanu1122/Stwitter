//
//  SearchViewController.h
//  Stwitter
//
//  Created by Andrew Long on 5/18/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TrendsFetcher.h"
#import "SlidingMenuViewController.h"

@class ACAccount;

@interface SearchViewController : UIViewController <UITableViewDelegate, UISearchBarDelegate, TrendsFetcherDelegate>
{
}

@property (nonatomic, retain) ACAccount* account;

- (id)initWithSlidingMenu:(SlidingMenuViewController *)slidingMenuViewController;
- (void)slideMenu;

@end

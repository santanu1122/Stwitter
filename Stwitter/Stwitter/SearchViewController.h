//
//  SearchViewController.h
//  Stwitter
//
//  Created by Andrew Long on 5/18/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TrendsFetcher.h"

@class ACAccount;

@interface SearchViewController : UIViewController <UITableViewDelegate, UISearchBarDelegate, TrendsFetcherDelegate>

@property (strong, nonatomic) ACAccount* account;

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UITableView *tableView;


@end

//
//  TrendsTableViewController.h
//  Stwitter
//
//  Created by Andrew Long on 6/16/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Trend;

@protocol TrendsTableViewDelegate <NSObject>

@optional

- (void)tappedOnTrend:(Trend *)trend;
- (void)slideMenu;

@end

@interface TrendsTableViewController : UITableViewController

@property (nonatomic, retain)id<TrendsTableViewDelegate> delegate;
@property (nonatomic, retain) NSArray *trends;


- (id)initWithDelegate:(id<TrendsTableViewDelegate>)delegate;

@end

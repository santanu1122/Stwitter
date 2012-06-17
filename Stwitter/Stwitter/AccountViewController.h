//
//  AccountViewController.h
//  Stwitter
//
//  Created by Andrew Long on 5/18/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TrendsViewController.h"

@interface AccountViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    TrendsViewController *_searchViewController;
}

@property (nonatomic, retain) TrendsViewController *searchViewController;

@end

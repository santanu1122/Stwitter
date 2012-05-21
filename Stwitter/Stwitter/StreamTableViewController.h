//
//  StreamTableViewController.h
//  Stwitter
//
//  Created by Andrew Long on 5/20/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FilteredTwitterStream.h"

@interface StreamTableViewController : UITableViewController

@property (strong, nonatomic) FilteredTwitterStream *stream;

- (void)setStream:(FilteredTwitterStream *)newStream;

@end

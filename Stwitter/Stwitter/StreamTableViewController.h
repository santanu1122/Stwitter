//
//  StreamTableViewController.h
//  Stwitter
//
//  Created by Andrew Long on 5/20/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StreamTableViewController : UITableViewController

@property (strong, nonatomic) id stream;

- (void)setStream:(id)newStream;

@end

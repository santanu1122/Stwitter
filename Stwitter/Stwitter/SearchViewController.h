//
//  SearchViewController.h
//  Stwitter
//
//  Created by Andrew Long on 5/18/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Accounts/Accounts.h>

@interface SearchViewController : UIViewController

@property (strong, nonatomic) ACAccount* account;

@property (strong, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end

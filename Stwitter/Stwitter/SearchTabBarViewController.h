//
//  SearchTabBarViewController.h
//  Stwitter
//
//  Created by Andrew Long on 6/16/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlidingMenuViewController.h"

@interface SearchTabBarViewController : UIViewController


- (id)initWithControllers:(NSArray *)controllers andSlidingMenuViewController:(SlidingMenuViewController *)slidingMenu;
- (void)slideMenu;

@end

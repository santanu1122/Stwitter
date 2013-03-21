//
//  SearchView2Controller.h
//  Stwitter
//
//  Created by Andrew Long on 6/16/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ACAccount;

@protocol SearchViewDelegate <NSObject>

- (ACAccount*)account;

@end

@interface SearchViewController : UIViewController <UISearchBarDelegate>

@property (nonatomic, retain) id<SearchViewDelegate> delegate;

- (id)initWithDelegate:(id<SearchViewDelegate>)delegate;

@end

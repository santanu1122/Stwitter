//
//  TrendsFetcher.h
//  Stwitter
//
//  Created by Andrew Long on 5/22/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TrendsFetcher;
@class ACAccount;

@protocol TrendsFetcherDelegate <NSObject>

@optional

- (void)fetcherReceivedTrends:(TrendsFetcher *)fetcher trends:(NSArray *)trends;
- (void)fetcherDidFailConnection:(TrendsFetcher *)fetcher;

@end

@interface TrendsFetcher : NSObject

- (id)initWithTwitterAccount:(ACAccount *)account
                    delegate:(id<TrendsFetcherDelegate>)delegate;

- (void)fetch;
- (void)cancel;

@end

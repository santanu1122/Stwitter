//
//  TrendsFetcher.m
//  Stwitter
//
//  Created by Andrew Long on 5/22/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import "TrendsFetcher.h"
#import "Trend.h"

#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>

@interface TrendsFetcher ()

- (NSArray *)loadTrends;

@property (nonatomic, assign) id<TrendsFetcherDelegate> delegate;
@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, retain) ACAccount *account;
@property (nonatomic, retain) NSMutableData *receivedData;

@end

@implementation TrendsFetcher

@synthesize delegate = _delegate;
@synthesize connection = _connection;
@synthesize account = _account;
@synthesize receivedData = _receivedData;

- (id)initWithTwitterAccount:(ACAccount *)account
                    delegate:(id<TrendsFetcherDelegate>)delegate;
{
    self = [super init];
    if (self) {
        // Twitter account object needed for authentication
        self.account = account;
        
        self.delegate = delegate;
    }
    return self;
}

- (void)fetch
{
    // Get current date into twitter's format
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    [dateFormatter release];

    // Create a twitter request for attaching to NSURLConnection.
    // HTTP method to use is GET as required by twitter.
    TWRequest *request = [[TWRequest alloc] initWithURL:[NSURL URLWithString:@"https://api.twitter.com/1/trends/daily.json"]
                                             parameters:[NSMutableDictionary dictionaryWithObject:dateString forKey:@"date"]
                                          requestMethod:TWRequestMethodGET];
    //[dateString release];
    [request setAccount:self.account];
    
    self.connection = [NSURLConnection connectionWithRequest:request.signedURLRequest
                                                    delegate:self];
    
    [request release];
    self.receivedData = [NSMutableData data];
}

- (void)cancel
{
    [self.connection cancel];
    self.connection = nil;
}

- (NSArray *)loadTrends
{
    NSDictionary *trendsResponse = [NSJSONSerialization JSONObjectWithData:self.receivedData 
                                                                       options:0
                                                                         error:nil];
    NSDictionary *allTrends = [trendsResponse objectForKey:@"trends"];
    NSMutableArray *currentTrends = [allTrends objectForKey:[[allTrends allKeys] objectAtIndex:0]];
    NSMutableArray *wrappedTrends = [NSMutableArray arrayWithCapacity:[currentTrends count]];

    for (NSDictionary *trend in currentTrends) {
        [wrappedTrends addObject:[Trend fromJson:trend]];
    }
    
    return wrappedTrends;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // It can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.    
    [self.receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data 
{
    // Append the new data to receivedData.
    // receivedData is an instance variable declared elsewhere.
    [self.receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(fetcherReceivedTrends:trends:)]) {
        [self.delegate fetcherReceivedTrends:self trends:[self loadTrends]];
    }
    self.receivedData = nil;
}

// We need to pass any connection errors onto our delegate for handling
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error 
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(fetcherDidFailConnection:)]) {
        [self.delegate fetcherDidFailConnection:self];
    }
    
}

- (void)dealloc
{
    [self.connection cancel];
    self.connection = nil;
    
    self.account = nil;
    self.receivedData = nil;
    
    [super dealloc];
}

@end

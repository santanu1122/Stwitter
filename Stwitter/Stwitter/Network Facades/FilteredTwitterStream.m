//
//  FilteredTwitterStream.m
//  Stwitter
//
//  Created by Andrew Long on 5/20/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import "FilteredTwitterStream.h"

@implementation FilteredTwitterStream

@synthesize keywordString = _keywordString;

- (id)initWithKeywords:(NSArray *)keywords
               account:(ACAccount *)account
              delegate:(id<TwitterStreamDelegate>)delegate
{
    self.keywordString = [keywords componentsJoinedByString:@","];
    NSMutableDictionary* parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys: self.keywordString, @"track", nil];
    
    return [super initWithTwitterEndpoint:@"https://stream.twitter.com/1/statuses/filter.json"
                               parameters:parameters
                                  account:account
                                 delegate:delegate];
}

- (void)dealloc
{
    self.keywordString = nil;
    
    [super dealloc];
}

@end
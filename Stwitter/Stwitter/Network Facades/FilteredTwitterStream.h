//
//  FilteredTwitterStream.h
//  Stwitter
//
//  Created by Andrew Long on 5/20/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import "TwitterStream.h"

@interface FilteredTwitterStream : TwitterStream

@property (strong, nonatomic) NSString* keywordString;

- (id)initWithKeywords:(NSArray *)keywords
               account:(ACAccount *)account
              delegate:(id<TwitterStreamDelegate>)delegate;

@end

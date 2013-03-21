//
//  Tweet.m
//  Stwitter
//
//  Created by Andrew Long on 5/22/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import "Tweet.h"

@interface Tweet ()

@property (nonatomic, retain) NSDictionary *data;

@end

@implementation Tweet

@synthesize data = _data;

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    
    if (self) {
        self.data = dictionary;
    }
    
    return self;
}

+ (Tweet *)fromJson:(id)json
{
    Tweet *newTweet = [[Tweet alloc] initWithDictionary:(NSDictionary *)json];
    return [newTweet autorelease];
}

- (NSString *)text
{
    return [self.data objectForKey:@"text"];
}

- (NSString *)username
{
    return [(NSDictionary *)[self.data objectForKey:@"user"] objectForKey:@"screen_name"];
}

- (void)dealloc
{
    self.data = nil;
    [super dealloc];
}

@end
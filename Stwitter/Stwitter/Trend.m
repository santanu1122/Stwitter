//
//  Trend.m
//  Stwitter
//
//  Created by Andrew Long on 5/22/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import "Trend.h"

@interface Trend ()

@property (strong, nonatomic) NSDictionary *data;

@end

@implementation Trend

@synthesize data;

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    
    if (self) {
        self.data = dictionary;
    }
    
    return self;
}

+ (Trend *)fromJson:(id)json
{
    Trend *newTrend = [[Trend alloc] initWithDictionary:(NSDictionary *)json];
    return [newTrend autorelease];
}

- (NSString *)name
{
    return [data objectForKey:@"name"];
}

- (NSString *)query;
{
    return [data objectForKey:@"query"];
}

@end

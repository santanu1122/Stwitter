//
//  Trend.h
//  Stwitter
//
//  Created by Andrew Long on 5/22/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Trend : NSObject

+ (Trend *)fromJson:(id)json;
- (id)initWithDictionary:(NSDictionary *)dictionary;
- (NSString *)name;
- (NSString *)query;

@end

//
//  Tweet.h
//  Stwitter
//
//  Created by Andrew Long on 5/22/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

@interface Tweet : NSObject

+ (Tweet *)fromJson:(id)json;
- (id)initWithDictionary:(NSDictionary *)dictionary;
- (NSString *)text;
- (NSString *)username;

@end

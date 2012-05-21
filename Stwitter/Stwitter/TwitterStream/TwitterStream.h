//
//  TwitterStream.h
//  Stwitter
//
//  Created by Andrew Long on 5/20/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ACAccount;
@class TwitterStream;

@protocol TwitterStreamDelegate <NSObject>

@optional

- (void)streamReceivedMessage:(TwitterStream *)stream json:(id)json;
- (void)streamReceivedMessageJsonError:(TwitterStream *)stream errorMessage:(NSString *)errorMessage;
- (void)streamDidTimeout:(TwitterStream *)stream;
- (void)streamDidFailConnection:(TwitterStream *)stream;

@end

@interface TwitterStream : NSObject

- (id)initWithTwitterEndpoint:(NSString *)endpoint
         parameters:(NSDictionary *)parameters
            account:(ACAccount *)account
           delegate:(id<TwitterStreamDelegate>)delegate;

- (void)start;
- (void)stop;

@end





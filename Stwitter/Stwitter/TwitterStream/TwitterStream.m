//
//  TwitterStream.m
//  Stwitter
//
//  Created by Andrew Long on 5/20/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import "TwitterStream.h"

#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>

@interface TwitterStream ()

@property (nonatomic, assign) id<TwitterStreamDelegate> delegate;

@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, retain) NSTimer *keepAliveTimer; // As per twitter dev docs

@property (nonatomic, retain) NSString *endpoint;
@property (nonatomic, retain) NSMutableDictionary *parameters;
@property (nonatomic, retain) ACAccount *account;

- (void)receivedFullMessage:(NSString *)message;

@end



@implementation TwitterStream

@synthesize delegate = _delegate;

@synthesize connection = _connection;
@synthesize keepAliveTimer = _keepAliveTimer;

@synthesize endpoint = _endpoint;
@synthesize parameters = _parameters;
@synthesize account = _account;

- (id)initWithTwitterEndpoint:(NSString *)endpoint
                   parameters:(NSDictionary *)parameters
                      account:(ACAccount *)account
                     delegate:(id<TwitterStreamDelegate>)delegate 
{
    self = [super init];
    if (self) {
        // Which twitter service function to use for streaming
        self.endpoint = endpoint;
        
        self.parameters = [NSMutableDictionary dictionaryWithDictionary:parameters];
        // Parameter to allow us to count bytes to know when we received
        // entire message and need to start parsing.
        [self.parameters setObject:@"length" forKey:@"delimited"];
        // Twitter account object needed for authentication
        self.account = account;
        
        self.delegate = delegate;
    }
    return self;
}

- (void)start 
{
    // Create a twitter request for attaching to NSURLConnection.
    // HTTP method to use is POST as required by twitter.
    // Also needs a valid twitter account object for security auth.
    TWRequest *request = [[TWRequest alloc] initWithURL:[NSURL URLWithString:self.endpoint]
                                             parameters:self.parameters
                                          requestMethod:TWRequestMethodPOST];
    
    [request setAccount:self.account];
    
    self.connection = [NSURLConnection connectionWithRequest:request.signedURLRequest
                                                    delegate:self];
    
    // As per twitter docs we need a keep alive timer for the streaming connnection.
    // Start that timer before starting connection in case of connection start timeout.
    [self resetKeepAliveTimeout];
    
    // Send request and start retreiving data from twitter server
    [self.connection start];
    
    [request release];
}

// Stop the current stream from receiving messages
- (void)stop 
{
    [self.connection cancel];
    self.connection = nil;
}

- (void)receivedFullMessage:(NSString *)message
{
    
    NSError *jsonParsingError = nil;
    id json = [NSJSONSerialization JSONObjectWithData:[message dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&jsonParsingError];
    
    
    // Alert the delegate
    if (json) { 
        if (self.delegate && [self.delegate respondsToSelector:@selector(streamReceivedMessage:json:)]) {
            [self.delegate streamReceivedMessage:self json:json];
        }
    } else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(streamReceivedMessageJsonError:errorMessage:)]) {
            [self.delegate streamReceivedMessageJsonError:self errorMessage:[jsonParsingError localizedDescription]];
        }
    }
    
    // We have received a full message and it is valid. Restart the
    // keepAlive timer for the next message from the server.
    [self resetKeepAliveTimeout];
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data 
{
    NSMutableString *message = nil;
    int bytesExpected = 0;
    
    // Create a string from the response data. Split the response into it's parts.
    NSString *response = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    NSArray *responseMessageComponents = [response componentsSeparatedByString:@"\r\n"];
    
    for (NSString* part in responseMessageComponents) {
        int length = [part intValue];
        // When the intValue of the current part is greater than 0
        // we have encountered a new message in our response, and
        // the intValue is the number of expected bytes for the message
        if (length > 0) {
            bytesExpected = length;
            message = [NSMutableString string];
        } else if (bytesExpected > 0 && message) {
            if (message.length < bytesExpected) {
                // Append the current part to the full current message
                [message appendString:part];
                
                // If our message length is under our bytes expected
                // we need to add the message markers back on message
                // as they count towards expected message length.
                if (message.length < bytesExpected) {
                    [message appendString:@"\r\n"];
                }
                
                // Constructed a full message from response. Notify the delegate
                // and reset our current message to build next message.
                if (message.length == bytesExpected) {
                    [self receivedFullMessage:message];
                    
                    message = nil;
                    bytesExpected = 0;
                }
            }
        } else {
            [self resetKeepAliveTimeout];
        }
    }
}

// We need to pass any connection errors onto our delegate for handling
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error 
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(streamDidFailConnection:)]) {
        [self.delegate streamDidFailConnection:self];
    }
    
}

- (void)resetKeepAliveTimeout 
{
    [self.keepAliveTimer invalidate];
    self.keepAliveTimer = [NSTimer scheduledTimerWithTimeInterval:40 
                                                           target:self 
                                                         selector:@selector(onKeepAliveTimeout)
                                                         userInfo:nil
                                                          repeats:NO];
}

- (void)onKeepAliveTimeout 
{
    // Connection has timedout. We need to stop and start it again.
    [self stop];
    
    // Notify delegate of timeout event
    if (self.delegate && [self.delegate respondsToSelector:@selector(streamDidTimeout:)]) {
        [self.delegate streamDidTimeout:self];
    }
    
    // Make an attempt to restart the transmission
    [self start];
}

- (void)dealloc 
{
    [self.keepAliveTimer invalidate];
    self.keepAliveTimer = nil;

    [self.connection cancel];
    self.connection = nil;
    
    self.endpoint = nil;
    self.parameters = nil;
    self.account = nil;
    
    [super dealloc];
}

@end
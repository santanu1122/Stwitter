//
//  StreamTableViewController.m
//  Stwitter
//
//  Created by Andrew Long on 5/20/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import "StreamTableViewController.h"
#import "Tweet.h"

//#import <SDWebImage/UIImageView+WebCache.h>

#define MAX_TWEET_LOAD_LIMIT 200

@interface StreamTableViewController ()

@property (retain) NSMutableArray* tweets;
@property (retain) NSMutableArray* tweetDisplayQueue;
@property (assign) BOOL tweetDisplayTimer;

- (void)streamReceivedMessage:(TwitterStream *)stream json:(id)json;
- (void)streamReceivedMessageJsonError:(TwitterStream *)stream errorMessage:(NSString *)errorMessage;
- (void)streamDidTimeout:(TwitterStream *)stream;
- (void)streamDidFailConnection:(TwitterStream *)stream;

- (void)emptyTweetDisplayQueue;

@end

@implementation StreamTableViewController

@synthesize stream = _stream;
@synthesize tweets = _tweets;
@synthesize tweetDisplayQueue = _tweetDisplayQueue;
@synthesize tweetDisplayTimer = _tweetDisplayTimer;

- (id)init
{
    self = [super init];
    if (self) {
        self.tweetDisplayQueue = [NSMutableArray array];
        self.tweetDisplayTimer = YES;
    }
    
    return self;
}

- (void)setStream:(id)newStream
{
    if (_stream != newStream) {
        _stream = newStream;
        
        [self configureView];
    }
}

- (void)configureView
{
    // Start the stream request.
    self.tweets = [NSMutableArray array];
    [self.stream start];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationItem.title = self.stream.keywordString;
}

- (void)viewDidAppear:(BOOL)animated
{
    CGRect frame = self.tableView.frame;
//    frame.origin.x += 30;
    //frame.size.width -= 60;
    //self.tableView.frame = frame;
    
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (self.stream) {
        [self.stream stop];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [self.stream stop];
    self.stream = nil;
    self.tweets = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)emptyTweetDisplayQueue
{     
    @synchronized (self.tweetDisplayQueue) {
        NSArray *tweetDisplayQueueCopy = [self.tweetDisplayQueue copy];
        self.tweetDisplayQueue = [NSMutableArray array];
    
    
        NSMutableArray *indexPaths = [NSMutableArray array];
        for (int i = 0; i < [tweetDisplayQueueCopy count] && i < 10; i++)
        {
            [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
            [self.tweets insertObject:[tweetDisplayQueueCopy objectAtIndex:i] atIndex:i];
        }
        [self.tableView insertRowsAtIndexPaths:indexPaths
                              withRowAnimation:UITableViewRowAnimationTop];
        
        if ([self.tweets count] > MAX_TWEET_LOAD_LIMIT) {
            [self.tweets removeObjectAtIndex:MAX_TWEET_LOAD_LIMIT];
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:MAX_TWEET_LOAD_LIMIT inSection:0]]
                                  withRowAnimation:UITableViewRowAnimationBottom];
        }
        
    //    [self.tweetDisplayTimer invalidate];
    //    self.tweetDisplayTimer = nil;
        self.tweetDisplayTimer = YES;
    }

}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.tweets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        cell.detailTextLabel.numberOfLines = 0;
    }
    
    Tweet *tweet = [self.tweets objectAtIndex:indexPath.row];
    cell.textLabel.text = tweet.username;
    cell.detailTextLabel.text = tweet.text;
    //[cell.imageView setImageWithURL:[NSURL URLWithString:[user objectForKey:@"profile_image_url"]]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
        // Calculate how much room we need for the tweet
        Tweet* tweet = [self.tweets objectAtIndex:indexPath.row];
        return [tweet.text sizeWithFont:[UIFont systemFontOfSize:15]
                                        constrainedToSize:CGSizeMake(tableView.bounds.size.width - 20, INT_MAX)
                                            lineBreakMode:UILineBreakModeCharacterWrap].height + 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)streamReceivedMessage:(TwitterStream *)stream json:(id)json
{
    [self.tweetDisplayQueue insertObject:[Tweet fromJson:json] atIndex:0];
    if (self.tweetDisplayTimer) {
        /*self.tweetDisplayTimer = [NSTimer timerWithTimeInterval:.25
                                                         target:self
                                                       selector:@selector(emptyTweetDisplayQueue)
                                                       userInfo:nil
                                                        repeats:NO];
        */
        self.tweetDisplayTimer = NO;
        [self performSelector:@selector(emptyTweetDisplayQueue) withObject:nil afterDelay:.30];
    }
}

- (void)streamReceivedMessageJsonError:(TwitterStream *)stream errorMessage:(NSString *)errorMessage
{
    NSLog(@"JSON error");
}

- (void)streamDidTimeout:(TwitterStream *)stream
{
    NSLog(@"Stream timeout");
}

- (void)streamDidFailConnection:(TwitterStream *)stream
{
    NSLog(@"Stream fail connection");
    
    // Make an attempt to re-connect after a short delay
    [self.stream performSelector:@selector(start) withObject:nil afterDelay:10];
}

- (void)dealloc
{
    self.stream = nil;
    self.tweets = nil;
    
    [super dealloc];
}

@end

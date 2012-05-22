//
//  StreamTableViewController.m
//  Stwitter
//
//  Created by Andrew Long on 5/20/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import "StreamTableViewController.h"
#import "Tweet.h"

#import <SDWebImage/UIImageView+WebCache.h>

#define MAX_TWEET_LOAD_LIMIT 200

@interface StreamTableViewController ()

@property (nonatomic, retain) NSMutableArray* tweets;

- (void)streamReceivedMessage:(TwitterStream *)stream json:(id)json;
- (void)streamReceivedMessageJsonError:(TwitterStream *)stream errorMessage:(NSString *)errorMessage;
- (void)streamDidTimeout:(TwitterStream *)stream;
- (void)streamDidFailConnection:(TwitterStream *)stream;

@end

@implementation StreamTableViewController

@synthesize stream = _stream;
@synthesize tweets = _tweets;

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

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.stream stop];
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
    [self.tweets insertObject:[Tweet fromJson:json] atIndex:0];
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]]
                          withRowAnimation:UITableViewRowAnimationNone];
    
    if ([self.tweets count] > MAX_TWEET_LOAD_LIMIT) {
        [self.tweets removeObjectAtIndex:MAX_TWEET_LOAD_LIMIT];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:MAX_TWEET_LOAD_LIMIT inSection:0]]
                              withRowAnimation:UITableViewRowAnimationNone];
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

@end

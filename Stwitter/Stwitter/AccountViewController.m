//
//  AccountViewController.m
//  Stwitter
//
//  Created by Andrew Long on 5/18/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import "AccountViewController.h"

#import <Accounts/Accounts.h>
#import <Twitter/Twitter.h>

#import "DetailViewController.h"

@interface AccountViewController ()

@property (nonatomic, retain) ACAccountStore* accountStore;
@property (nonatomic, retain) NSArray* accounts;

@end

@implementation AccountViewController

@synthesize accountStore = _accountStore;
@synthesize accounts = _accounts;

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Fetch the twitter account. Display an AlertView if we cannot access
    // the twitter accounts or if there are no accounts available.
    self.accountStore = [[[ACAccountStore alloc] init] autorelease];
    ACAccountType *twitterAccountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [self.accountStore requestAccessToAccountsWithType:twitterAccountType 
                                 withCompletionHandler:^(BOOL accessable, NSError *error) {
         if (accessable && !error) {
             dispatch_sync(dispatch_get_main_queue(), ^{
                 self.accounts = [self.accountStore accountsWithAccountType:twitterAccountType];
                 
                 if (self.accounts.count) {
                     [self.tableView insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
                 } else {
                     UIAlertView *errorAlert = [[[UIAlertView alloc] initWithTitle:nil
                                                                           message:@"Please add a Twitter account in the Settings app"
                                                                          delegate:nil
                                                                 cancelButtonTitle:@"Ok"
                                                                 otherButtonTitles:nil] autorelease];
                     [errorAlert show];
                 }
             });
         } else {
             dispatch_sync(dispatch_get_main_queue(), ^{
                 NSString* message = [NSString stringWithFormat:@"Failed getting access to Twitter accounts: %@", [error localizedDescription]];
                 UIAlertView *errorAlert = [[[UIAlertView alloc] initWithTitle:nil
                                              message:message
                                             delegate:nil
                                    cancelButtonTitle:@"Ok"
                                    otherButtonTitles:nil] autorelease];
                 [errorAlert show];
             });
         }
     }];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.accounts.count > 0 ? 1 : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.accounts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];

    ACAccount* account = [self.accounts objectAtIndex:indexPath.row];
    cell.textLabel.text = account.accountDescription;
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        // Pass the account into the StreamViewController to
        // view the stream of tweets.
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDate *object = [self.accounts objectAtIndex:indexPath.row];
        [[segue destinationViewController] setDetailItem:object];
    }
}

- (void)dealloc {
    self.accountStore = nil;
    self.accounts = nil;
    
    [super dealloc];
}

@end

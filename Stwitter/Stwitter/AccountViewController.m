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

#import "SearchViewController.h"

@interface AccountViewController ()
{
    UITableView *_tableView;
}

@property (nonatomic, retain) ACAccountStore* accountStore;
@property (nonatomic, retain) NSArray* accounts;
@property (nonatomic, retain) UITableView *tableView;

@end

@implementation AccountViewController

@synthesize searchViewController = _searchViewController;

@synthesize accountStore = _accountStore;
@synthesize accounts = _accounts;
@synthesize tableView = _tableView;

- (id)init
{
    self = [super init];
    if (self) {
        CGRect fullScreen = [[UIScreen mainScreen] bounds];
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, fullScreen.size.width, fullScreen.size.height) style:UITableViewStylePlain];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        
        [self.view addSubview:self.tableView];
    }
    
    return self;
}

- (void)dealloc {
    self.accountStore = nil;
    self.accounts = nil;
    self.tableView = nil;
    
    [super dealloc];
}

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
    
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ItemTableViewCell"] autorelease];
    }

    ACAccount* account = [self.accounts objectAtIndex:indexPath.row];
    cell.textLabel.text = account.accountDescription;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.searchViewController.account = [self.accounts objectAtIndex:indexPath.row];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showSearch"]) {
        // Pass the account into the SearchViewController to
        // build search stream request
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        [[segue destinationViewController] setAccount:[self.accounts objectAtIndex:indexPath.row]];
    }
}

@end

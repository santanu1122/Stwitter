//
//  SearchViewController.m
//  Stwitter
//
//  Created by Andrew Long on 5/18/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import "SearchViewController.h"
#import "FilteredTwitterStream.h"

@class StreamTableViewController;

@interface SearchViewController ()

- (void)configureView;

@end

@implementation SearchViewController

@synthesize account = _account;
@synthesize searchBar = _searchBar;

#pragma mark - Managing the detail item

- (void)setAccount:(ACAccount *)newAccount
{
    if (_account != newAccount) {
        _account = newAccount;
        
        // Update the view.
        [self configureView];
    }
}

- (void)configureView
{
    // Update the user interface for the detail item.
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
    [self.searchBar becomeFirstResponder];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.searchBar = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self performSegueWithIdentifier:@"showStream" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showStream"]) {
        NSArray *keywords = [self.searchBar.text componentsSeparatedByString:@" "];
        FilteredTwitterStream *stream = [[[FilteredTwitterStream alloc] initWithKeywords:keywords 
                                                                                 account:self.account
                                                                                delegate:[segue destinationViewController]] autorelease];
        
        id destinationViewController = [segue destinationViewController];
        if ([destinationViewController respondsToSelector:@selector(setStream:)]) {
            [destinationViewController performSelector:@selector(setStream:) withObject:stream];
        }
    }
}

@end

//
//  TrendsTableViewController.m
//  Stwitter
//
//  Created by Andrew Long on 6/16/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import "TrendsTableViewController.h"
#import "Trend.h"

@interface TrendsTableViewController ()


@end

@implementation TrendsTableViewController

@synthesize trends = _trends;
@synthesize delegate=_delegate;

- (id)initWithDelegate:(id<TrendsTableViewDelegate>)delegate
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.delegate = delegate;
        self.title = @"Trends";

        UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"Accounts" 
                                                                       style:UIBarButtonSystemItemDone 
                                                                      target:self.delegate 
                                                                      action:@selector(slideMenu)];
        [self.navigationItem setLeftBarButtonItem:leftButton];
        [self.navigationItem setHidesBackButton:YES];
        [leftButton release];
        
        _trends = [NSArray array];
        self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
    return self;
}

- (void)setTrends:(NSArray *)trends
{
    if (_trends != trends) {
        _trends = trends;
        
        // Update the view.
        [self.tableView reloadData];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    if (self.navigationController.navigationBar.frame.origin.y > 0.0) {
        self.navigationController.navigationBar.frame = CGRectOffset(self.navigationController.navigationBar.frame, 0.0, -20.0);
    }    
}

- (void)viewDidAppear:(BOOL)animated
{
    if (self.view.superview.frame.origin.y > 44.0) {
        UIView *container = self.view.superview;
        container.frame = CGRectMake(container.frame.origin.x, container.frame.origin.y - 20.0, container.frame.size.width, container.frame.size.height + 20.0);
    }
    
    [super viewDidAppear:animated];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self viewDidAppear:NO];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.trends count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Top Trends";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    Trend *trend = [self.trends objectAtIndex:indexPath.row];
    cell.textLabel.text = trend.name;
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.delegate && [self.delegate respondsToSelector:@selector(tappedOnTrend:)]) {
        Trend *trend = [self.trends objectAtIndex:indexPath.row];
        [self.delegate tappedOnTrend:trend];
    }
}

@end

//
//  STXViewController.m
//  STXInstagramFeedView
//
//  Created by Rinat Enikeev on 11/16/2015.
//  Copyright (c) 2015 Rinat Enikeev. All rights reserved.
//

#import "STXFeedViewController.h"
#import <STXInstagramFeedView/STXDynamicTableView.h>

#import "UIImageView+Circling.h"

@interface STXFeedViewController () <STXFeedPhotoCellDelegate, STXLikesCellDelegate, STXCaptionCellDelegate, STXCommentCellDelegate, STXUserActionDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;

@property (strong, nonatomic) STXFeedTableViewDataSource *tableViewDataSource;
@property (strong, nonatomic) STXFeedTableViewDelegate *tableViewDelegate;

@end

@implementation STXFeedViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Feed", nil);
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    STXFeedTableViewDataSource *dataSource = [[STXFeedTableViewDataSource alloc] initWithController:self tableView:self.tableView];
    self.tableView.dataSource = dataSource;
    self.tableViewDataSource = dataSource;
    
    STXFeedTableViewDelegate *delegate = [[STXFeedTableViewDelegate alloc] initWithController:self];
    self.tableView.delegate = delegate;
    self.tableViewDelegate = delegate;
    
    self.activityIndicatorView = [self activityIndicatorViewOnView:self.view];
    
    [self loadFeed];
}

- (void)dealloc
{
    // To prevent crash when popping this from navigation controller
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // This will be notified when the Dynamic Type user setting changes (from the system Settings app)
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contentSizeCategoryChanged:) name:UIContentSizeCategoryDidChangeNotification object:nil];
    
    if ([self.tableViewDataSource.posts count] == 0) {
        [self.activityIndicatorView startAnimating];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIContentSizeCategoryDidChangeNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)contentSizeCategoryChanged:(NSNotification *)notification
{
    [self.tableView reloadData];
}

#pragma mark - STXFeedPhotoCellDelegate
- (void)feedCellWillBeDisplayed:(STXFeedPhotoCell *)cell
{
    
    cell.postImageView.image = cell.postItem.imageStd.image;
    if (cell.postItem.imageStd.image == nil) {
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSURL * imageUrl = [NSURL URLWithString:cell.postItem.imageStd.urlString];
            NSData* data = [NSData dataWithContentsOfURL:imageUrl];
            UIImage* postStdImage = [UIImage imageWithData:data];
            dispatch_async(dispatch_get_main_queue(), ^(void){
                cell.postItem.imageStd.image = postStdImage;
                cell.postImageView.image = postStdImage;
            });
        });
    }
    
    cell.profileImageView.image = cell.postItem.author.profilePicture;
    
    if (cell.postItem.author.profilePicture == nil) {
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSURL * imageUrl = [NSURL URLWithString:[cell.postItem.author profilePictureUrl]];
            NSData* data = [NSData dataWithContentsOfURL:imageUrl];
            UIImage* profilePicture = [UIImage imageWithData:data];
            
            dispatch_async(dispatch_get_main_queue(), ^(void){
                cell.postItem.author.profilePicture = profilePicture;
                // todo: add ProfilePlaceholder image
                [cell.profileImageView setCircledImageFrom:profilePicture placeholderImage:[UIImage imageNamed:@"ProfilePlaceholder"] borderWidth:2];
            });
        });
    }
}

#pragma mark - Feed

- (void)loadFeed
{
    
    InstaKit* kit = [[InstaKit alloc] initWithClientId:@"24fc1af302d3442c86e5e3c1e8708015" dbFileName:@"dbFile"];
    [[kit postService] renewMediaPopularWithProgress:nil success:^(NSArray *objects) {
        self.tableViewDataSource.posts = [objects copy];
        [self.tableView reloadData];
        [self.activityIndicatorView stopAnimating];
    } failure:^(NSError *error) {
        [self.activityIndicatorView stopAnimating];
        NSLog(@"%@", error);
    }];
    
}

#pragma mark - User Action Cell

- (void)userDidLike:(STXUserActionCell *)userActionCell
{
    
}

- (void)userDidUnlike:(STXUserActionCell *)userActionCell
{
    
}

- (void)userWillComment:(STXUserActionCell *)userActionCell
{
    
}

- (void)userWillShare:(STXUserActionCell *)userActionCell
{
    
}

@end

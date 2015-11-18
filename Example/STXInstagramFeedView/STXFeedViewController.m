//
//  STXViewController.m
//  STXInstagramFeedView
//
//  Created by Rinat Enikeev on 11/16/2015.
//  Copyright (c) 2015 Rinat Enikeev. All rights reserved.
//

#import "STXFeedViewController.h"
#import <STXInstagramFeedView/STXDynamicTableView.h>
#import <InstaKit/InstaKit.h>
#import <InstaModel/InstaModel.h>

@interface STXFeedViewController () <STXFeedPhotoCellDelegate, STXLikesCellDelegate, STXCaptionCellDelegate, STXCommentCellDelegate, STXUserActionDelegate>

@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;
@property (strong, nonatomic) STXFeedTableViewDataSource *tableViewDataSource;
@property (strong, nonatomic) STXFeedTableViewDelegate *tableViewDelegate;

@property (strong, nonatomic) InstaKit* instaKit;

@end

@implementation STXFeedViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.instaKit = [[InstaKit alloc] initWithClientId:@"24fc1af302d3442c86e5e3c1e8708015" dbFileName:@"dbFile"];
    
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
    
    // Initialize Refresh Control
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(loadFeed) forControlEvents:UIControlEventValueChanged];
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
 
    NSObject<InstaImage>* imgStd = cell.postItem.imageStd;
    if (imgStd.localPath == nil) {
        [[_instaKit blobService] renewImageBlobFor:imgStd withProgress:nil success:^(NSObject<InstaImage> *image) {
            [self updateStdImageInPost:cell];
        } failure:^(NSError *error) {
            NSLog(@"%@", error.localizedDescription);
        }];
    } else {
        [self updateStdImageInPost:cell];
    }
    
    NSObject<InstaUser>* author = cell.postItem.author;
    if (author.profilePictureLocalPath == nil) {
        [[_instaKit blobService] renewProfileImageBlobFor:author withProgress:nil success:^(NSObject<InstaUser> *user) {
            [self updateProfilePictureIn:cell];
        } failure:^(NSError *error) {
            NSLog(@"%@", error.localizedDescription);
        }];

    } else {
        [self updateProfilePictureIn:cell];
    }
}

/**
 *  @brief  Assume thatcell.postItem.imageStd.localPath is not null.
 */
-(void)updateStdImageInPost:(STXFeedPhotoCell *)cell {
    NSObject<InstaImage>* imgStd = cell.postItem.imageStd;
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage* postStdImage = [UIImage imageWithContentsOfFile:imgStd.localPath];
        dispatch_async(dispatch_get_main_queue(), ^(void){
            cell.postImageView.image = postStdImage;
        });
    });
}

/**
 *  @brief  Assume that cell.postItem.author.profilePictureLocalPath is not null.
 */
-(void)updateProfilePictureIn:(STXFeedPhotoCell *)cell {
    NSObject<InstaUser>* author = cell.postItem.author;
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage* authorImage = [UIImage imageWithContentsOfFile:author.profilePictureLocalPath];
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [cell.profileImageView setCircledImageFrom:authorImage placeholderImage:[UIImage imageNamed:@"ProfilePlaceholder"] borderWidth:2];
        });
    });
}


#pragma mark - Feed

- (void)loadFeed
{
    
    [[_instaKit postService] renewMediaPopularWithProgress:nil success:^(NSArray *objects) {
        self.tableViewDataSource.posts = [objects copy];
        [self.tableView reloadData];
        [self.activityIndicatorView stopAnimating];
        [self.refreshControl endRefreshing];
    } failure:^(NSError *error) {
        [self.activityIndicatorView stopAnimating];
        [self.refreshControl endRefreshing];
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

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
#import <Reachability/Reachability.h>
#import <TSMessages/TSMessage.h>
#import "UIViewController+InformUser.h"

NSString *const kInstagramBaseUrl = @"https://api.instagram.com/v1/";

@interface STXFeedViewController () <STXFeedPhotoCellDelegate, STXLikesCellDelegate, STXCaptionCellDelegate, STXCommentCellDelegate, STXUserActionDelegate>

// views
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;

// services
@property (strong, nonatomic) InstaKit* instaKit;

// instagram-like feed support
@property (strong, nonatomic) STXFeedTableViewDataSource *tableViewDataSource;
@property (strong, nonatomic) STXFeedTableViewDelegate *tableViewDelegate;

// configurable
@property (strong, nonatomic) NSNumber* fetchedPostsLimit;

@end

@implementation STXFeedViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.instaKit = [[InstaKit alloc] initWithClientId:@"24fc1af302d3442c86e5e3c1e8708015" dbFileName:@"dbFile"];
    self.fetchedPostsLimit = @10;
    
    self.title = NSLocalizedString(@"Feed", nil);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // 1. Delegate UITableView datasource and delegate to STX.
    STXFeedTableViewDataSource *dataSource = [[STXFeedTableViewDataSource alloc] initWithController:self tableView:self.tableView];
    self.tableView.dataSource = dataSource;
    self.tableViewDataSource = dataSource;
    
    STXFeedTableViewDelegate *delegate = [[STXFeedTableViewDelegate alloc] initWithController:self];
    self.tableView.delegate = delegate;
    self.tableViewDelegate = delegate;
    
    // 2. Centered in table view screen activity indicator
    self.activityIndicatorView = [self activityIndicatorViewOnView:self.view];
    
    // 3. Refresh Control
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(renewFeed) forControlEvents:UIControlEventValueChanged];
    
    // 4. Renew/fetch feed based on reachability (internet and instagram) and inform user appropriately
    Reachability* reachability = [Reachability reachabilityForInternetConnection];
    
    if ([Reachability reachabilityForInternetConnection]) {
        
        if ([Reachability reachabilityWithHostName:kInstagramBaseUrl]) {
            [self renewFeed];
        } else {
            [self informUserWithErrorMessage:NSLocalizedString(@"Instagram servers are not reachable. ", @"Instagram servers are not reachable. ") withTitle:NSLocalizedString(@"Error", @"Error")];
            
            reachability.reachableBlock = ^(Reachability * reachability)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self informUserWithSuccessMessage:NSLocalizedString(@"Instagram servers are now alive!", @"Instagram servers are now alive!") withTitle:NSLocalizedString(@"Great!", @"Great!")];
                });
            };
            
            [self fetchFeed:self.fetchedPostsLimit.integerValue];
        }
        
    } else {
        [self informUserWithWarnMessage:NSLocalizedString(@"Internet connection unavaliable. ", @"Internet connection unavaliable. ") withTitle:NSLocalizedString(@"Warning", @"Warning")];
        
        reachability.reachableBlock = ^(Reachability * reachability)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self informUserWithSuccessMessage:NSLocalizedString(@"Internet connection now alive!", @"Internet connection now alive!") withTitle:NSLocalizedString(@"Great!", @"Great!")];
            });
        };
        
        [self fetchFeed:self.fetchedPostsLimit.integerValue];
    }

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


#pragma mark - Data

/**
 *  @brief  Fetches posts from persistence.
 *
 *  @param limit maximum number of posts to fetch.
 *
 *  @return number of posts fetched.
 */
-(NSUInteger)fetchFeed:(NSUInteger)limit {
    
}

/**
 *  @brief  Downloads last popular posts from Instagram.
 */
- (void)renewFeed
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

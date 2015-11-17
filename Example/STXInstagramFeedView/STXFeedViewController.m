//
//  STXViewController.m
//  STXInstagramFeedView
//
//  Created by Rinat Enikeev on 11/16/2015.
//  Copyright (c) 2015 Rinat Enikeev. All rights reserved.
//

#import "STXFeedViewController.h"
#import <STXInstagramFeedView/STXDynamicTableView.h>

#import "STXPost.h"
#import "UIImageView+Circling.h"

#define PHOTO_CELL_ROW 0

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
    if (cell.postItem.standardImage == nil) {
        
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSURL * imageUrl = [cell.postItem standardImageURL];
            NSData* data = [NSData dataWithContentsOfURL:imageUrl];
            UIImage* postStdImage = [UIImage imageWithData:data];
            dispatch_async(dispatch_get_main_queue(), ^(void){
                cell.postItem.standardImage = postStdImage;
                cell.postImageView.image = postStdImage;
            });
        });
    }
    
    if (cell.postItem.user.profilePicture == nil) {
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSURL * imageUrl = [cell.postItem.user profilePictureURL];
            NSData* data = [NSData dataWithContentsOfURL:imageUrl];
            UIImage* profilePicture = [UIImage imageWithData:data];
            
            dispatch_async(dispatch_get_main_queue(), ^(void){
                cell.postItem.user.profilePicture = profilePicture;
                // todo: add ProfilePlaceholder image
                [cell.profileImageView setCircledImageFrom:profilePicture placeholderImage:[UIImage imageNamed:@"ProfilePlaceholder"] borderWidth:2];
            });
        });
    }
}

#pragma mark - Feed

- (void)loadFeed
{
    NSString *feedPath = [[NSBundle mainBundle] pathForResource:@"instagram_media_popular" ofType:@"json"];
    
    NSError *error;
    NSData *jsonData = [NSData dataWithContentsOfFile:feedPath options:NSDataReadingMappedIfSafe error:&error];
    if (jsonData) {
        NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
        if (error) {
            NSLog(@"%@", error);
        }
        
        NSDictionary *instagramPopularMediaDictionary = jsonObject;
        if (instagramPopularMediaDictionary) {
            NSArray *mediaDataArray = [instagramPopularMediaDictionary valueForKey:@"data"];
            
            NSMutableArray *posts = [NSMutableArray array];
            for (NSDictionary *mediaDictionary in mediaDataArray) {
                STXPost *post = [[STXPost alloc] initWithDictionary:mediaDictionary];
                [posts addObject:post];
            }
            
            self.tableViewDataSource.posts = [posts copy];
            
            [self.tableView reloadData];
            
        } else {
            if (error) {
                NSLog(@"%@", error);
            }
        }
    } else {
        if (error) {
            NSLog(@"%@", error);
        }
    }
    
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

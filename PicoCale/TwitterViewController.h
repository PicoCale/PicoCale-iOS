//
//  TwitterViewController.h
//  manantha_Universal_Multimedia
//
//  Created by Manishgant on 7/14/15.
//  Copyright (c) 2015 Manishgant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <Accounts/Accounts.h>
#import <Social/Social.h>

@interface TwitterViewController : UIViewController
<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tweetTableView;
@property (strong, nonatomic) NSArray *dataSource;

@property (weak,nonatomic) NSURL *imageURL;
@property (weak, nonatomic) IBOutlet UINavigationItem *twitterNavBar;

@end

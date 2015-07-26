//
//  TweetDisplayView.h
//  manantha_Universal_Multimedia
//
//  Created by Manishgant on 7/15/15.
//  Copyright (c) 2015 Manishgant. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <Accounts/Accounts.h>
#import <Social/Social.h>

@interface TwitterDisplayView : UIViewController<UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *displayTweetWebView;

@property (weak,nonatomic) NSURL *imageURL;
@end
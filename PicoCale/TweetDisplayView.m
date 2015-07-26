//
//  TweetDisplayView.m
//  manantha_Universal_Multimedia
//
//  Created by Manishgant on 7/15/15.
//  Copyright (c) 2015 Manishgant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TweetDisplayView.h"

@interface TwitterDisplayView()

@end

@implementation TwitterDisplayView

/*
 Load URL in webview when the user has selected 
 the tweet. The URL to be displayed is passed using prepare
 for segue in TwitterView Controller
 */

-(void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    NSURLRequest* request = [NSURLRequest requestWithURL:self->_imageURL cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:30];
    
    self.displayTweetWebView.scalesPageToFit =YES;
    self.displayTweetWebView.frame = self.view.bounds;
    [self->_displayTweetWebView loadRequest:request];
    
}



@end
//
//  FlickrViewAppDelegate.h
//  PicoCale
//
//  Created by Manishgant on 7/28/15.
//  Copyright (c) 2015 Manishgant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ObjectiveFlickr.h"

extern NSString *SnapAndRunShouldUpdateAuthInfoNotification;

@interface FlickrViewAppDelegate : NSObject <UIApplicationDelegate, OFFlickrAPIRequestDelegate>
{
    UINavigationController *viewController;
    UIWindow *window;
    
    UIActivityIndicatorView *activityIndicator;
    UIView *progressView;
    UIButton *cancelButton;
    UILabel *progressDescription;
    
    OFFlickrAPIContext *flickrContext;
    OFFlickrAPIRequest *flickrRequest;
    NSString *flickrUserName;
}

+ (SnapAndRunAppDelegate *)sharedDelegate;
- (void)setAndStoreFlickrAuthToken:(NSString *)inAuthToken secret:(NSString *)inSecret;

- (IBAction)cancelAction;

@property (nonatomic, retain) IBOutlet UINavigationController *viewController;
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) IBOutlet UIView *progressView;
@property (nonatomic, retain) IBOutlet UIButton *cancelButton;
@property (nonatomic, retain) IBOutlet UILabel *progressDescription;

@property (nonatomic, readonly) OFFlickrAPIContext *flickrContext;
@property (nonatomic, retain) NSString *flickrUserName;
@end

extern NSString *SRCallbackURLBaseString;

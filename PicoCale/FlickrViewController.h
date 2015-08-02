//
//  FullViewController.h
//  manantha_Universal_Multimedia
//
//  Created by Manishgant on 7/5/15.
//  Copyright (c) 2015 Manishgant. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "FlickrCollectionViewController.h"

@import CoreLocation;
/*
 Initialize the elements required to display the selected image
 from the TableView in a separate View.
 */

@interface FlickrViewController : UIViewController<CLLocationManagerDelegate,OFFlickrAPIRequestDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *fullImageView;

@property (weak, nonatomic) IBOutlet UINavigationBar *fullImageTopBar;

@property (weak, nonatomic) IBOutlet UINavigationItem *fullImageLabel;

@property (nonatomic, strong) UIImage *displayImage;

@property (nonatomic, strong) ALAsset *assetInfo;

@property (nonatomic, strong) NSString *locationString;

@property (nonatomic,strong) CLLocation *location;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *shareTwitter;

@property (nonatomic, strong) CLLocation *selectedLocation;

@property (nonatomic, strong) OFFlickrAPIRequest *flickrRequest;

@property(nonatomic) long long photoID;


@end

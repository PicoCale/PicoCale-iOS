//
//  FlickrViewController.h
//  PicoCale
//
//  Created by Manishgant on 7/27/15.
//  Copyright (c) 2015 Manishgant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MediaPlayer/MediaPlayer.h>
#import "Photo.h"
#import "SettingsController.h"
#import <ObjectiveFlickr.h>


@import CoreLocation;


@interface FlickrViewController : UIViewController<UIImagePickerControllerDelegate, CLLocationManagerDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,OFFlickrAPIRequestDelegate,NSURLSessionDownloadDelegate,UIApplicationDelegate>

{
    OFFlickrAPIRequest *flickrRequest;
    
    UIImagePickerController *imagePicker;
    
    UILabel *authorizeDescriptionLabel;
    UILabel *snapPictureDescriptionLabel;
    UIButton *authorizeButton;
    UIButton *snapPictureButton;
}
- (IBAction)authorizeAction;



@end


//
//  SnapAndRunViewController.h
//  PicoCale
//
//  Created by Manishgant on 7/27/15.
//  Copyright (c) 2015 Manishgant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ObjectiveFlickr.h"

@interface SnapAndRunViewController : UIViewController <OFFlickrAPIRequestDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    OFFlickrAPIRequest *flickrRequest;
    
    UIImagePickerController *imagePicker;
    
    UILabel *authorizeDescriptionLabel;
    UILabel *snapPictureDescriptionLabel;
    UIButton *authorizeButton;
    UIButton *snapPictureButton;
}

@property (nonatomic, retain) IBOutlet UILabel *authorizeDescriptionLabel;
@property (nonatomic, retain) IBOutlet UILabel *snapPictureDescriptionLabel;
@property (nonatomic, retain) IBOutlet UIButton *snapPictureButton;
@property (nonatomic, retain) IBOutlet UIButton *authorizeButton;

@property (nonatomic, retain) OFFlickrAPIRequest *flickrRequest;
@property (nonatomic, retain) UIImagePickerController *imagePicker;
@end
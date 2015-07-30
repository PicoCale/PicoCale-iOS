//
//  ImagesViewController.h
//  manantha_Universal_Multimedia
//
//  Created by Manishgant on 7/4/15.
//  Copyright (c) 2015 Manishgant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MediaPlayer/MediaPlayer.h>

/*
 Declare elements to generate UITableView and
 make the view controller as UIImagePickerConcontroller delegate
 */

@interface ImagesViewController : UITableViewController<UIImagePickerControllerDelegate>

@property (nonatomic, strong) NSArray *photos;

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, strong) ALAsset *assetInfo;

+ (ALAssetsLibrary *)defaultAssetsLibrary;

@end




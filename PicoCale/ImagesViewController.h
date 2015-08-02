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
#import "Photo.h"
#import "SettingsController.h"
#import <Photos/Photos.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>


@import MapKit;
@import CoreLocation;
/*
 Declare elements to generate UITableView and
 make the view controller as UIImagePickerConcontroller delegate
 */

@interface ImagesViewController : UICollectionViewController<UIImagePickerControllerDelegate, CLLocationManagerDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSMutableArray *photos;

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, strong) ALAsset *assetInfo;

@property (weak, nonatomic) IBOutlet UINavigationItem *titleBarForImages;

@property (nonatomic, weak) NSMutableArray *photoInfo;

@property (nonatomic, strong) SettingsController *sc;

@property (nonatomic, strong) NSMutableString *radius_C;

@property (nonatomic, strong) NSString *locationString;

@property (nonatomic, strong) CLLocation *selectedLocation;



+(NSMutableString *)getRadius_C;

+(NSString *)getnoPhotos;

+(void)setRadius_C:(NSMutableString *)value;

+ (ALAssetsLibrary *)defaultAssetsLibrary;

@end






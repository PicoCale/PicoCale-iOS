//
//  LocationListCollectionViewController.h
//  PicoCale
//
//  Created by Manishgant on 7/30/15.
//  Copyright (c) 2015 Manishgant. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MediaPlayer/MediaPlayer.h>
#import "Photo.h"
#import "SettingsController.h"
#import "Location.h"


@import MapKit;
@import CoreLocation;
/*
 Declare elements to generate UITableView and
 make the view controller as UIImagePickerConcontroller delegate
 */

@interface LocationListCollectionViewController : UICollectionViewController<UIImagePickerControllerDelegate, CLLocationManagerDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSMutableArray *photos;

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, strong) ALAsset *assetInfo;

@property (weak, nonatomic) IBOutlet UINavigationItem *titleBarForImages;

@property (nonatomic, weak) NSMutableArray *photoInfo;

@property (nonatomic, strong) SettingsController *sc;

@property (nonatomic, strong) NSMutableString *radius_C;

@property (nonatomic, weak) NSString *locationString;

@property (nonatomic, strong) Location *passLocation1;

+(NSMutableString *)getRadius_C;

+(NSString *)getnoPhotos;

+(void)setRadius_C:(NSMutableString *)value;

+ (ALAssetsLibrary *)defaultAssetsLibrary;

@end


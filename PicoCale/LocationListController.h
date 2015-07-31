//
//  LocationListController.h
//  PicoCale
//
//  Created by Manishgant on 7/29/15.
//  Copyright (c) 2015 Manishgant. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MediaPlayer/MediaPlayer.h>
#import "SettingsController.h"
#import "Location.h"

@import CoreLocation;

/*
 Declare elements to generate UITableView and
 make the view controller as UIImagePickerConcontroller delegate
 */

@interface LocationListController : UITableViewController<UIImagePickerControllerDelegate,CLLocationManagerDelegate>

@property (nonatomic, strong) NSArray *locationList;

@property (nonatomic, strong) NSArray *photos;

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, strong) ALAsset *assetInfo;

@property (nonatomic, strong) CLLocation *passLocation;

@property (nonatomic, strong) NSString *locationString;



+ (ALAssetsLibrary *)defaultAssetsLibrary;

@property (nonatomic, strong) SettingsController *sc;

@property (nonatomic, strong) NSMutableString *radius_C;

+(NSMutableString *)getRadius_C;

+(NSString *)getnoPhotos;


+(void)setRadius_C:(NSMutableString *)value;

@end

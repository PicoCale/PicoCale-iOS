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
#import "RXFlickr.h"


@import CoreLocation;


@interface FlickrViewController : UICollectionViewController<UIImagePickerControllerDelegate, CLLocationManagerDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,OFFlickrAPIRequestDelegate,RXFlickrDelegate,NSURLSessionDownloadDelegate,UIApplicationDelegate>

@property (nonatomic, strong) NSMutableArray *photos;

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, strong) ALAsset *assetInfo;

@property (weak, nonatomic) IBOutlet UINavigationItem *titleBarForImages;

@property (nonatomic, weak) NSMutableArray *photoInfo;

@property (nonatomic, strong) SettingsController *sc;

@property (nonatomic, strong) NSMutableString *radius_C;

@property (nonatomic) OFFlickrAPIContext *flickrContext;
@property (nonatomic) OFFlickrAPIRequest *flickrRequest;
@property (nonatomic) NSString *nextPhotoTitle;
@property (nonatomic) NSURLSession *urlSession;
@property (nonatomic) NSURLSessionDownloadTask *imageDownloadTask;
@property (weak, nonatomic) NSTimer *fetchTimer;

+(NSMutableString *)getRadius_C;

+(NSString *)getnoPhotos;

+(void)setRadius_C:(NSMutableString *)value;

+ (ALAssetsLibrary *)defaultAssetsLibrary;


@end


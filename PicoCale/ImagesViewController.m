//
//  ImagesViewController.m
//  manantha_Universal_Multimedia
//
//  Created by Manishgant on 7/4/15.
//  Copyright (c) 2015 Manishgant. All rights reserved.
//

#import "ImagesViewController.h"
#import "FullViewController.h"
#import "Photo.h"
#import "Math.h"


@interface ImagesViewController ()

{
    CLLocationManager *locationManager;
    
    CLLocation *currentLocation;
}


@end

@implementation ImagesViewController

/*
 Reload data when new photos are added
 */
@synthesize photos = _photos;

-(void)setPhotos:(NSMutableArray *)photos {
    if (_photos != photos) {
        _photos = photos;
        [self.collectionView reloadData];
    }
}

/*
 This ALAssets library is used to avoid
 reallocating memory everytime the view loads
 */
+ (ALAssetsLibrary *)defaultAssetsLibrary {
    static dispatch_once_t pred = 0;
    static ALAssetsLibrary *library = nil;
    dispatch_once(&pred, ^{
        library = [[ALAssetsLibrary alloc] init];
    });
    return library;
}

/*
 When the view is about to appear, enumerate through the
 camera roll and obtain all the media files as Assets
 
 Use blocks to load chunks of data asynchronously. This
 will avoid slowing down the device when loading large number of
 assets
 */

- (void)viewWillAppear:(BOOL)animated
{
    double maxLatitude,minLatitude;
    double maxLongitude,minLongitude;
    
    double radius = 0.1*0.8;
    
    [super viewWillAppear:animated];
    // collect the photos
    
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"myGridImage"];
    [self->locationManager startUpdatingLocation];
    
    NSMutableArray *collector = [[NSMutableArray alloc] initWithCapacity:0];
    ALAssetsLibrary *al = [ImagesViewController defaultAssetsLibrary];
    
    
    maxLatitude = [self getMaxLatitude:self->locationManager.location radius:radius];
    
    maxLongitude = [self getMaxLongitude:self->locationManager.location radius:radius];
    
    
    minLatitude = [self getMinLatitude:self->locationManager.location radius:radius];
    
    
    minLongitude = [self getMinLongitude:self->locationManager.location radius:radius];
    
    NSLog(@"%f %f %f %f",minLatitude,minLongitude,maxLatitude,maxLongitude);
    
    
    [al enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                      usingBlock:^(ALAssetsGroup *group, BOOL *stop)
     {
         [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop)
          {
              if (asset) {
                  
                  ALAssetRepresentation *representation = [asset defaultRepresentation];
                  CLLocation *location = [asset valueForProperty:ALAssetPropertyLocation];
                  
                  double image_Latitude = location.coordinate.latitude;
                  double image_Longitude= location.coordinate.longitude;

                  
                  if ((image_Latitude > minLatitude) && (image_Latitude < maxLatitude) ) {
                      
                      if((image_Longitude < minLongitude) && (image_Longitude > maxLongitude)) {
                          [collector addObject:asset];
                          NSLog(@"Image %@ Latitude = %f Longitude = %f",[representation filename],image_Latitude,image_Longitude);
                      }
                  }
                  
              }
          }];
         
         self.photos = collector;
         
         
     }
                    failureBlock:^(NSError *error) { NSLog(@"Error retrieving photos");}
     ];
    
}


/*
 Get the number of rows generated in Table View
 */



- (NSInteger) collectionView:(UICollectionView *)collectionView
      numberOfItemsInSection:(NSInteger)section
{
    return self.photos.count;
}


/*
 Generate the Table View  and insert each row with the Image thumbnail
 and associated filename.
 */
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"myGridImage";
    
    
    UICollectionViewCell *imageCell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSLog(@"the cell is %@", imageCell);
    
    // Configure each cell in the
    ALAsset *asset = [self.photos objectAtIndex:indexPath.row];
        
    //NSLog(@"Image URL: %@", [url absoluteString]);
    
    imageCell.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageWithCGImage:[asset thumbnail]]];
    //collectionImageView.image = [UIImage imageWithCGImage:[asset thumbnail]];

    return imageCell;
}

/*
 The below method is a listener to listen for row select event inside the Table View
 On selecting the row, the view will segue to an UIImageView to display the image
 or a MPMoviePlayerController to play the video
 */

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    self->_assetInfo = [self.photos objectAtIndex:indexPath.row];
    
    ALAssetRepresentation *imageRep = [self->_assetInfo defaultRepresentation];
    
    self->_image = [UIImage imageWithCGImage:[imageRep fullScreenImage] scale:[imageRep scale] orientation: UIImageOrientationUp];
    NSString *tempString = [_assetInfo.defaultRepresentation filename];
    
    //Check if the media is a photo or a video
    
    if (!(([tempString containsString:(@".MOV")]) || ([tempString containsString:(@".MP4")])||
          ([tempString containsString:(@".mov")]) || ([tempString containsString:(@".mp4")]))) {
        
        [self performSegueWithIdentifier:@"viewFullScreenImage" sender:self.image];
        
    } else {
        
        [self playVideo:imageRep];
        
    }
    
}

/*
 Encapsulate MPMoviePlayerController into a separate method for modularity
 This method is referred from the course example uploaded in Blackboard
 */


-(void) playVideo:(ALAssetRepresentation *)defaultRep {
    
    MPMoviePlayerViewController *theMovieController=[[MPMoviePlayerViewController alloc] initWithContentURL:defaultRep.url] ;
    
    /* Size movie view to fit parent view. */
    //CGRect viewInsetRect = CGRectInset ([self.view bounds],0.0,44.0 );
    
    [theMovieController.view setFrame:CGRectMake(0, 44, 320, 270)];
    
    [theMovieController.view setTransform:CGAffineTransformMakeRotation(M_PI_2)];
    
    /* To present a movie in your application, incorporate the view contained
     in a movie player’s view property into your application’s view hierarchy.
     Be sure to size the frame correctly. */
    
    [self.view addSubview: theMovieController.view];
    //
    
    // Create a new movie player object.
    MPMoviePlayerController *mp = [theMovieController moviePlayer];
    
    [mp prepareToPlay];
    mp.controlStyle = MPMovieControlStyleEmbedded;
    //[mp setControlStyle:2];
    //[mp setScalingMode:MPMovieScalingModeFill];
    [mp setFullscreen:YES animated:YES];
    
    // Register for the playback finished notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinishedCallback:)
     
                                                 name:MPMoviePlayerPlaybackDidFinishNotification object:mp];
    
    // Register for the playback interruption notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinishedCallback:)
     
                                                 name:MPMoviePlayerWillExitFullscreenNotification object:mp];
    
    [mp play];
    
}

/*
 Listen for Movie Playback finish and interruptions and handle those events accordingly
 Stop the video playback and remove Movie Player from the view
 */

- (void)playbackFinishedCallback:(NSNotification *)notification {
    
    MPMoviePlayerController *mpController = [notification object];
    MPMoviePlayerViewController *mpViewController = [notification object];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:mpController];
    
    [mpController stop];
    
    mpController = nil;
    
    [mpViewController.view removeFromSuperview];
}

/*
 In order to show the images selected in a separate imageview, use segue and
 prepare the segue to send image data of the selected row to the destination
 UIViewController
 */

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    FullViewController *fVC = [segue destinationViewController];
    
    fVC.displayImage = self->_image;
    
}

/*
 Set Tableview dimensions upon view load
 */

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.collectionView.contentInset = UIEdgeInsetsMake(20.0f, 0.0f, 0.0f, 0.0f);
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"myGridImage"];

    self->locationManager = [[CLLocationManager alloc] init];
    self->locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self->locationManager.delegate = self;
    [self-> locationManager requestAlwaysAuthorization];
    [self->locationManager startUpdatingLocation];
    
    //Get Curent Location coordinates from current MapView
    self->currentLocation = [self deviceLocation] ;
    
    NSLog(@"Curent Location : Latitude : %f Longitude : %f", self->currentLocation.coordinate.latitude, self->currentLocation.coordinate.longitude);
    
}

- (CLLocation *)deviceLocation {
    return self->locationManager.location;
}

- (double)getMaxLatitude: (CLLocation *) location radius:(double)radius {
    double correctionFactor;
    
    double latitude,longitude;
    
    latitude = location.coordinate.latitude;
    longitude = location.coordinate.longitude;
    
    double earth_radius = 3960;
    
    double radians_to_degrees = 180.0/M_PI;
    
    correctionFactor = ((radius/earth_radius) *radians_to_degrees);
    
    double maxLatitude = latitude + correctionFactor;
    
    return maxLatitude;
}

- (double)getMinLatitude: (CLLocation *) location radius:(double)radius {
    double correctionFactor;
    
    double latitude,longitude;
    
    latitude = location.coordinate.latitude;
    longitude = location.coordinate.longitude;
    
    double earth_radius = 3960;
    
    double radians_to_degrees = 180.0/M_PI;
    
    correctionFactor = ((radius/earth_radius) *radians_to_degrees);
    
    double minLatitude = latitude - correctionFactor;
    
    return minLatitude;
}



- (double)getMaxLongitude: (CLLocation *) location radius:(double)radius {
    double correctionFactor;
    
    double latitude,longitude;
    
    latitude = location.coordinate.latitude;
    longitude = location.coordinate.longitude;
    
    double earth_radius = 3960;
    
    double degrees_to_radians = 3.14/180.0;
    double radians_to_degrees = 180.0/M_PI;
    
    double r = earth_radius*cos(latitude*degrees_to_radians);
    
    correctionFactor = ((radius/r) *radians_to_degrees);
    
    double maxLongitude = longitude - correctionFactor;
    
    return maxLongitude ;
}


- (double)getMinLongitude: (CLLocation *) location radius:(double)radius {
    double correctionFactor;
    
    double latitude,longitude;
    
    latitude = location.coordinate.latitude;
    longitude = location.coordinate.longitude;
    
    double earth_radius = 3960;
    
    double degrees_to_radians = 3.14/180.0;
    double radians_to_degrees = 180.0/M_PI;
    
    double r = earth_radius*cos(latitude*degrees_to_radians);
    
    correctionFactor = ((radius/r) *radians_to_degrees);
    
    double minLongitude = longitude + correctionFactor;
    
    return minLongitude ;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

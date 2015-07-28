//
//  FlickrViewController.m
//  PicoCale
//
//  Created by Manishgant on 7/27/15.
//  Copyright (c) 2015 Manishgant. All rights reserved.
//

//
//  ImagesViewController.m
//  manantha_Universal_Multimedia
//
//  Created by Manishgant on 7/4/15.
//  Copyright (c) 2015 Manishgant. All rights reserved.
//

#import "FlickrViewController.h"
#import "FullViewController.h"
#import <OFUtilities.h>

static NSString* kConsumerKey = @"4bd53aa5f4c2ff55b7fdaa6a067ab915";
static NSString *kOAuthAuth = @"OAuth";
static NSString* kConsumerSecret = @"156d6d81cb6efc97";
static NSString* kCallbackURLBaseString = @"picocale://callback";

@interface FlickrViewController ()


{
    CLLocationManager *locationManager;
    
    CLLocation *currentLocation;
    
     NSString *flickrUserName;
    
    
}


@end

@implementation FlickrViewController


static NSMutableString *radius_CC = (NSMutableString *) @"5";
static NSMutableString *noPhotosAlerts = (NSMutableString *) @"10";


+(NSMutableString *)getRadius_C{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableString *geoRadius = [defaults objectForKey:@"geoRadius"];
    if (geoRadius != nil){
        return geoRadius;
    } else {
        return radius_CC;
    }
}

+(NSString *)getnoPhotos{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *noForAlert = [defaults objectForKey:@"noPhotosAlerts"];
    if (noForAlert != nil){
        return noForAlert;
    } else {
        return noPhotosAlerts;
    }
}


+(void)setRadius_C:(NSMutableString *)value {
    
    radius_CC = value;
}

+(void)setnoPhotos:(NSMutableString *)value {
    
    noPhotosAlerts = value;
}


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
    [super viewWillAppear:animated];
    
    [[self titleBarForImages] setTitle:[NSString stringWithFormat:@"Photos within %@ mile radius",[FlickrViewController getRadius_C]]];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"myGridImage"];
    
    [self->locationManager startUpdatingLocation];
    
    [self disPlayLocationBasedPictures:self->locationManager.location];
    
    [self.collectionView reloadData];
    
    
}

-(void) disPlayLocationBasedPictures:(CLLocation *)location {
        //NSLog(@"%f %f %f %f",minLatitude,minLongitude,maxLatitude,maxLongitude);
    self.flickrContext = [[OFFlickrAPIContext alloc] initWithAPIKey:kConsumerKey sharedSecret:kConsumerSecret];
    
    OFFlickrAPIRequest *request = [[OFFlickrAPIRequest alloc] initWithAPIContext:self.flickrContext];
    
    // set the delegate, here we assume it's the controller that's creating the request object
    
    request.sessionInfo = kOAuthAuth;
    [request setDelegate:self];
    
    [request fetchOAuthRequestTokenWithCallbackURL:[NSURL URLWithString:kCallbackURLBaseString]];
}

- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didObtainOAuthRequestToken:(NSString *)inRequestToken secret:(NSString *)inSecret;
{
    self.flickrContext.OAuthToken = inRequestToken;
    self.flickrContext.OAuthTokenSecret = inSecret;
    
    NSURL *authURL = [self.flickrContext userAuthorizationURLWithRequestToken:inRequestToken requestedPermission:OFFlickrWritePermission];
    NSLog(@"Auth URL: %@", [authURL absoluteString]);
    [[UIApplication sharedApplication] openURL:authURL];
    
}

- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didFailWithError:(NSError *)inError
{
    NSLog(@"%s, error: %@", __PRETTY_FUNCTION__, inError);

}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if ([self flickrRequest].sessionInfo) {
        // already running some other request
        NSLog(@"Already running some other request");
    }
    else {
        NSString *token = nil;
        NSString *verifier = nil;
        BOOL result = OFExtractOAuthCallback(url, [NSURL URLWithString:kCallbackURLBaseString], &token, &verifier);
        
        if (!result) {
            NSLog(@"Cannot obtain token/secret from URL: %@", [url absoluteString]);
            return NO;
        }
        
        [self flickrRequest].sessionInfo = kOAuthAuth;
        [self.flickrRequest fetchOAuthAccessTokenWithRequestToken:token verifier:verifier];
            
    }
    
    return YES;
}

- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didObtainOAuthAccessToken:(NSString *)inAccessToken secret:(NSString *)inSecret userFullName:(NSString *)inFullName userName:(NSString *)inUserName userNSID:(NSString *)inNSID
{
    [self setAndStoreFlickrAuthToken:inAccessToken secret:inSecret];
    self->flickrUserName = inUserName;
    
    [self flickrRequest].sessionInfo = nil;
}

- (void)setAndStoreFlickrAuthToken:(NSString *)inAuthToken secret:(NSString *)inSecret
{
    if (![inAuthToken length] || ![inSecret length]) {
        self.flickrContext.OAuthToken = nil;
        self.flickrContext.OAuthTokenSecret = nil;
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kConsumerKey];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kConsumerSecret];
        
    }
    else {
        self.flickrContext.OAuthToken = inAuthToken;
        self.flickrContext.OAuthTokenSecret = inSecret;
        [[NSUserDefaults standardUserDefaults] setObject:inAuthToken forKey:kConsumerKey];
        [[NSUserDefaults standardUserDefaults] setObject:inSecret forKey:kConsumerSecret];
    }
}






-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    BOOL ifDisplayNotifs = [defaults boolForKey:@"notifToggle"];
    
    if (ifDisplayNotifs) {
        if (UIApplication.sharedApplication.applicationState == UIApplicationStateActive)
        {
            
        } else {
            
            NSString *tempString = [FlickrViewController getnoPhotos];
            
            if (self.photos.count >= [tempString integerValue]) {
                
                UILocalNotification *localNotification = [[UILocalNotification alloc] init];
                localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:5];
                localNotification.alertBody = @"You have taken photos here!! Click here to view them";
                localNotification.timeZone = [NSTimeZone defaultTimeZone];
                localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
                
                [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
                
                
            }
        }
        
    }
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
    
    //NSLog(@"the cell is %@", imageCell);
    
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

    
    double radius;
    SettingsController *sc = [[SettingsController alloc]init];
    
    if (sc.radius_C == nil) {
        radius = 5*0.8;
    } else {
        radius = [sc.radius_C doubleValue] *0.8;
        NSLog(@"Radius : %f",radius);
    }
    
    
    self.collectionView.contentInset = UIEdgeInsetsMake(20.0f, 0.0f, 0.0f, 0.0f);
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"myGridImage"];
    
    self->locationManager = [[CLLocationManager alloc] init];
    
    if(radius > 10) {
        self->locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    } else {
        self->locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    }
    self->locationManager.distanceFilter = radius * 1690;
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

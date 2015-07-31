//
//  LocationListController.m
//  PicoCale
//
//  Created by Manishgant on 7/29/15.
//  Copyright (c) 2015 Manishgant. All rights reserved.
//

#import "LocationListController.h"
#import "FullViewController.h"
#import "SettingsController.h"
#import "LocationListCollectionViewController.h"


@interface LocationListController ()

{
    CLLocationManager *locationManager;
    
    CLLocation *currentLocation;
    
    NSTimer *myTimer;
    
    NSArray *arrayWithNoDuplicates;
    
}


@end

@implementation LocationListController

static NSMutableString *radius_CC = (NSMutableString *) @"5";
static NSMutableString *noPhotosAlerts = (NSMutableString *) @"10";
static NSMutableArray *placeMarks;
static NSMutableOrderedSet *placeMarksSet;



+(NSString *)getRadius_C{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *geoRadius = [defaults objectForKey:@"geoRadius"];
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
@synthesize locationList = _locationList;
@synthesize photos = _photos;

-(void)setPhotos:(NSArray *)photos {
    if (_photos != photos) {
        _photos = photos;
        [self.tableView reloadData];
    }
}

-(void)setLocationList:(NSArray *)locationList {
    if (_locationList != locationList) {
        _locationList = locationList;
        [self.tableView reloadData];
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


- (IBAction)onRefreshPressed:(id)sender {
    [self.tableView reloadData];
}


- (void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    // add it
    [self.view addSubview:indicator];
    
    // animate it
    [indicator startAnimating];
    
    [self->locationManager startUpdatingLocation];
    // collect the photos
    [self disPlayLocationBasedPictures:self->locationManager.location];
    [indicator stopAnimating];
   
}

-(void) viewWillDisappear:(BOOL)animated {
    
    [myTimer invalidate];
    
}


-(void)refreshTable:(NSTimer *)timer {
    [self.tableView reloadData];
}

-(void) disPlayLocationBasedPictures:(CLLocation *)location {
    
    double maxLatitude,minLatitude;
    double maxLongitude,minLongitude;
    double radius;
    
    if (self.radius_C == nil) {
        radius = [[LocationListController getRadius_C] doubleValue];
        NSLog(@"Radius : %f",radius);
    } else {
        radius = [self.radius_C doubleValue];
        NSLog(@"Radius : %f",radius);
    }
    // collect the photos
    
    
    NSMutableArray *collector = [[NSMutableArray alloc] initWithCapacity:0];
    ALAssetsLibrary *al = [LocationListController defaultAssetsLibrary];
    
    
    maxLatitude = [self getMaxLatitude:location radius:radius];
    
    maxLongitude = [self getMaxLongitude:location radius:radius];
    
    
    minLatitude = [self getMinLatitude:location radius:radius];
    
    
    minLongitude = [self getMinLongitude:location radius:radius];
    
    //NSLog(@"%f %f %f %f",minLatitude,minLongitude,maxLatitude,maxLongitude);
    
    
    [al enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                      usingBlock:^(ALAssetsGroup *group, BOOL *stop)
     {
         [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop)
          {
              if (asset) {
                  
                  //ALAssetRepresentation *representation = [asset defaultRepresentation];
                  CLLocation *location = [asset valueForProperty:ALAssetPropertyLocation];
                  
                  double image_Latitude = location.coordinate.latitude;
                  double image_Longitude= location.coordinate.longitude;
                  
                  
                  if ((image_Latitude > minLatitude) && (image_Latitude < maxLatitude) ) {
                      
                      if((image_Longitude < minLongitude) && (image_Longitude > maxLongitude)) {
                          
                          [collector addObject:asset];
                          
                          // NSLog(@"Image %@ Latitude = %f Longitude = %f",[representation filename],image_Latitude,image_Longitude);
                      }
                  }
                  
              }
          }];
         
         self.photos = collector;
         
         placeMarks = [[NSMutableArray alloc] initWithCapacity:0];
         
         for (ALAsset * asset in collector) {
             [self reverseGeocode:[asset valueForProperty:ALAssetPropertyLocation]];
         }//[self.tableView reloadData];
         
         self.locationList = [[NSArray alloc]initWithArray:placeMarks];
        // arrayWithNoDuplicates = [[[NSSet alloc]initWithArray:placeMarks] allObjects];
        /*
         dispatch_async(dispatch_get_main_queue(), ^{
             [self.tableView reloadData];
         });
       */
         
         
     }
                    failureBlock:^(NSError *error) { NSLog(@"Error retrieving photos");}
     ];
    
    
}



/*
 Get the number of rows generated in Table View
 */

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //placeMarksSet = [[NSMutableOrderedSet alloc] initWithArray:placeMarks];
    return [placeMarks count];
    
}


/*
 Generate the Table View  and insert each row with the Image thumbnail
 and associated filename.
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[NSThread sleepForTimeInterval:5.0];
    static NSString *CellIdentifier = @"myLocationCell";
    
    UITableViewCell *imageCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (imageCell == nil) {
        imageCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure each cell in the
   
    if(placeMarks.count >0) {
  
        [imageCell.textLabel setText:[placeMarks objectAtIndex:indexPath.row]];
    }

        //ALAsset *asset = [self.photos objectAtIndex:indexPath.row];
        
        //CLLocation *location = [asset valueForProperty:ALAssetPropertyLocation];
        
       // [imageCell.textLabel setText:@""];
    
    return imageCell;
}

- (void)reverseGeocode:(CLLocation *)location {
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        //NSLog(@"Finding address");
        if (error) {
            NSLog(@"Error %@", error.description);
        } else {
            CLPlacemark *placemark = [placemarks lastObject];
            if (placemark.thoroughfare != nil){
            [placeMarks addObject:[placemark thoroughfare]];
            }
            placeMarks = [[[NSSet setWithArray: placeMarks] allObjects] mutableCopy];
            
            NSLog(@"Location info %@",[placeMarks lastObject]);
        }
           }];
}





/*
 The below method is a listener to listen for row select event inside the Table View
 On selecting the row, the view will segue to an UIImageView to display the image
 or a MPMoviePlayerController to play the video
 */

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  
    self.locationString = [placeMarks objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"viewLocationListColl" sender:self.locationString];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    LocationListCollectionViewController *fVC = [segue destinationViewController];
    
    fVC.locationString = self.locationString;
    
}



/*
 Set Tableview dimensions upon view load
 */

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.contentInset = UIEdgeInsetsMake(20.0f, 0.0f, 0.0f, 0.0f);
    double radius;
    
    
    myTimer= [NSTimer scheduledTimerWithTimeInterval: 3.0 target:self selector:@selector(refreshTable:) userInfo:nil repeats: NO];
    
    
    
    SettingsController *sc = [[SettingsController alloc]init];
    
    if (sc.radius_C == nil) {
        radius = 5*0.8;
    } else {
        radius = [sc.radius_C doubleValue] *0.8;
        NSLog(@"Radius : %f",radius);
    }
    
    
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

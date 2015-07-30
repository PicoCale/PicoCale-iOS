//
//  ImagesViewController.m
//  manantha_Universal_Multimedia
//
//  Created by Manishgant on 7/4/15.
//  Copyright (c) 2015 Manishgant. All rights reserved.
//

#import "ImagesViewController.h"
#import "FullViewController.h"


@interface ImagesViewController ()


@end

@implementation ImagesViewController

/*
 Reload data when new photos are added
 */
@synthesize photos = _photos;

-(void)setPhotos:(NSArray *)photos {
    if (_photos != photos) {
        _photos = photos;
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

- (void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    // collect the photos
    
    NSMutableArray *collector = [[NSMutableArray alloc] initWithCapacity:0];
    ALAssetsLibrary *al = [ImagesViewController defaultAssetsLibrary];
    
    [al enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                      usingBlock:^(ALAssetsGroup *group, BOOL *stop)
     {
         [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop)
          {
              if (asset) {
                  [collector addObject:asset];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.photos count];
    
}


/*
 Generate the Table View  and insert each row with the Image thumbnail
 and associated filename.
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"myImages";
    
    UITableViewCell *imageCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (imageCell == nil) {
        imageCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure each cell in the
    ALAsset *asset = [self.photos objectAtIndex:indexPath.row];
    
    ALAssetRepresentation *representation = [asset defaultRepresentation];
    NSURL *url = [representation url];
    NSLog(@"Image URL: %@", [url absoluteString]);
    
    [imageCell.imageView setImage:[UIImage imageWithCGImage:[asset thumbnail]]];
    [imageCell.textLabel setText:[asset.defaultRepresentation filename]];
    
    return imageCell;
}

/*
 The below method is a listener to listen for row select event inside the Table View
 On selecting the row, the view will segue to an UIImageView to display the image
 or a MPMoviePlayerController to play the video
 */

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    self->_assetInfo = [self.photos objectAtIndex:indexPath.row];
    
    ALAssetRepresentation *imageRep = [self->_assetInfo defaultRepresentation];
    
    self->_image = [UIImage imageWithCGImage:[imageRep fullScreenImage] scale:[imageRep scale] orientation: UIImageOrientationUp];
    NSString *tempString = [_assetInfo.defaultRepresentation filename];
    
    //Check if the media is a photo or a video
    
    if (!(([tempString containsString:(@".MOV")]) || ([tempString containsString:(@".MP4")])||
          ([tempString containsString:(@".mov")]) || ([tempString containsString:(@".mp4")]))) {
        
        [self performSegueWithIdentifier:@"viewFullImage" sender:self.image];
        
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
    
    self.tableView.contentInset = UIEdgeInsetsMake(20.0f, 0.0f, 0.0f, 0.0f);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

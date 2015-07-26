//
//  PreviewVideoController.m
//  manantha_Universal_Multimedia
//
//  Created by Manishgant on 7/7/15.
//  Copyright (c) 2015 Manishgant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PreviewVideoController.h"
#import "TwitterVideoUploader.h"


@import AVFoundation;



@interface PreviewVideoController()

- (void)saveVideo:(NSURL *)outputFileURL;

@property (nonatomic) UIBackgroundTaskIdentifier backgroundRecordingID;

@end


@implementation PreviewVideoController

/*
 Set captured video thumbnail from the passed video URL
 */
-(void)viewDidLoad{
    
    AVAsset *asset = [AVAsset assetWithURL:self->_opURL];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
    CMTime time = CMTimeMake(1, 1);
    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
    UIImage *thumbnail = [UIImage imageWithCGImage:imageRef scale:1.0f orientation:UIImageOrientationRight];
    CGImageRelease(imageRef);  // CGImageRef won't be released by ARC
    
    self->_videoThumbnail = thumbnail;
    
    [self->_videoThumbnailView setImage:thumbnail];
    
}

/*
 This method saves the captured video file to the device.
 This is referenced from the course example
 */

- (void)saveVideo:(NSURL *)outputFileURL
{
    // Note that currentBackgroundRecordingID is used to end the background task associated with this recording.
    // This allows a new recording to be started, associated with a new UIBackgroundTaskIdentifier, once the movie file output's isRecording property
    // is back to NO — which happens sometime after this method returns.
    // Note: Since we use a unique file path for each recording, a new recording will not overwrite a recording currently being saved.
    UIBackgroundTaskIdentifier currentBackgroundRecordingID = self.backgroundRecordingID;
    self.backgroundRecordingID = UIBackgroundTaskInvalid;
    
    dispatch_block_t cleanup = ^{
        [[NSFileManager defaultManager] removeItemAtURL:outputFileURL error:nil];
        if ( currentBackgroundRecordingID != UIBackgroundTaskInvalid ) {
            [[UIApplication sharedApplication] endBackgroundTask:currentBackgroundRecordingID];
        }
    };
    
    BOOL success = YES;
    
    if ( success ) {
        // Check authorization status.
        [PHPhotoLibrary requestAuthorization:^( PHAuthorizationStatus status ) {
            if ( status == PHAuthorizationStatusAuthorized ) {
                // Save the movie file to the photo library and cleanup.
                [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                    NSLog(@"Movie Save HERE");
                    [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:outputFileURL];
                    //}
                } completionHandler:^( BOOL success, NSError *error ) {
                    if ( ! success ) {
                        NSLog( @"Could not save movie to photo library: %@", error );
                    }
                    cleanup();
                }];
            }
            else {
                cleanup();
            }
        }];
    }
    else {
        cleanup();
    }
}

/*
 The following method plays back the captured video for the user to preview
 when the play video button is clicked
 */

- (IBAction)onPlayVideoPressed:(id)sender {
    
    MPMoviePlayerViewController *theMovieController=[[MPMoviePlayerViewController alloc] initWithContentURL:self->_opURL] ;
    
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
 A listener to check when video playback is finished and remove the view
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
 The following method calls the save video method when the
 Save Video button is pressed on the screen
 
 Also output device info & date to the log
 */

- (IBAction)onSavedVideo:(id)sender {
    
    NSDate *date = [[NSDate alloc]init];
    
    //Declare Date Formatter to format date according to problem
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss z"];
    
    NSString *dateString = [dateFormatter stringFromDate:date];
    
    NSString *OSVersion = (NSString *)[[UIDevice currentDevice] systemVersion];
    
    NSString *DeviceInfo = (NSString *)[[UIDevice currentDevice] model];
    
    NSString *andrewID = @"manantha";
    
    // Write requested information in the log
    NSLog(@"Device Info > %@:%@ %@:%@ ",andrewID,DeviceInfo,OSVersion,dateString);
    
    [self saveVideo:self->_opURL];
    
}


- (IBAction)onTweetVideoPressed:(id)sender {
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
        
    {
        ACAccountStore *account = [[ACAccountStore alloc] init];
        ACAccountType *accountType = [account
                                      accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        
        NSArray *arrayOfAccounts = [account
                                    accountsWithAccountType:accountType];
        
        ACAccount *twitterAccount = [arrayOfAccounts lastObject];
        
        
        NSURL *videoURL = self->_opURL;
        NSString *urlPath = [videoURL path];
        

    
        NSData *videoData = [NSData dataWithContentsOfURL:videoURL];
        
            // Get the size of the file in bytes.
            NSString *yourPath = [NSString stringWithFormat:@"%@", videoURL];
            NSFileManager *man = [NSFileManager defaultManager];
            NSDictionary *attrs = [man attributesOfItemAtPath:yourPath error: NULL];
            unsigned long long result = [attrs fileSize];
            
            if (result < 15728640) {
                
                [TwitterVideoUploader uploadTwitterVideo:videoData account:twitterAccount path:yourPath withCompletion: ^(void){
                 
                    [self videoUploadInform];
                    
                }];
                
                [self videoUploadingInform];
                
            } else {
                [self videoSizeTooLarge];
                
            }
        
    } else {
        [self twitterExceptionHandling:@"Please Sign in and allow access to Twitter to upload the video"];
        
    }
}


/*
 Inform user that the video has been uploaded
 */

-(void)videoUploadInform {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Video Uploaded!!!" message:@"Check the timeline to view your video :)" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       NSLog(@"User pressed OK");
                                   }];
    
    
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

/*
 Inform user that the video is uploading
 */

-(void)videoUploadingInform {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Uploading......" message:@"Please hold on while your video is being uploaded" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       NSLog(@"User pressed OK");
                                   }];
    
    
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}


/*
 Throw exception when video file size
 is too large
 */

-(void)videoSizeTooLarge {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Video size too large!!!" message:@"Please upload video less than 15 MB in size" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       NSLog(@"User pressed OK");
                                   }];
    
    
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}




/*
 Exception Handling to warn user to sign in and give access to Twitter credentials
 before posting the picture
 */

-(void)twitterExceptionHandling:(NSString *)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Oops!!!" message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       NSLog(@"User pressed Cancel");
                                   }];
    
    UIAlertAction *settingsAction = [UIAlertAction
                                     actionWithTitle:NSLocalizedString(@"Settings", @"Settings action")
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction *action)
                                     {
                                         NSLog(@"Settings Pressed");
                                         
                                         //code for opening settings app in iOS 8
                                         [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                                         
                                     }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:settingsAction];
    [self presentViewController:alertController animated:YES completion:nil];
    
}

@end
//
//  PreviewController.m
//  manantha_Universal_Multimedia
//
//  Created by Manishgant on 7/6/15.
//  Copyright (c) 2015 Manishgant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PreviewController.h"



@interface PreviewController()


@end

@implementation PreviewController

/*
 Set the image to be displayed on View load
 ALso set the parameters for scroll view,
 to enable zoom and pan effects
 */

-(void)viewDidLoad{
    
    [self.fullImageView setImage:_displayImage];
    self.fullImageView.frame = (CGRect){.origin=CGPointMake(0.0f, 0.0f), .size= self->_displayImage.size};
    
}

/*
 Clear the image of the UIImageView when the view is
 about to disappear so that it is available for the next image
 to be selected
 */

-(void) viewWillDisappear:(BOOL)animated {
    
    [self->_fullImageView setImage:nil];
    
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
 The following method saves the Photo captured
 along with outputting device & time info to the log
 */

- (IBAction)onSaveButtonClicked:(id)sender {
    
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
    
    [PHPhotoLibrary requestAuthorization:^( PHAuthorizationStatus status ) {
        if ( status == PHAuthorizationStatusAuthorized ) {
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                
                
                [PHAssetChangeRequest creationRequestForAssetFromImage:self->_displayImage];
                //request.contentEditingOutput = request.con;
                // iOS9
                /*
                 [[PHAssetCreationRequest creationRequestForAsset] addResourceWithType:PHAssetResourceTypePhoto data:imageData options:nil];*/
            } completionHandler:^( BOOL success, NSError *error ) {
                if ( ! success ) {
                    NSLog( @"Error occurred while saving image to photo library: %@", error );
                }
            }];
        }
    }];
    
    
}

/*
 Use Tweet Composer sheet to tweet the image with status
 */

- (IBAction)onTweetImagePressed:(id)sender {
    
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
        
    {
        
        SLComposeViewController *tweetSheet = [SLComposeViewController
                                               
                                               composeViewControllerForServiceType:SLServiceTypeTwitter];
        
        NSDate *date = [[NSDate alloc]init];
        
        //Declare Date Formatter to format date according to problem
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss z"];
        
        NSString *dateString = [dateFormatter stringFromDate:date];
        
        NSString *OSVersion = (NSString *)[[UIDevice currentDevice] systemVersion];
        
        NSString *DeviceInfo = (NSString *)[[UIDevice currentDevice] model];
        
        NSString *andrewID = @"manantha";
        
        [tweetSheet setInitialText: [NSString stringWithFormat:@"@MobileApp4 [Team 8] %@ %@ %@ %@",andrewID,dateString,DeviceInfo,OSVersion]];
        
        [tweetSheet addImage:self->_displayImage];
        
        [self presentViewController:tweetSheet animated:YES completion:^(void) {
            NSLog(@"Photo Uploaded to Twitter");
            [self imageUploadedInform];
        }
         ];
        
    } else {
        
        [self twitterExceptionHandling:@"Please Sign in and allow access to Twitter to post the picture"];
    }
    
}

/*
 Inform user that the image has been uploaded
 */

-(void)imageUploadedInform {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Image Uploaded!!!" message:@"Check the timeline to view your image :)" preferredStyle:UIAlertControllerStyleAlert];
    
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
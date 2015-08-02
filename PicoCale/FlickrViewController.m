//
//  FullViewController.m
//  manantha_Universal_Multimedia
//
//  Created by Manishgant on 7/5/15.
//  Copyright (c) 2015 Manishgant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FlickrViewController.h"
#import <Social/Social.h>




@interface FlickrViewController()
{
    CLLocationManager *locationManager;
    
}

@end

@implementation FlickrViewController


/*
 Set the image to be displayed on View load
 ALso set the parameters for scroll view,
 to enable zoom and pan effects
 */

-(void)viewDidLoad{
    
    [self.fullImageView setImage:_displayImage];
    [self.fullImageLabel setTitle:_displayImage.description];
    self.fullImageView.frame = (CGRect){.origin=CGPointMake(0.0f, 0.0f), .size= self->_displayImage.size};
    self->locationManager = [[CLLocationManager alloc] init];
    [self->locationManager startUpdatingLocation];
    
     self.flickrRequest = [[OFFlickrAPIRequest alloc] initWithAPIContext:[AppDelegate sharedDelegate].flickrContext];
    
    [self.flickrRequest callAPIMethodWithGET:@"flickr.photos.geo.getLocation" arguments:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%lld",self.photoID],@"photo_id", nil]];
    
    
}



- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didObtainOAuthRequestToken:(NSString *)inRequestToken secret:(NSString *)inSecret
{
    // these two lines are important
    [AppDelegate sharedDelegate].flickrContext.OAuthToken = inRequestToken;
    [AppDelegate sharedDelegate].flickrContext.OAuthTokenSecret = inSecret;
    
    NSURL *authURL = [[AppDelegate sharedDelegate].flickrContext userAuthorizationURLWithRequestToken:inRequestToken requestedPermission:OFFlickrWritePermission];
    [[UIApplication sharedApplication] openURL:authURL];
}


- (IBAction)TwitterShareButtonPressed:(id)sender {
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
        
    {
        
        SLComposeViewController *tweetSheet = [SLComposeViewController
                                               
                                               composeViewControllerForServiceType:SLServiceTypeTwitter];
        
        
        [tweetSheet setInitialText: [NSString stringWithFormat:@" Sent using @PicoCaleApp from #%@",[self.locationString stringByReplacingOccurrencesOfString:@" " withString:@"_"]]];
        
        [tweetSheet addImage:self->_displayImage];
        
        
        [self presentViewController:tweetSheet animated:YES completion:^(void) {
            NSLog(@"Photo Uploaded to Twitter");
        }
         ];
        
    } else {
        
        [self twitterExceptionHandling:@"Please Sign in and allow access to Twitter to post the picture"];
    }

    
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


- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didCompleteWithResponse:(NSDictionary *)inResponseDictionary
{
    //NSDictionary *photoDict = [[inResponseDictionary valueForKeyPath:@"photos.photo"] objectAtIndex:0];
    
    //NSString *title = [photoDict objectForKey:@"title"];
    // NSLog(@"PhotoTitle : %@",title);
    
    NSLog(@"%s %@ %@", __PRETTY_FUNCTION__, inRequest.sessionInfo, inResponseDictionary);
    
    NSArray *objPhotos = inResponseDictionary[@"photos"][@"photo"];
    
        NSMutableDictionary *objPhoto = objPhotos[0][@"location"];
        NSLog(@"The location is: %@",objPhoto);
        [self.fullImageLabel setTitle:self.locationString];
    
    
    
}

- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didFailWithError:(NSError *)inError
{
   // NSLog(@"%s %@ %@", __PRETTY_FUNCTION__, inRequest.sessionInfo, inError);
}

- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest imageUploadSentBytes:(NSUInteger)inSentBytes totalBytes:(NSUInteger)inTotalBytes
{
}

@end

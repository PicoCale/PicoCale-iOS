//
//  FullViewController.m
//  manantha_Universal_Multimedia
//
//  Created by Manishgant on 7/5/15.
//  Copyright (c) 2015 Manishgant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FullViewController.h"




@interface FullViewController()
{
    CLLocationManager *locationManager;
}

@end

@implementation FullViewController

/*
 Set the image to be displayed on View load
 ALso set the parameters for scroll view,
 to enable zoom and pan effects
 */

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self reverseGeocode:self.selectedLocation];
    
}

- (void)reverseGeocode:(CLLocation *)location {
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        //NSLog(@"Finding address");
        if (error) {
            NSLog(@"Error %@", error.description);
        } else {
            self.locationStringTitle = [[placemarks lastObject]thoroughfare];
             [self.fullImageLabel setTitle:self.locationStringTitle];
            NSLog(self.locationStringTitle);
        }
    }];
    
    //[self.tableView reloadData];
}

-(void)viewDidLoad{
    
    [self.fullImageView setImage:_displayImage];
    
   
    self.fullImageView.frame = (CGRect){.origin=CGPointMake(0.0f, 0.0f), .size= self->_displayImage.size};
    self->locationManager = [[CLLocationManager alloc] init];
    [self->locationManager startUpdatingLocation];
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:self->locationManager.location completionHandler:^(NSArray *placemarks, NSError *error) {
        //NSLog(@"Finding address");
        if (error) {
            NSLog(@"Error %@", error.description);
        } else {
            self.locationString = [[placemarks lastObject]subLocality];
        }
    }];

    
}


- (IBAction)TwitterShareButtonPressed:(id)sender {
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
        
    {
        
        SLComposeViewController *tweetSheet = [SLComposeViewController
                                               
                                               composeViewControllerForServiceType:SLServiceTypeTwitter];
        
        
        [tweetSheet setInitialText: [NSString stringWithFormat:@" Sent using @PicoCaleApp from #%@",[self.locationStringTitle stringByReplacingOccurrencesOfString:@" " withString:@"_"]]];
        
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


@end

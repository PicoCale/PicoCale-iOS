//
//  LocationListImageViewController.m
//  PicoCale
//
//  Created by Manishgant on 7/30/15.
//  Copyright (c) 2015 Manishgant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LocationListImageViewController.h"




@interface LocationListImageViewController()


@end

@implementation LocationListImageViewController

/*
 Set the image to be displayed on View load
 ALso set the parameters for scroll view,
 to enable zoom and pan effects
 */

-(void)viewDidLoad{
    
    [self.fullImageView setImage:_displayImage];
    [self.fullImageLabel setTitle:_displayImage.description];
    self.fullImageView.frame = (CGRect){.origin=CGPointMake(0.0f, 0.0f), .size= self->_displayImage.size};
    self.fullImageLabel.title = self.locationString;
    
    
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


@end

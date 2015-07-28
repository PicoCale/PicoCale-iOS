//
//  SettingsController.m
//  PicoCale
//
//  Created by Manishgant on 7/26/15.
//  Copyright (c) 2015 Manishgant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SettingsController.h"
#import "ImagesViewController.h"

@interface SettingsController ()

@property (nonatomic, assign) id currentResponder;

@end

@implementation SettingsController

- (void) setRadius_C:(NSString *)radius_C
{
    _radius_C = self.radiusTextField.text;
    
}


-(void) viewDidLoad {
    [super viewDidLoad];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *geoRadius = [defaults objectForKey:@"geoRadius"];
    
    NSString *noPhotosAlerts = [defaults objectForKey:@"noPhotosAlerts"];
    
    BOOL notificationOn = [defaults boolForKey:@"notifToggle"];
    
    self.radiusTextField.delegate = self;
    self.noPhotosAlertTextField.delegate = self;
    
    if (geoRadius != nil) {
        self.radiusTextField.text = geoRadius;
    }
    
    if (noPhotosAlerts != nil) {
        self.noPhotosAlertTextField.text = noPhotosAlerts;
    }
    
    if(notificationOn) {
        [self.notificationToggle setOn:TRUE animated:YES];
    
    } else {
        [self.notificationToggle setOn:FALSE animated:YES];
    }
    
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignOnTap:)];
    [singleTap setNumberOfTapsRequired:1];
    [singleTap setNumberOfTouchesRequired:1];
    [self.view addGestureRecognizer:singleTap];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.currentResponder = textField;
}

-(void)dismissKeyboard {
    [self.currentResponder resignFirstResponder];
    
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return YES;
}

- (void)resignOnTap:(id)iSender {
    [self.currentResponder resignFirstResponder];
}

- (IBAction)onSetTextPressed:(id)sender {
    
    [ImagesViewController setRadius_C:(NSMutableString *)self.radiusTextField.text];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.radiusTextField.text forKey:@"geoRadius"];
    [defaults setObject:self.noPhotosAlertTextField.text  forKey:@"noPhotosAlerts"];
    
    if([self.notificationToggle isOn]){
        [defaults setBool:TRUE forKey:@"notifToggle"];
    } else {
        [defaults setBool:FALSE forKey:@"notifToggle"];
    }
    
    [defaults synchronize];
}


@end
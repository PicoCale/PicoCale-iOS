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

    self.radiusTextField.delegate = self;
    if (geoRadius != nil) {
        self.radiusTextField.text = geoRadius;
    }
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)onSetTextPressed:(id)sender {
    
    [ImagesViewController setRadius_C:(NSMutableString *)self.radiusTextField.text];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.radiusTextField.text forKey:@"geoRadius"];
    [defaults synchronize];
}


@end
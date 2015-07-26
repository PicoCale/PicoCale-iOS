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


@end

@implementation FullViewController

/*
 Set the image to be displayed on View load
 ALso set the parameters for scroll view,
 to enable zoom and pan effects
 */

-(void)viewDidLoad{
    
    [self.fullImageView setImage:_displayImage];
    [self.fullImageLabel setTitle:_displayImage.description];
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


@end
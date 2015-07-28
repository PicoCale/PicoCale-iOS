//
//  SettingsController.h
//  PicoCale
//
//  Created by Manishgant on 7/26/15.
//  Copyright (c) 2015 Manishgant. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

/*
 Initialize the elements required to display the selected image
 from the TableView in a separate View.
 */

@interface SettingsController : UIViewController<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *radiusTextField;


@property (weak, nonatomic) NSString *radius_C;

@property (weak, nonatomic) IBOutlet UITextField *noPhotosAlertTextField;

@property (weak, nonatomic) IBOutlet UISwitch *notificationToggle;

@end


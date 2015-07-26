//
//  MediaPreview.h
//  manantha_Universal_Multimedia
//
//  Created by Manishgant on 7/6/15.
//  Copyright (c) 2015 Manishgant. All rights reserved.
//

#import  <UIKit/UIKit.h>

@class AVCaptureSession;

@interface MediaPreview : UIView

@property (nonatomic) AVCaptureSession *session;

@end


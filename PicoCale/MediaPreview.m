//
//  MediaPreview.m
//  manantha_Universal_Multimedia
//
//  Created by Manishgant on 7/6/15.
//  Copyright (c) 2015 Manishgant. All rights reserved.
//

#import "Foundation/Foundation.h"
@import AVFoundation;

#import "MediaPreview.h"

@implementation MediaPreview

+ (Class)layerClass
{
    return [AVCaptureVideoPreviewLayer class];
}

- (AVCaptureSession *)session
{
    AVCaptureVideoPreviewLayer *previewLayer = (AVCaptureVideoPreviewLayer *)self.layer;
    return previewLayer.session;
}

- (void)setSession:(AVCaptureSession *)session
{
    AVCaptureVideoPreviewLayer *previewLayer = (AVCaptureVideoPreviewLayer *)self.layer;
    previewLayer.session = session;
}

@end

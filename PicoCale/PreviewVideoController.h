//
//  PreviewVideoController.h
//  manantha_Universal_Multimedia
//
//  Created by Manishgant on 7/7/15.
//  Copyright (c) 2015 Manishgant. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import <MediaPlayer/MediaPlayer.h>

/*
 Initialize the elements required to display the selected image
 from the TableView in a separate View.
 */

@interface PreviewVideoController: UIViewController<UIScrollViewDelegate>

@property (weak, nonatomic) NSURL *opURL;

@property (weak, nonatomic) IBOutlet UIImageView *videoThumbnailView;

@property (weak, nonatomic) IBOutlet UIImage *videoThumbnail;

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;





@end

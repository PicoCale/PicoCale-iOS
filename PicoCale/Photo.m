//
//  Photo.m
//  manantha_Universal_Multimedia
//
//  Created by Manishgant on 7/25/15.
//  Copyright (c) 2015 Manishgant. All rights reserved.
//
#import "Photo.h"

@interface PhotoCell ()
// 1
@property(nonatomic, weak) IBOutlet UIImageView *photoImageView;
@end

@implementation PhotoCell
- (void) setAsset:(ALAsset *)asset
{
    // 2
    _asset = asset;
    self.photoImageView.image = [UIImage imageWithCGImage:[asset thumbnail]];
}
@end

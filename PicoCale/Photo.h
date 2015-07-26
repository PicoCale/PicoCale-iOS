//
//  Photo.h
//  manantha_Universal_Multimedia
//
//  Created by Manishgant on 7/25/15.
//  Copyright (c) 2015 Manishgant. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import <UIKit/UIKit.h>

@interface PhotoCell : UICollectionViewCell
@property(nonatomic, strong) ALAsset *asset;
@end

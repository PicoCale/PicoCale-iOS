//
//  Flickr.h
//  PicoCale
//
//  Created by Manishgant on 7/28/15.
//  Copyright (c) 2015 Manishgant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class FlickrPhoto;

typedef void (^FlickrSearchCompletionBlock)(NSString *searchTerm, NSArray *results, NSError *error);
typedef void (^FlickrPhotoCompletionBlock)(UIImage *photoImage, NSError *error);

@interface Flickr : NSObject

@property(strong) NSString *apiKey;

- (void)searchFlickrForTerm:(NSString *) term completionBlock:(FlickrSearchCompletionBlock) completionBlock;
+ (void)loadImageForPhoto:(FlickrPhoto *)flickrPhoto thumbnail:(BOOL)thumbnail completionBlock:(FlickrPhotoCompletionBlock) completionBlock;
+ (NSString *)flickrPhotoURLForFlickrPhoto:(FlickrPhoto *) flickrPhoto size:(NSString *) size;

@end


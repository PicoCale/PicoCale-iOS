//
//  Photo.h
//  manantha_Universal_Multimedia
//
//  Created by Manishgant on 7/25/15.
//  Copyright (c) 2015 Manishgant. All rights reserved.
//

@import CoreLocation;

@interface Photo : NSObject

@property(nonatomic,strong) NSString *identifier;
@property(nonatomic, weak) NSURL *url;
@property(nonatomic, weak) CLLocation *locationInfo;


@end


//
//  Location.m
//  PicoCale
//
//  Created by Manishgant on 7/30/15.
//  Copyright (c) 2015 Manishgant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Location.h"

@interface Location ()


@end

@implementation Location

-(void) setLatitude:(NSString *)latitude {
    
    _latitude = latitude;
}

-(void) setLongitude:(NSString *)longitude {
    
    _longitude = longitude;
}

-(NSString *) getLatitude {
    
    return _latitude;
}

-(NSString *) getLongitude {
    
    return _longitude;
}

@end
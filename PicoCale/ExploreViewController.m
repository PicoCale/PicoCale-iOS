//
//  SecondViewController.m
//  PicoCale
//
//  Created by Manishgant on 6/29/15.
//  Copyright (c) 2015 Manishgant. All rights reserved.
//

#import "ExploreViewController.h"
#import "Flickr.h"
#import "FlickrPhoto.h"

@interface ExploreViewController ()

@property(nonatomic, strong) NSMutableDictionary *searchResults;
@property(nonatomic, strong) NSMutableArray *searches;
@property(nonatomic, strong) Flickr *flickr;

@end

@implementation ExploreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.searches = [@[] mutableCopy];
    self.searchResults = [@{} mutableCopy];
    self.flickr = [[Flickr alloc] init];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

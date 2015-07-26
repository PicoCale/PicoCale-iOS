//
//  TwitterVideoUploader.m
//  manantha_Universal_Multimedia
//
//  Created by Manishgant on 7/16/15.
//  Copyright (c) 2015 Manishgant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TwitterVideoUploader.h"

@interface TwitterVideoUploader()

@end

@implementation TwitterVideoUploader

+(BOOL)userHasAccessToFacebook
{
    return [SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook];
}

+(BOOL)userHasAccessToTwitter
{
    return [SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter];
}

/*
 Twitter video upload is using twitter's REST API. This is done through
 3 steps, INIT, APPEND and FINALIZE to upload the video.
 
 A fourth step is also required, which posts the status with the uploaded 
 video.
 
 Each INIT, APPEND and FINALIZE methods return URL response from Twitter containing status code
 and media_id to proceed to subsequent steps
 
 The response from twitter and media_ids are printed to the log to check for consistency
 */

+(void)uploadTwitterVideo:(NSData*)videoData account:(ACAccount*)account path:(NSString *)path withCompletion:(dispatch_block_t)completion{
    
    NSURL *twitterPostURL = [[NSURL alloc] initWithString:@"https://upload.twitter.com/1.1/media/upload.json"];
    
    NSDictionary *postParams = @{@"command": @"INIT",
                                 @"total_bytes" : [NSNumber numberWithInteger: videoData.length].stringValue,
                                 @"media_type" : @"video/mp4"
                                 };
    
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:twitterPostURL parameters:postParams];
    request.account = account;
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        NSLog(@"HTTP Response: %li, responseData: %@", (long)[urlResponse statusCode], [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
        if (error) {
            NSLog(@"There was an error:%@", [error localizedDescription]);
        } else {
            NSMutableDictionary *returnedData = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&error];
            
            NSString *mediaID = [NSString stringWithFormat:@"%@", [returnedData valueForKey:@"media_id_string"]];
            
            [self tweetVideoStage2:videoData mediaID:mediaID account:account path:path withCompletion:completion];
            
            NSLog(@"Stage1 INIT success, mediaID -> %@", mediaID);
        }
    }];
}

+(void)tweetVideoStage2:(NSData*)videoData mediaID:(NSString *)mediaID account:(ACAccount*)account path:(NSString *)path withCompletion:(dispatch_block_t)completion{
    
    NSURL *twitterPostURL = [[NSURL alloc] initWithString:@"https://upload.twitter.com/1.1/media/upload.json"];
    NSDictionary *postParams = @{@"command": @"APPEND",
                                 @"media_id" : mediaID,
                                 @"segment_index" : @"0",
                                 //@"--file": path,
                                 //@"--file-field" : @"media"
                                 };
    
    SLRequest *postRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:twitterPostURL parameters:postParams];
    postRequest.account = account;
    
    [postRequest addMultipartData:videoData withName:@"media" type:@"video/mp4" filename:@"video"];
    [postRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        NSLog(@"Stage2 APPEND HTTP Response: %li, %@", (long)[urlResponse statusCode], [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
        if (!error) {
            [self tweetVideoStage3:videoData mediaID:mediaID account:account withCompletion:completion];
        }
        else {
            NSLog(@"Error stage 2 - %@", error);
        }
    }];
}

+(void)tweetVideoStage3:(NSData*)videoData mediaID:(NSString *)mediaID account:(ACAccount*)account withCompletion:(dispatch_block_t)completion{
    
    NSURL *twitterPostURL = [[NSURL alloc] initWithString:@"https://upload.twitter.com/1.1/media/upload.json"];
    
    NSDictionary *postParams = @{@"command": @"FINALIZE",
                                 @"media_id" : mediaID };
    
    SLRequest *postRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:twitterPostURL parameters:postParams];
    
    // Set the account and begin the request.
    postRequest.account = account;
    [postRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        NSLog(@"Stage3 FINALIZE HTTP Response: %li, %@", (long)[urlResponse statusCode], [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
        if (error) {
            NSLog(@"Error stage 3 - %@", error);
        } else {
            [self tweetVideoStage4:videoData mediaID:mediaID account:account withCompletion:completion];
        }
    }];
}

+(void)tweetVideoStage4:(NSData*)videoData mediaID:(NSString *)mediaID account:(ACAccount*)account withCompletion:(dispatch_block_t)completion{
    
    NSDate *date = [[NSDate alloc]init];
    
    //Declare Date Formatter to format date according to problem
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss z"];
    
    NSString *dateString = [dateFormatter stringFromDate:date];
    
    NSString *OSVersion = (NSString *)[[UIDevice currentDevice] systemVersion];
    
    NSString *DeviceInfo = (NSString *)[[UIDevice currentDevice] model];
    
    NSString *andrewID = @"manantha";
    
    
    
    NSURL *twitterPostURL = [[NSURL alloc] initWithString:@"https://api.twitter.com/1.1/statuses/update.json"];
    NSString *statusContent = [NSString stringWithFormat:@"@MobileApp4 [Team 8] %@ %@ %@ %@",andrewID,dateString,DeviceInfo,OSVersion];
    
    NSLog(@" This is the media_id in last stage : %@",mediaID);
    
    // Set the parameters for the third twitter video request.
    NSMutableDictionary *parameters =
    [[NSMutableDictionary alloc] init];
    [parameters setObject:statusContent forKey:@"status"];
    [parameters setObject:@[mediaID] forKey:@"media_ids"];
    
    SLRequest *postRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:twitterPostURL parameters:parameters];
    postRequest.account = account;
    [postRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        NSLog(@"Stage4 POST Status HTTP Response: %li, %@", (long)[urlResponse statusCode], [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
        if (error) {
            NSLog(@"Error stage 4 - %@", error);
        } else {
            if ([urlResponse statusCode] == 200){
                NSLog(@"upload success !");
                DispatchMainThread(^(){completion();});
            }
        }
    }];
    
}

@end
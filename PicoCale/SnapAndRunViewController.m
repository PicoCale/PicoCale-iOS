//
//  SnapAndRunViewController.m
//  PicoCale
//
//  Created by Manishgant on 7/27/15.
//  Copyright (c) 2015 Manishgant. All rights reserved.
//

#import "SnapAndRunViewController.h"
#import "SnapAndRunAppDelegate.h"

NSString *kFetchRequestTokenStep = @"kFetchRequestTokenStep";
NSString *kGetUserInfoStep = @"kGetUserInfoStep";
NSString *kSetImagePropertiesStep = @"kSetImagePropertiesStep";
NSString *kUploadImageStep = @"kUploadImageStep";

@interface SnapAndRunViewController (PrivateMethods)
- (void)updateUserInterface:(NSNotification *)notification;
@end


@implementation SnapAndRunViewController
- (void)viewDidUnload
{
    self.flickrRequest = nil;
    self.imagePicker = nil;
    
    self.authorizeButton = nil;
    self.authorizeDescriptionLabel = nil;
    self.snapPictureButton = nil;
    self.snapPictureDescriptionLabel = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Snap and Run";
    
    if ([[SnapAndRunAppDelegate sharedDelegate].flickrContext.OAuthToken length]) {
        authorizeButton.enabled = NO;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUserInterface:) name:SnapAndRunShouldUpdateAuthInfoNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateUserInterface:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)updateUserInterface:(NSNotification *)notification
{
    if ([[SnapAndRunAppDelegate sharedDelegate].flickrContext.OAuthToken length]) {
        [authorizeButton setTitle:@"Reauthorize" forState:UIControlStateNormal];
        [authorizeButton setTitle:@"Reauthorize" forState:UIControlStateHighlighted];
        [authorizeButton setTitle:@"Reauthorize" forState:UIControlStateDisabled];
        
        if ([[SnapAndRunAppDelegate sharedDelegate].flickrUserName length]) {
            authorizeDescriptionLabel.text = [NSString stringWithFormat:@"You are %@", [SnapAndRunAppDelegate sharedDelegate].flickrUserName];
        }
        else {
            authorizeDescriptionLabel.text = @"You've logged in";
        }
        
        snapPictureButton.enabled = YES;
    }
    else {
        [authorizeButton setTitle:@"Authorize" forState:UIControlStateNormal];
        [authorizeButton setTitle:@"Authorize" forState:UIControlStateHighlighted];
        [authorizeButton setTitle:@"Authorize" forState:UIControlStateDisabled];
        
        authorizeDescriptionLabel.text = @"Login to Flickr";
        snapPictureButton.enabled = NO;
    }
    
    if ([self.flickrRequest isRunning]) {
        [snapPictureButton setTitle:@"Cancel" forState:UIControlStateNormal];
        [snapPictureButton setTitle:@"Cancel" forState:UIControlStateHighlighted];
        [snapPictureButton setTitle:@"Cancel" forState:UIControlStateDisabled];
        authorizeButton.enabled = NO;
    }
    else {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            [snapPictureButton setTitle:@"Snap" forState:UIControlStateNormal];
            [snapPictureButton setTitle:@"Snap" forState:UIControlStateHighlighted];
            [snapPictureButton setTitle:@"Snap" forState:UIControlStateDisabled];
            snapPictureDescriptionLabel.text = @"Use camera";
        }
        else {
            [snapPictureButton setTitle:@"Pick Picture" forState:UIControlStateNormal];
            [snapPictureButton setTitle:@"Pick Picture" forState:UIControlStateHighlighted];
            [snapPictureButton setTitle:@"Pick Picture" forState:UIControlStateDisabled];
            snapPictureDescriptionLabel.text = @"Pick from library";
        }
        
        authorizeButton.enabled = YES;
    }
}


#pragma mark OFFlickrAPIRequest delegate methods

- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didObtainOAuthRequestToken:(NSString *)inRequestToken secret:(NSString *)inSecret
{
    // these two lines are important
    [SnapAndRunAppDelegate sharedDelegate].flickrContext.OAuthToken = inRequestToken;
    [SnapAndRunAppDelegate sharedDelegate].flickrContext.OAuthTokenSecret = inSecret;
    
    NSURL *authURL = [[SnapAndRunAppDelegate sharedDelegate].flickrContext userAuthorizationURLWithRequestToken:inRequestToken requestedPermission:OFFlickrWritePermission];
    [[UIApplication sharedApplication] openURL:authURL];
}

- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didCompleteWithResponse:(NSDictionary *)inResponseDictionary
{
    NSLog(@"%s %@ %@", __PRETTY_FUNCTION__, inRequest.sessionInfo, inResponseDictionary);
    
    if (inRequest.sessionInfo == kUploadImageStep) {
        snapPictureDescriptionLabel.text = @"Setting properties...";
        
        
        NSLog(@"%@", inResponseDictionary);
        NSString *photoID = [[inResponseDictionary valueForKeyPath:@"photoid"] textContent];
        
        flickrRequest.sessionInfo = kSetImagePropertiesStep;
        [flickrRequest callAPIMethodWithPOST:@"flickr.photos.setMeta" arguments:[NSDictionary dictionaryWithObjectsAndKeys:photoID, @"photo_id", @"Snap and Run", @"title", @"Uploaded from my iPhone/iPod Touch", @"description", nil]];
    }
    else if (inRequest.sessionInfo == kSetImagePropertiesStep) {
        [self updateUserInterface:nil];
        snapPictureDescriptionLabel.text = @"Done";
        
        [UIApplication sharedApplication].idleTimerDisabled = NO;
        
    }
}

- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didFailWithError:(NSError *)inError
{
    NSLog(@"%s %@ %@", __PRETTY_FUNCTION__, inRequest.sessionInfo, inError);
    if (inRequest.sessionInfo == kUploadImageStep) {
        [self updateUserInterface:nil];
        snapPictureDescriptionLabel.text = @"Failed";
        [UIApplication sharedApplication].idleTimerDisabled = NO;
        
        [[[UIAlertView alloc] initWithTitle:@"API Failed" message:[inError description] delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
        
    }
    else {
        [[[UIAlertView alloc] initWithTitle:@"API Failed" message:[inError description] delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
    }
}

- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest imageUploadSentBytes:(NSUInteger)inSentBytes totalBytes:(NSUInteger)inTotalBytes
{
    if (inSentBytes == inTotalBytes) {
        snapPictureDescriptionLabel.text = @"Waiting for Flickr...";
    }
    else {
     //   snapPictureDescriptionLabel.text = [NSString stringWithFormat:@"%u/%lu (KB)", inSentBytes / 1024, inTotalBytes / 1024];
    }
}


#pragma mark UIImagePickerController delegate methods
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    //[self dismissModalViewControllerAnimated:YES];
}

- (void)_startUpload:(UIImage *)image
{
    NSData *JPEGData = UIImageJPEGRepresentation(image, 1.0);
    
    snapPictureButton.enabled = NO;
    snapPictureDescriptionLabel.text = @"Uploading";
    
    self.flickrRequest.sessionInfo = kUploadImageStep;
    [self.flickrRequest uploadImageStream:[NSInputStream inputStreamWithData:JPEGData] suggestedFilename:@"Snap and Run Demo" MIMEType:@"image/jpeg" arguments:[NSDictionary dictionaryWithObjectsAndKeys:@"0", @"is_public", nil]];
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    [self updateUserInterface:nil];
}
    
#pragma mark Accesors
    
    - (OFFlickrAPIRequest *)flickrRequest
    {
        if (!flickrRequest) {
            flickrRequest = [[OFFlickrAPIRequest alloc] initWithAPIContext:[SnapAndRunAppDelegate sharedDelegate].flickrContext];
            flickrRequest.delegate = self;
            flickrRequest.requestTimeoutInterval = 60.0;
        }
        
        return flickrRequest;
    }
    

#endif
    
    @synthesize flickrRequest;
    @synthesize imagePicker;
    
    @synthesize authorizeButton;
    @synthesize authorizeDescriptionLabel;
    @synthesize snapPictureButton;
    @synthesize snapPictureDescriptionLabel;
    @end
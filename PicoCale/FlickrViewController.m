//
// SnapAndRunViewController.m
//
// Copyright (c) 2009 Lukhnos D. Liu (http://lukhnos.org)
//
// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without
// restriction, including without limitation the rights to use,
// copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following
// conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.
//

#import "FlickrViewController.h"
#import "FlickrViewAppDelegate.h"

NSString *kFetchRequestTokenStep = @"kFetchRequestTokenStep";
NSString *kGetUserInfoStep = @"kGetUserInfoStep";
NSString *kSetImagePropertiesStep = @"kSetImagePropertiesStep";
NSString *kUploadImageStep = @"kUploadImageStep";

@interface FlickrViewController (PrivateMethods)
- (void)updateUserInterface:(NSNotification *)notification;
@end


@implementation FlickrViewController
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
    self.title = @"PicoCale";
    
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

#pragma mark Actions

- (IBAction)snapPictureAction
{
    if ([self.flickrRequest isRunning]) {
        [self.flickrRequest cancel];
        [self updateUserInterface:nil];
        return;
    }
    
    [self presentModalViewController:self.imagePicker animated:YES];
}

- (IBAction)authorizeAction
{
    // if there's already OAuthToken, we want to reauthorize
    if ([[SnapAndRunAppDelegate sharedDelegate].flickrContext.OAuthToken length]) {
        [[SnapAndRunAppDelegate sharedDelegate] setAndStoreFlickrAuthToken:nil secret:nil];
    }
    
    authorizeButton.enabled = NO;
    authorizeDescriptionLabel.text = @"Authenticating...";
    
    self.flickrRequest.sessionInfo = kFetchRequestTokenStep;
    [self.flickrRequest fetchOAuthRequestTokenWithCallbackURL:[NSURL URLWithString:SRCallbackURLBaseString]];
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
        snapPictureDescriptionLabel.text = [NSString stringWithFormat:@"%u/%lu (KB)", inSentBytes / 1024, inTotalBytes / 1024];
    }
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
    
    - (UIImagePickerController *)imagePicker
    {
        if (!imagePicker) {
            imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.delegate = self;
            
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            }
        }
        return imagePicker;
    }
    
#ifndef __IPHONE_3_0
    - (void)setView:(UIView *)view
    {
        if (view == nil) {
            [self viewDidUnload];
        }
        
        [super setView:view];
    }
#endif
    
    @synthesize flickrRequest;
    @synthesize imagePicker;
    
    @synthesize authorizeButton;
    @synthesize authorizeDescriptionLabel;
    @synthesize snapPictureButton;
    @synthesize snapPictureDescriptionLabel;
    @end

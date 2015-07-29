
#import "SnapAndRunViewController.h"
#import "AppDelegate.h"
#import "FlickrPhoto.h"
#import "Flickr.h"
#import "FlickrViewController.h"

NSString *kFetchRequestTokenStep = @"kFetchRequestTokenStep";
NSString *kGetUserInfoStep = @"kGetUserInfoStep";
NSString *kSetImagePropertiesStep = @"kSetImagePropertiesStep";
NSString *kUploadImageStep = @"kUploadImageStep";

@interface SnapAndRunViewController (PrivateMethods)
- (void)updateUserInterface:(NSNotification *)notification;
@end


@implementation SnapAndRunViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Snap and Run";
    
	if ([[AppDelegate sharedDelegate].flickrContext.OAuthToken length]) {
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
	if ([[AppDelegate sharedDelegate].flickrContext.OAuthToken length]) {
		[authorizeButton setTitle:@"Reauthorize" forState:UIControlStateNormal];
		[authorizeButton setTitle:@"Reauthorize" forState:UIControlStateHighlighted];
		[authorizeButton setTitle:@"Reauthorize" forState:UIControlStateDisabled];		
		
		if ([[AppDelegate sharedDelegate].flickrUserName length]) {
			authorizeDescriptionLabel.text = [NSString stringWithFormat:@"You are %@", [AppDelegate sharedDelegate].flickrUserName];
		}
		else {
			authorizeDescriptionLabel.text = @"You've logged in";
		}
		
		snapPictureButton.enabled = YES;
	}
	else {
		[authorizeButton setTitle:@"Reauthorize" forState:UIControlStateNormal];
		[authorizeButton setTitle:@"Reauthorize" forState:UIControlStateHighlighted];
		[authorizeButton setTitle:@"Reauthorize" forState:UIControlStateDisabled];
		
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
			[snapPictureButton setTitle:@"Get Photos" forState:UIControlStateNormal];
			[snapPictureButton setTitle:@"Get Photos" forState:UIControlStateHighlighted];
			[snapPictureButton setTitle:@"Get Photos" forState:UIControlStateDisabled];
			snapPictureDescriptionLabel.text = @"Get Photos from Location";
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
    if (![flickrRequest isRunning]) {
        [flickrRequest callAPIMethodWithGET:@"flickr.photos.getRecent" arguments:[NSDictionary dictionaryWithObjectsAndKeys:@"20", @"per_page", nil]];
    }
}

- (IBAction)authorizeAction
{
    // if there's already OAuthToken, we want to reauthorize
    if ([[AppDelegate sharedDelegate].flickrContext.OAuthToken length]) {
        [[AppDelegate sharedDelegate] setAndStoreFlickrAuthToken:nil secret:nil];
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
    [AppDelegate sharedDelegate].flickrContext.OAuthToken = inRequestToken;
    [AppDelegate sharedDelegate].flickrContext.OAuthTokenSecret = inSecret;

    NSURL *authURL = [[AppDelegate sharedDelegate].flickrContext userAuthorizationURLWithRequestToken:inRequestToken requestedPermission:OFFlickrWritePermission];
    [[UIApplication sharedApplication] openURL:authURL];    
}

-(NSString *)flickrPhotoURLforPhoto:(FlickrPhoto *) flickrPhoto size:(NSString *) size
{
    if(!size)
    {
        size = @"m";
    }
    return [NSString stringWithFormat:@"http://farm%ld.staticflickr.com/%ld/%lld_%@_%@.jpg",(long)flickrPhoto.farm,(long)flickrPhoto.server,flickrPhoto.photoID,flickrPhoto.secret,size];
}


- (void)flickrAPIRequest:(OFFlickrAPIRequest *)inRequest didCompleteWithResponse:(NSDictionary *)inResponseDictionary
{
    //NSDictionary *photoDict = [[inResponseDictionary valueForKeyPath:@"photos.photo"] objectAtIndex:0];
    
    //NSString *title = [photoDict objectForKey:@"title"];
   // NSLog(@"PhotoTitle : %@",title);
    
    NSLog(@"%s %@ %@", __PRETTY_FUNCTION__, inRequest.sessionInfo, inResponseDictionary);
    
    NSArray *objPhotos = inResponseDictionary[@"photos"][@"photo"];
    
    NSMutableArray *flickrPhotos = [@[] mutableCopy];
    self.flickrPics = [[NSMutableArray alloc] initWithCapacity:0 ];
    for(NSMutableDictionary *objPhoto in objPhotos)
    {
        FlickrPhoto *photo = [[FlickrPhoto alloc] init];
        photo.farm = [objPhoto[@"farm"] intValue];
        photo.server = [objPhoto[@"server"] intValue];
        photo.secret = objPhoto[@"secret"];
        photo.photoID = [objPhoto[@"id"] longLongValue];
        
        NSString *searchURL = [Flickr flickrPhotoURLForFlickrPhoto:photo size:@"m"];
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:searchURL] options:0 error:nil];
        UIImage *image = [UIImage imageWithData:imageData];
        photo.thumbnail = image;
        
        [flickrPhotos addObject:photo];
        [self.flickrPics addObject:photo];
    }
    
    //self.flickrPics = flickrPhotos;
   [self performSegueWithIdentifier:@"viewFlickrPics" sender:self.flickrPics];
    /*
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
     */
  //  [UIApplication sharedApplication].idleTimerDisabled = NO;
        
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    FlickrViewController *fVC = [segue destinationViewController];
    
    fVC.flickrPhotos = self.flickrPics;
    
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
		snapPictureDescriptionLabel.text = [NSString stringWithFormat:@"%lu/%lu (KB)", inSentBytes / 1024, inTotalBytes / 1024];
	}
}


#pragma mark UIImagePickerController delegate methods
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissModalViewControllerAnimated:YES];
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

#ifndef __IPHONE_3_0
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
//  NSDictionary *editingInfo = info;
#else
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
#endif

    [self dismissModalViewControllerAnimated:YES];
	
	snapPictureDescriptionLabel.text = @"Preparing...";
	
	// we schedule this call in run loop because we want to dismiss the modal view first
	[self performSelector:@selector(_startUpload:) withObject:image afterDelay:0.0];
}

#pragma mark Accesors

- (OFFlickrAPIRequest *)flickrRequest
{
    if (!flickrRequest) {
        flickrRequest = [[OFFlickrAPIRequest alloc] initWithAPIContext:[AppDelegate sharedDelegate].flickrContext];
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
    @synthesize flickrPics;
@synthesize authorizeButton;
@synthesize authorizeDescriptionLabel;
@synthesize snapPictureButton;
@synthesize snapPictureDescriptionLabel;
@end

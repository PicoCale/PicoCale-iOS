//
//  TwitterViewController.m
//  manantha_Universal_Multimedia
//
//  Created by Manishgant on 7/14/15.
//  Copyright (c) 2015 Manishgant. All rights reserved.
//

#import "TwitterViewCOntroller.h"
#import "TweetDisplayView.h"

@interface TwitterViewController()

@end

@implementation TwitterViewController


/*
 When view is about to appear, get the tweets
 from user timeline and display them in a
 TableView
 */

-(void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self getTimelineTweets];
    ACAccountStore *account = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [account
                                  accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    
    NSArray *arrayOfAccounts = [account
                                accountsWithAccountType:accountType];
    
    if ([arrayOfAccounts count] > 0)
    {
        ACAccount *twitterAccount = [arrayOfAccounts lastObject];
        self.twitterNavBar.title = [NSString stringWithFormat: @"@%@ Timeline",twitterAccount.username];
    }
    
}

/*
 Set refresh control for timeline when tableview gets loaded
 */
-(void) viewDidLoad {
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.tweetTableView addSubview:refreshControl];
}

/*
 Update the timeline when the user refreshes screen by pulling down
 */
- (void)refresh:(UIRefreshControl *)refreshControl {
    [self getTimelineTweets];
    [self.tweetTableView reloadData];
    [refreshControl endRefreshing];
}

/*
 Get the number of rows in the TableView
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataSource.count;
}

/*
 Construct each cell in the Tableview with text from the tweet
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [self.tweetTableView
                             dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary *tweet = _dataSource[[indexPath row]];
    cell.textLabel.numberOfLines = 0;
    [cell.textLabel setText: tweet[@"text"]];
    
    NSDictionary *entities = tweet[@"entities"];
    NSArray *medias = entities[@"media"];
    NSDictionary *ImageUrls = medias[0];
    NSString *string = ImageUrls[@"media_url"];
    
    if (string != nil) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
    
}

/*
 Alter the height of the cell in Tableview based on
 text content. Wrap the text of the content in the cell
 */

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewAutomaticDimension;
}

/*
 When the user selects a row on the tableview, perform a segue
 to display the tweet in a webview. Perform this only on tweets
 which have media attached. Use NSDataDetector to identify tweets
 with media URL and display only those in the webview
 */

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *tweet = _dataSource[[indexPath row]];
    NSDictionary *entities = tweet[@"entities"];
    NSArray *medias = entities[@"media"];
    NSDictionary *ImageUrls = medias[0];
    NSString *media_type = ImageUrls[@"expanded_url"];
    NSString *isMediaTweet = ImageUrls[@"media_url"];
    
    //Check if the selected tweet has any media
    if (isMediaTweet != nil) {
        
        //Check if the media is photo or video and accordingly
        //send the url to the Webview
        
        NSString *expression = @"^(.*?(video)[^$]*)$";
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:expression options:NSRegularExpressionCaseInsensitive error:nil];
        
        NSTextCheckingResult *match = [regex firstMatchInString:media_type options:0 range:NSMakeRange(0, [media_type length])];
        
        if (match){
            NSURL *url = [NSURL URLWithString:ImageUrls[@"expanded_url"]];
            self ->_imageURL = url;
            // Perform Segue to webview with URL data
            [self performSegueWithIdentifier:@"displayImage" sender:self->_imageURL];

        } else {
            NSURL *url = [NSURL URLWithString:ImageUrls[@"media_url"]];
            self->_imageURL = url;
            NSLog(@"Type of Tweet Clicked : %@",media_type);
            
            // Perform Segue to webview with URL data
            [self performSegueWithIdentifier:@"displayImage" sender:self->_imageURL];
            
        }
    }
    else {
        
        [self timelineNoImageExeptionThrow];
    }
}

/*
 Use Twitter REST API to get the tweets from user timeline
 Use asynchronous blocks to perform this operation in the background
 as this is a time consuming process
 */

- (void)getTimelineTweets {
    ACAccountStore *account = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [account
                                  accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        [account requestAccessToAccountsWithType:accountType
                                         options:nil completion:^(BOOL granted, NSError *error)
         {
             
             if (granted == YES)
             
             {
                 NSArray *arrayOfAccounts = [account
                                             accountsWithAccountType:accountType];
                 
                 if ([arrayOfAccounts count] > 0)
                 {
                     ACAccount *twitterAccount = [arrayOfAccounts lastObject];
                     
                     NSURL *requestURL = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/user_timeline.json"];
                     
                     NSMutableDictionary *parameters =
                     [[NSMutableDictionary alloc] init];
                     [parameters setObject:@"50" forKey:@"count"];
                     [parameters setObject:@"1" forKey:@"include_entities"];
                     
                     SLRequest *postRequest = [SLRequest
                                               requestForServiceType:SLServiceTypeTwitter
                                               requestMethod:SLRequestMethodGET
                                               URL:requestURL parameters:parameters];
                     
                     postRequest.account = twitterAccount;
                     
                     [postRequest performRequestWithHandler:
                      ^(NSData *responseData, NSHTTPURLResponse
                        *urlResponse, NSError *error)
                      {
                          self.dataSource = [NSJSONSerialization
                                             JSONObjectWithData:responseData
                                             options:NSJSONReadingMutableLeaves
                                             error:&error];
                          
                          if (self.dataSource.count != 0) {
                              dispatch_async(dispatch_get_main_queue(), ^{
                                  [self.tweetTableView reloadData];
                              });
                          }
                      }];
                 }
             } else {
                 // Handle failure to get account access
                 NSString *message = @"It seems that you have not yet allowed your app to use Twitter account. Please go to Settings to allow access ";
                 [self twitterExceptionHandling:message];
                 
             }
         }];
    } else {
        
        // Handle failure to get account access
        NSString *message = @"It seems that you have not yet added a Twitter account. Please go to Settings and add an account";
        [self twitterExceptionHandling:message];
        
    }
    
}

/*
 Exception Handling in case the user has not added a twitter account
 or has not authorized the app to use twitter credentials
 */

-(void)twitterExceptionHandling:(NSString *)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Oops!!!" message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       NSLog(@"User pressed Cancel");
                                   }];
    
    UIAlertAction *settingsAction = [UIAlertAction
                                     actionWithTitle:NSLocalizedString(@"Settings", @"Settings action")
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction *action)
                                     {
                                         NSLog(@"Settings Pressed");
                                         
                                         //code for opening settings app in iOS 8
                                         [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                                         
                                     }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:settingsAction];
    [self presentViewController:alertController animated:YES completion:nil];
    
}

/*
 Throw a message when the user selects a tweet with no media to show
 */

-(void)timelineNoImageExeptionThrow {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"No Image" message:@"This tweet has no image to display" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       NSLog(@"User pressed OK");
                                   }];
    
    
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

/*
 Bundle the media URL data to display in the Webview
 */
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    TwitterDisplayView *view = [segue destinationViewController];
    view.imageURL = self->_imageURL;
}


@end
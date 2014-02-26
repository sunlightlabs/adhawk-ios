//
//  RecorderViewController.m
//  adhawk
//
//  Created by Jim Snavely on 4/14/12.
//  Copyright (c) 2012 Sunlight Foundation 
//

#import "RecorderViewController.h"
#import "AdDetailViewController.h"
#import "AdhawkErrorViewController.h"
#import "InternalAdBrowserViewController.h"
#import "AdHawkLocationManager.h"
#import "Settings.h"
#import "AdHawkAPI.h"
#import "AdHawkAd.h"
#import "GetPCMFromFile.h"

@implementation RecorderViewController

@synthesize recordButton, workingBackground, failView;

- (NSString *)getAudioFilePath
{

    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(
                                                   NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = [dirPaths objectAtIndex:0];
    NSString *soundFilePath = [docsDir
                               stringByAppendingPathComponent:@"sound.caf"];

    return soundFilePath;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    failView = nil;
    _hawktivityAnimatedImageView = nil;

    // Audio Session setup
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryRecord error:nil];
    [audioSession setPreferredSampleRate:44100.0 error:nil];
    [audioSession setActive:YES withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleEnteredBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];

    [self setFailState:NO];
    
    [self setWorkingState:NO];

    // Recording setup. Audio session set up in AppDelegate
    NSString *soundFilePath = [self getAudioFilePath];                                
    NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
    NSDictionary *recordSettings = [NSDictionary 
                                    dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInt:AVAudioQualityMin],
                                    AVEncoderAudioQualityKey,
                                    [NSNumber numberWithInt:16], 
                                    AVEncoderBitRateKey,
                                    [NSNumber numberWithInt: 2], 
                                    AVNumberOfChannelsKey,
                                    [NSNumber numberWithFloat:44100.0], 
                                    AVSampleRateKey,
                                    nil];
    
    NSError *error = nil;
    
    audioRecorder = [[AVAudioRecorder alloc]
                     initWithURL:soundFileURL
                     settings:recordSettings
                     error:&error];

    if (error) {
        NSLog(@"error: %@", [error localizedDescription]);
        
    } else {
        [audioRecorder prepareToRecord];
    }

    [AdHawkLocationManager sharedInstance];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    if (_hawktivityAnimatedImageView != nil) {
        _hawktivityAnimatedImageView = nil;
    }

    if (failView != nil) {
        failView = nil;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    recordButton.hidden = NO;
    audioRecorder.delegate = self;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self setFailState:NO];

    if (audioRecorder.recording) {
        [audioRecorder stop];
        audioRecorder.delegate = nil;
    }
    [self setWorkingState:NO];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)handleEnteredBackground:(NSNotification *)notification
{
    [self setFailState:NO];
}

- (void)retryButtonClicked
{
    [self setFailState:NO];
    [self setWorkingState:YES];
    [self recordAudio];
}

- (void)setFailState:(BOOL)isFail
{
    if (isFail && failView == nil) {
        AdhawkErrorViewController *errorVC = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil]
                                              instantiateViewControllerWithIdentifier:@"ErrorViewController"];
        failView = errorVC.view;
        [errorVC.popularResultsButton addTarget:self action:@selector(showBrowseWebView) forControlEvents:UIControlEventTouchUpInside];
        [errorVC.tryAgainButton addTarget:self action:@selector(handleTVButtonTouch) forControlEvents:UIControlEventTouchUpInside];
        [errorVC.whyNoResultsButton addTarget:self action:@selector(handleWhyNoResultsTouch) forControlEvents:UIControlEventTouchUpInside];
    }

    if (isFail) {
        [self.view addSubview:failView];
        failView.frame = self.view.frame;
    } else {
        if ([failView isDescendantOfView:self.view]) {
            [failView removeFromSuperview];
        }
        failView = nil;
    }
}

- (void)setWorkingState:(BOOL)isWorking
{
    if (_hawktivityAnimatedImageView == nil) {
        UIImage *animImage = [UIImage animatedImageNamed:@"Animation_" duration:3.125];  
        _hawktivityAnimatedImageView = [[UIImageView alloc] initWithImage:animImage];
        _hawktivityAnimatedImageView.layer.position = recordButton.layer.position;
    }

    if (isWorking) {
        [self.view addSubview:_hawktivityAnimatedImageView];
        workingBackground.hidden = NO;
        recordButton.hidden = YES;
        recordButton.enabled = NO; 
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    } else {
        [_hawktivityAnimatedImageView removeFromSuperview];
        workingBackground.hidden = YES;
        recordButton.hidden = NO;
        recordButton.enabled = YES; 
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
   }
}

#pragma mark button touches

- (void)handleTVButtonTouch
{
    NSLog(@"handleTVButtonTouch run");

    AdHawkLocationManager *locationManager = [AdHawkLocationManager sharedInstance];
    NSTimeInterval locationUpdateFrequency = 1800; // 30 * 60seconds or 30 minutes
    BOOL hasLastLocation = [locationManager.lastBestLocation isKindOfClass:CLLocation.class];
    NSTimeInterval intervalSinceLastUpdate = -(locationManager.lastBestLocation.timestamp.timeIntervalSinceNow);

    if (intervalSinceLastUpdate >= locationUpdateFrequency || !hasLastLocation) {
        NSLog(@"Updating location...");
        [locationManager attemptLocationUpdateOver:20.0];
    } else {
        NSLog(@"Not updating location since locationManager.lastLocationUpdate is less than %f.", locationUpdateFrequency);
    }

    [self setWorkingState:YES];
    [self recordAudio];
}

- (void)showBrowseWebView
{
    InternalAdBrowserViewController *vc = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"InternalAdBrowserViewController"];
    vc.targetURL = [NSURL URLWithString:kAdHawkBrowseURL];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)handleWhyNoResultsTouch
{
    SimpleWebViewController *vc = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"SimpleWebViewController"];
    vc.targetURL = [NSURL URLWithString:kAdHawkTroubleshootingURL];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)recordAudio
{
    NSLog(@"Start recording audio");

    if (!audioRecorder.recording) {
        [self setFailState:NO];

        NSLog(@"Recording for a duration of %lf", kAdHawkRecordDuration);

        BOOL didRecord = [audioRecorder recordForDuration:kAdHawkRecordDuration];

        if (didRecord) {
            [self setWorkingState:YES];
        } else {
            NSLog(@"audioRecorder failed to start recording");
        }

        NSLog(@"Trying recordforDuration method... %@", (didRecord ? @"SUCCESS" : @"FAILURE"));
    }
}

- (void)stopRecorder
{
    [audioRecorder stop];
    [self handleRecordingFinished];
}

- (void)handleRecordingFinished
{    
    NSLog(@"Handle recording finished. Recorder %@ recording", (audioRecorder.recording ? @"IS" : @"IS NOT"));
    if (audioRecorder.recording) [audioRecorder stop]; else NSLog(@"Audio recorder stopped already, as expected");
    NSString *soundFilePath = [self getAudioFilePath];
    const char *fpCode = GetPCMFromFile((char *)[soundFilePath cStringUsingEncoding:NSASCIIStringEncoding]);
    NSString *fpCodeString = [NSString stringWithCString:fpCode encoding:NSASCIIStringEncoding];
    NSLog(@"Fingerprint generated");
    
//    [[AdHawkAPI sharedInstance] searchForAdWithFingerprint:kAdHawkTestFingerprint delegate:self];
    [[AdHawkAPI sharedInstance] searchForAdWithFingerprint:fpCodeString delegate:self];
    [audioRecorder deleteRecording];
}

- (void)adHawkAPIDidReturnAd:(AdHawkAd *)ad
{
    AdDetailViewController *vc = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"AdDetailViewController"];
    vc.targetURL = ad.resultURL;
    vc.shareText = ad.shareText;
    [self.navigationController pushViewController:vc animated:YES];
    [self setWorkingState:NO];
}

- (void)adHawkAPIDidReturnNoResult
{
    NSLog(@"No results for search");
    [self setWorkingState:NO];
    [self setFailState:YES];
}

- (void)adHawkAPIDidFailWithError:(NSError *)error
{
    NSLog(@"Fail error: %ld", (long)error.code);
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error.userInfo objectForKey:@"title"] message:[error.userInfo objectForKey:@"message"]
                                                       delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil]; 
    [alertView show];
    [self setWorkingState:NO];
}

#pragma mark AudioRecorderDelegate message handlers

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    NSLog(@"audioRecorderDidFinishRecording successully: %@", flag ? @"True" : @"False");
    [self handleRecordingFinished];
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error
{
    NSLog(@"Encode Error occurred");
}

- (void)audioRecorderBeginInterruption:(AVAudioRecorder *)recorder
{
    TFLog(@"Audio recording interrupted. Should only happen during a call or something.");
}

- (void)audioRecorderEndInterruption:(AVAudioRecorder *)recorder
{
    TFLog(@"Audio recording resumed.");
}

@end

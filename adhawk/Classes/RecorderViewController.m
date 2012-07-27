//
//  RecorderViewController.m
//  adhawk
//
//  Created by Jim Snavely on 4/14/12.
//  Copyright (c) 2012 Sunlight Foundation 
//

#import "RecorderViewController.h"
#import "AdDetailViewController.h"
#import "InternalAdBrowserViewController.h"
#import "Settings.h"
#import "AdHawkAPI.h"
#import "AdHawkAd.h"


extern const char * GetPCMFromFile(char * filename);

@implementation RecorderViewController

@synthesize recordButton, popularResultsButton, workingBackground, failView, activityIndicator;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (NSString*) getAudioFilePath {

    NSArray * dirPaths = NSSearchPathForDirectoriesInDomains(
                                                   NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = [dirPaths objectAtIndex:0];
    NSString *soundFilePath = [docsDir
                               stringByAppendingPathComponent:@"sound.caf"];
    return soundFilePath;
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    [[AdHawkAPI sharedInstance] searchForAdWithFingerprint:TEST_FINGERPRINT delegate:self];

    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(handleEnteredBackground:) 
                                                 name: UIApplicationDidEnterBackgroundNotification
                                               object: nil];
    [self setFailState:NO];
    [self setWorkingState:NO];
    
    recordButton.enabled = YES;
    [recordButton setImage:[UIImage imageNamed:@"IDbtndown"] forState:UIControlStateHighlighted];
    
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
    
    if (error)
    {
        NSLog(@"error: %@", [error localizedDescription]);
        
    } else {
        [audioRecorder prepareToRecord];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    recordButton.hidden = NO;
}

- (void) viewDidDisappear:(BOOL)animated
{
    [self setFailState:NO];
    if (audioRecorder.recording) {
        [audioRecorder stop];
        [_timer invalidate];
    }
    [self setWorkingState:NO];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) handleEnteredBackground:(NSNotification *)notification
{
    [self setFailState:NO];
}

- (void) retryButtonClicked
{
    [self setFailState:NO];
    [self recordAudio];
}

-(void) setFailState:(BOOL)isFail
{
    failView.hidden = !isFail;
}

- (void)setWorkingState:(BOOL)isWorking
{
    if (isWorking) {
        workingBackground.hidden = NO;
        recordButton.hidden = YES;
        recordButton.enabled = NO; 
    }
    else {
        workingBackground.hidden = YES;
        recordButton.hidden = NO;
        recordButton.enabled = YES; 
   }
}

-(void) recordAudio
{
    if (!audioRecorder.recording)
    {
        [self setFailState:NO];
        [self setWorkingState:YES];
        _timer = [NSTimer scheduledTimerWithTimeInterval:15.0
                                         target:self
                                       selector:@selector(recordingTimerFinished:)
                                       userInfo:nil
                                        repeats:NO];
        [audioRecorder record];
        [activityIndicator startAnimating];
    }
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [super prepareForSegue:segue sender:sender];
    if ([[segue identifier] isEqualToString:@"adSegue"])
    {
        // Get reference to the destination view controller
        AdDetailViewController *vc = [segue destinationViewController];
        NSLog(@"Segue to AdDetailView");
        
        // Pass any objects to the view controller here, like...
        NSURL *targetURL = [AdHawkAPI sharedInstance].currentAdHawkURL;
        [vc setTargetURLString:[targetURL absoluteString]];
    }
}

- (void) recordingTimerFinished:(NSTimer*)theTimer
{
    
    TFPLog(@"Timer complete");
    [self stopRecorder];
}

-(void)stopRecorder
{    
    if (audioRecorder.recording)
    {
        [audioRecorder stop];
        NSString *soundFilePath = [self getAudioFilePath];
        const char * fpCode = GetPCMFromFile((char*) [soundFilePath cStringUsingEncoding:NSASCIIStringEncoding]);
        NSString *fpCodeString = [NSString stringWithCString:fpCode encoding:NSASCIIStringEncoding];
        NSLog(@"fpcode generated");
        
//        [[AdHawkAPI sharedInstance] searchForAdWithFingerprint:TEST_FINGERPRINT delegate:self];
        [[AdHawkAPI sharedInstance] searchForAdWithFingerprint:fpCodeString delegate:self];
        
        [activityIndicator stopAnimating];

    } else if (audioPlayer.playing) {
        [audioPlayer stop];
    }
}


-(void) playAudio
{
    if (!audioRecorder.recording)
    {
        NSError *error;
        
        audioPlayer = [[AVAudioPlayer alloc] 
                       initWithContentsOfURL:audioRecorder.url                                    
                       error:&error];
        
        audioPlayer.delegate = self;
        
        if (error)
            NSLog(@"Error: %@", 
                  [error localizedDescription]);
        else
            [audioPlayer play];
    }
}

-(void)audioPlayerDidFinishPlaying:
(AVAudioPlayer *)player successfully:(BOOL)flag
{
    recordButton.enabled = YES;
}

-(void)audioPlayerDecodeErrorDidOccur:
(AVAudioPlayer *)player 
                                error:(NSError *)error
{
    NSLog(@"Decode Error occurred");
}
-(void)audioRecorderDidFinishRecording:
(AVAudioRecorder *)recorder 
                          successfully:(BOOL)flag
{
}
-(void)audioRecorderEncodeErrorDidOccur: (AVAudioRecorder *)recorder error:(NSError *)error
{
    NSLog(@"Encode Error occurred");
}


-(void) adHawkAPIDidReturnURL:(NSURL *)url
{
//    [self performSegueWithIdentifier:@"adSegue" sender:self];
    AdDetailViewController *vc = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"adDetailVC"];
    [vc setTargetURLString:[url absoluteString]];
    [self.navigationController pushViewController:vc animated:YES];
    [self setWorkingState:NO];
}

-(void) adHawkAPIDidReturnNoResult
{
    TFPLog(@"No results for search");
    [self setWorkingState:NO];
    [self setFailState:YES];
}

-(void)showBrowseWebView
{
    InternalAdBrowserViewController *vc = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"internalBrowserVC"];
    NSURL *browseURL = [NSURL URLWithString:ADHAWK_BROWSE_URL];
    [self.navigationController pushViewController:vc animated:YES];
    [vc.webView loadRequest:[NSURLRequest requestWithURL:browseURL]];
}


@end

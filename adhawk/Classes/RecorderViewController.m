//
//  RecorderViewController.m
//  adhawk
//
//  Created by Jim Snavely on 4/14/12.
//  Copyright (c) 2012 Sunlight Foundation 
//

#import "RecorderViewController.h"
#import "AdDetailViewController.h"
#import "Settings.h"
#import "AdHawkAPI.h"
#import "AdHawkAd.h"


#define NSLog(__FORMAT__, ...) TFLog((@"%s [Line %d] " __FORMAT__), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)

extern const char * GetPCMFromFile(char * filename);


@implementation RecorderViewController

//@synthesize recorderDelegate;
@synthesize playButton, stopButton, recordButton, activityIndicator;


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
    
    playButton.enabled = NO;
    stopButton.enabled = NO;
    
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



-(void) recordAudio
{
    if (!audioRecorder.recording)
    {
        playButton.enabled = NO;
        stopButton.enabled = YES;
        [NSTimer scheduledTimerWithTimeInterval:15.0
                                         target:self
                                       selector:@selector(stop)
                                       userInfo:nil
                                        repeats:NO];
        [audioRecorder record];
        [recordButton setTitle:@"Recording..." forState:UIControlStateNormal];
        [activityIndicator startAnimating];
    }
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"adSegue"])
    {
        // Get reference to the destination view controller
        AdDetailViewController *vc = [segue destinationViewController];
        NSLog(@"Segue to AdDetailView");
        
        // Pass any objects to the view controller here, like...
        NSURL *targetURL = [AdHawkAPI sharedInstance].currentAdHawkURL;
        [vc setTargetURL:[targetURL absoluteString]];
    }
}

-(void)stop
{
    stopButton.enabled = NO;
    playButton.enabled = YES;
    recordButton.enabled = YES;
    
    if (audioRecorder.recording)
    {
        [audioRecorder stop];
        [recordButton setTitle:@"Identify Ad" forState:UIControlStateNormal];
        NSString *soundFilePath = [self getAudioFilePath];
        const char * fpCode = GetPCMFromFile((char*) [soundFilePath cStringUsingEncoding:NSASCIIStringEncoding]);
        NSString *fpCodeString = [NSString stringWithCString:fpCode encoding:NSASCIIStringEncoding];
        NSLog(@"fpcode generated");
        
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
        stopButton.enabled = YES;
        recordButton.enabled = NO;
        
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
    stopButton.enabled = NO;
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
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self performSegueWithIdentifier:@"adSegue" sender:self];
}

@end

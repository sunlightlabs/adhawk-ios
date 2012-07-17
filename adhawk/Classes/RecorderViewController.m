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
#import "AdHawkQuery.h"

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
        [vc setTargetURL:[[AdHawkAPI sharedInstance].currentAd.result_url absoluteString]];
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
        
        NSMutableDictionary* birdIsTheWord = [NSMutableDictionary dictionaryWithCapacity:0];
        [birdIsTheWord setObject:fpCodeString forKey:@"fingerprint"];
        [birdIsTheWord setObject:[NSNumber numberWithInt:0] forKey:@"lat"];
        [birdIsTheWord setObject:[NSNumber numberWithInt:0] forKey:@"lon"];
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        RKObjectManager* manager = [RKObjectManager sharedManager];
        [manager loadObjectsAtResourcePath:@"/ad/" usingBlock:^(RKObjectLoader * loader) {
            loader.serializationMIMEType = RKMIMETypeJSON;
            loader.objectMapping = [manager.mappingProvider objectMappingForClass:[AdHawkAd class]];
            loader.resourcePath = @"/ad/";
            loader.method = RKRequestMethodPOST;
            loader.delegate = self;
            [loader setBody:birdIsTheWord forMIMEType:RKMIMETypeJSON];
            [TestFlight passCheckpoint:@"Submitted Fingerprint"];
        }];
        
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

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
    NSLog(@"Load did fail with error: %@", error.localizedDescription);
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObject:(id)object {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    if ([object isKindOfClass:[AdHawkAd class]]) {
        NSLog(@"Got back an AdHawkAd object!");
        [AdHawkAPI sharedInstance].currentAd = (AdHawkAd *)object;
        [self performSegueWithIdentifier:@"adSegue" sender:self];
    }
    else {
        NSLog(@"Got back an object, but it didn't conform to AdHawkAd");
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Server Error" message:@"The server didn't return data AdHawk could identify" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil]; 
        [alertView show];
    }
}


@end

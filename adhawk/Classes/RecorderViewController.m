//
//  RecorderViewController.m
//  adhawk
//
//  Created by Jim Snavely on 4/14/12.
//  Copyright (c) 2012 Cuibono 
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
@synthesize playButton, stopButton, recordButton;


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
        
    NSMutableDictionary* birdIsTheWord = [NSMutableDictionary dictionaryWithCapacity:0];
    [birdIsTheWord setObject:TEST_FINGERPRINT forKey:@"fingerprint"];
    [birdIsTheWord setObject:[NSNumber numberWithInt:0] forKey:@"lat"];
    [birdIsTheWord setObject:[NSNumber numberWithInt:0] forKey:@"lon"];

    RKObjectManager* manager = [RKObjectManager sharedManager];
        [manager loadObjectsAtResourcePath:@"/ad/" usingBlock:^(RKObjectLoader * loader) {
            loader.serializationMIMEType = RKMIMETypeJSON;
            loader.objectMapping = [manager.mappingProvider objectMappingForClass:[AdHawkAd class]];
            loader.resourcePath = @"/ad/";
            loader.method = RKRequestMethodPOST;
            [loader setBody:birdIsTheWord forMIMEType:RKMIMETypeJSON];
        }];

    
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
    }
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"adSegue"])
    {
        // Get reference to the destination view controller
        AdDetailViewController *vc = [segue destinationViewController];

        
        // Pass any objects to the view controller here, like...
        [vc setTargetURL:@"http://news.google.com"];
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
//        const char * fpCode = GetPCMFromFile((char*) [soundFilePath cStringUsingEncoding:NSASCIIStringEncoding]);
        
        NSLog(@"fpcode generated");

//        [self.recorderDelegate recorderDidGenerateFingerPrint:[NSString stringWithCString:fpCode encoding:NSASCIIStringEncoding]];

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
-(void)audioRecorderEncodeErrorDidOccur:
(AVAudioRecorder *)recorder 
                                  error:(NSError *)error
{
    NSLog(@"Encode Error occurred");
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
    NSLog(@"Load did fail with error: %@", error.localizedDescription);
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObject:(id)object {
    NSLog(@"LOADED OBJECT!!!!");
}


@end

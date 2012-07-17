//
//  RecorderViewController.h
//  adhawk
//
//  Created by Jim Snavely on 4/14/12.
//  Copyright (c) 2012 Cuibono. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

//@protocol RecorderViewDelegate <NSObject>
//@required
//- (void) recorderDidGenerateFingerPrint:(NSString *)fingerprint;
//@end

@interface RecorderViewController : UIViewController
<AVAudioRecorderDelegate, AVAudioPlayerDelegate, RKObjectLoaderDelegate>
{
    AVAudioRecorder *audioRecorder;
    AVAudioPlayer *audioPlayer;
    UIButton *playButton;
    UIButton *recordButton;
    UIButton *stopButton;
    UIActivityIndicatorView *activityIndicator;
}
//@property (nonatomic, retain) id <RecorderViewDelegate> recorderDelegate;
@property (nonatomic, strong) IBOutlet UIButton *playButton;
@property (nonatomic, strong) IBOutlet UIButton *recordButton;
@property (nonatomic, strong) IBOutlet UIButton *stopButton;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;
-(IBAction) recordAudio;
-(IBAction) playAudio;
-(IBAction) stop;
@end
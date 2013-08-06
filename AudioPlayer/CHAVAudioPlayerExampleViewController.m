//
//  CHAVAudioPlayerExampleViewController.m
//  AudioPlayer
//
//  Created by Eoin McCarthy on 5/08/13.
//  Copyright (c) 2013 Hydric Media Pty Ltd. All rights reserved.
//

#import "CHAVAudioPlayerExampleViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <MediaPlayer/MediaPlayer.h>

#import "NSMutableArray+CHQueueAdditions.h"


#define NUM_OF_FRAMES 120.

#define USE_MPVOLUME 0

#define USE_MPNOWPLAYING 0

@interface CHAVAudioPlayerExampleViewController () <MPMediaPickerControllerDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) CADisplayLink	*updateTimer;
@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic, strong) NSArray *layers;
@property (nonatomic, strong) NSMutableArray *framesLeft;
@property (nonatomic, strong) NSMutableArray *framesRight;
@property (nonatomic, strong) NSArray *framesArr;

@property (nonatomic, weak) IBOutlet UIView *graphView;
@property (nonatomic, weak) IBOutlet UIView *mpVolumeViewParentView;

@end

@implementation CHAVAudioPlayerExampleViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	NSError *setCategoryError = nil;
	[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error: &setCategoryError];
    self.framesLeft = [NSMutableArray array];
    self.framesRight = [NSMutableArray array];
    
    for(int i=0;i<NUM_OF_FRAMES;i++) {
        [self.framesLeft insertObject:[NSNumber numberWithFloat:0.] atIndex:i];
        [self.framesRight insertObject:[NSNumber numberWithFloat:0.] atIndex:i];
    }
    self.framesArr = @[self.framesLeft, self.framesRight];
    [self setupLayers];
    
#if USE_MPVOLUME
    self.mpVolumeViewParentView.backgroundColor = [UIColor clearColor];
    MPVolumeView *myVolumeView = [[MPVolumeView alloc] initWithFrame:self.mpVolumeViewParentView.bounds];
    myVolumeView.showsRouteButton = YES;
    [self.mpVolumeViewParentView addSubview:myVolumeView];
#endif
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(play) name:@"play" object:nil];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillDisappear:(BOOL)animated
{
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)refresh
{
    [_player updateMeters];
    
    for(int i=0;i<[_player numberOfChannels];i++) {
        [self drawPath:i];
    }
}

- (void)setupLayers
{
    CAShapeLayer *leftLayer = [CAShapeLayer layer];
    CAShapeLayer *rightLayer = [CAShapeLayer layer];
    
    [leftLayer setStrokeColor:[[UIColor colorWithRed:20./255. green:20./255. blue:240./255. alpha:1.0] CGColor]];
        leftLayer.lineWidth = 1.f;
    leftLayer.fillColor = leftLayer.strokeColor;
    
    [rightLayer setStrokeColor:[[UIColor colorWithRed:240./255. green:20./255. blue:20./255. alpha:1.0] CGColor]];
    rightLayer.lineWidth = 1.f;
    rightLayer.fillColor = [[UIColor colorWithRed:240./255. green:20./255. blue:20./255. alpha:0.3] CGColor];

    
    [self.graphView.layer addSublayer:leftLayer];
    [self.graphView.layer addSublayer:rightLayer];
    
    _layers = @[leftLayer, rightLayer];
}

- (void)drawPath:(NSInteger)channel
{
    NSMutableArray* frames = [self.framesArr objectAtIndex:channel];
    float dbs = [_player averagePowerForChannel:channel];
    float unitDbs = 1.-logx(-dbs, 160.);
    unitDbs = MIN(1., unitDbs);
    unitDbs = unitDbs-0.3f;

    [frames dequeue];
    [frames enqueue:[NSNumber numberWithFloat:unitDbs]];
    
    UIBezierPath *path = [[UIBezierPath alloc] init];
    
    float BASELINE_OFFSET = 180.;
    float LENGTH = 300.;
    float DRAWABLE_LENGTH = 250.;
    float MAX_HEIGHT = 200.0f;
    
    [path moveToPoint:CGPointMake(10., BASELINE_OFFSET)];
    
    float increment = DRAWABLE_LENGTH/frames.count;
    
    for(int i=0;i<frames.count;i++) {
        float level = [[frames objectAtIndex:i] floatValue];
        float damping = logx(i+1, NUM_OF_FRAMES);
        float yOffset = level*MAX_HEIGHT*damping;
        yOffset = -yOffset;
        [path addLineToPoint:CGPointMake(10.+increment*i, BASELINE_OFFSET + yOffset) ];
    }
    
    
    [path addLineToPoint:CGPointMake(10.+LENGTH, BASELINE_OFFSET)];
    [path addLineToPoint:CGPointMake(10., BASELINE_OFFSET)];
    
    CAShapeLayer* layer = [_layers objectAtIndex:channel];
    layer.path = [path CGPath];
}

- (void)play:(NSURL*)fileURL
{
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
    self.player.meteringEnabled = YES;
//#if MPNOWPLAYING
    MPNowPlayingInfoCenter* infoCenter = [MPNowPlayingInfoCenter defaultCenter];
    MPMediaItemArtwork* cover = [[MPMediaItemArtwork alloc] initWithImage:[UIImage imageNamed:@"hydric-app-icon"]];
    
    NSDictionary* infoDict = @{MPMediaItemPropertyArtist : @"Hydric Media", MPMediaItemPropertyTitle : @"Track Title", MPMediaItemPropertyArtwork : cover};
    [infoCenter setNowPlayingInfo:infoDict];
//#endif
    [self start];
}

- (void)togglePlayPause
{
    if(self.player.isPlaying) {
       [self.player pause];
    } else {
        [self.player play];
    }
    
}
- (void)stop
{
    [_updateTimer invalidate];
    [_player stop];
}

- (void)start
{
    if (_updateTimer) [_updateTimer invalidate];
    _updateTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(refresh)];
    [_updateTimer addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_player play];
}

float logx(float value, float base)
{
    return log10f(value) / log10f(base);
}

- (IBAction)setTrack:(id)sender
{
    [self stop];
#if TARGET_IPHONE_SIMULATOR
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"This needs a real device" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
    
#else
    MPMediaPickerController* picker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeAnyAudio];
    picker.delegate = self;
    picker.prompt =
    NSLocalizedString (@"Add songs to play",
                       "Prompt in media item picker");
    picker.allowsPickingMultipleItems = NO;
    [self presentViewController:picker animated:YES completion:nil];
#endif
}

- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection
{
    MPMediaItem* item = [[mediaItemCollection items] lastObject];
    [self play:[item valueForProperty:MPMediaItemPropertyAssetURL]];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSString* filepath = [[NSBundle mainBundle] pathForResource:@"UntrustUs" ofType:@"mp3"];
//    NSString* filepath = [[NSBundle mainBundle] pathForResource:@"Holocene" ofType:@"m4a"];
    NSURL* url = [[NSURL alloc] initFileURLWithPath:filepath];
    [self play:url];

}

- (void)remoteControlReceivedWithEvent:(UIEvent*)receivedEvent {
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        switch (receivedEvent.subtype) {
            case UIEventSubtypeRemoteControlPlay:
                [self togglePlayPause];
                break;
            case UIEventSubtypeRemoteControlPause:
                [self togglePlayPause];
                break;

            default:
                break;
        }
    }
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}
@end

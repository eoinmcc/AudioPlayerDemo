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



@interface CHAVAudioPlayerExampleViewController () <MPMediaPickerControllerDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic, strong) CADisplayLink	*updateTimer;

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
    
//	[[AVAudioSession sharedInstance] setDelegate: self];
	NSError *setCategoryError = nil;
	[[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: &setCategoryError];
    self.framesLeft = [NSMutableArray array];
    self.framesRight = [NSMutableArray array];
    
    for(int i=0;i<200;i++) {
        [self.framesLeft insertObject:[NSNumber numberWithFloat:0.] atIndex:i];
        [self.framesRight insertObject:[NSNumber numberWithFloat:0.] atIndex:i];
    }
    self.framesArr = @[self.framesLeft, self.framesRight];
    [self setupLayers];
    
    self.mpVolumeViewParentView.backgroundColor = [UIColor clearColor];
    MPVolumeView *myVolumeView =
    [[MPVolumeView alloc] initWithFrame:self.mpVolumeViewParentView.bounds];
    [self.mpVolumeViewParentView addSubview:myVolumeView];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self stop];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    leftLayer.fillColor = [[UIColor clearColor] CGColor];
    
    [rightLayer setStrokeColor:[[UIColor colorWithRed:240./255. green:20./255. blue:20./255. alpha:1.0] CGColor]];
    rightLayer.lineWidth = 1.f;
    rightLayer.fillColor = [[UIColor clearColor] CGColor];

    
    [self.graphView.layer addSublayer:leftLayer];
    [self.graphView.layer addSublayer:rightLayer];
    
    _layers = @[leftLayer, rightLayer];
}

- (void)drawPath:(NSInteger)channel
{
    NSMutableArray* frames = [self.framesArr objectAtIndex:channel];
    float dbs = [_player averagePowerForChannel:channel];
    float unitDbs = logx(-dbs, 160.);

    unitDbs = MAX(0, unitDbs);
    NSLog(@"%g",unitDbs);
    [frames dequeue];
    [frames enqueue:[NSNumber numberWithFloat:unitDbs]];
    
    UIBezierPath *path = [[UIBezierPath alloc] init];
    
    float BASELINE_OFFSET = 100.;
    float LENGTH = 300.;
    float MAX_HEIGHT = 100.0f;
    float EXAGGERATION = 2.f;
    
    [path moveToPoint:CGPointMake(10., BASELINE_OFFSET)];
    
    float increment = LENGTH/frames.count;
    
    for(int i=0;i<frames.count;i++) {
        float level = [[frames objectAtIndex:i] floatValue];
        float damping = frames.count-i;
        damping = 1.0f;

        float yOffset = EXAGGERATION*50. - EXAGGERATION*level*MAX_HEIGHT/damping;
        
        yOffset = MAX(-yOffset, 0.);
        yOffset = channel == 0 ? yOffset : -yOffset;
        [path addLineToPoint:CGPointMake(10.+increment*i, BASELINE_OFFSET + yOffset) ];
    }
    
    
    [path addLineToPoint:CGPointMake(10.+LENGTH, BASELINE_OFFSET)];
    [path addLineToPoint:CGPointMake(10., BASELINE_OFFSET)];
    
    CAShapeLayer* layer = [_layers objectAtIndex:channel];
    layer.path = [path CGPath];
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
#ifdef TARGET_IPHONE_SIMULATOR
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
    
}

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker
{
    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
//    NSString* filepath = [[NSBundle mainBundle] pathForResource:@"UntrustUs" ofType:@"mp3"];
    NSString* filepath = [[NSBundle mainBundle] pathForResource:@"Holocene" ofType:@"m4a"];
    NSURL* url = [[NSURL alloc] initFileURLWithPath:filepath];
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    self.player.meteringEnabled = YES;    
    [self start];

}
@end

//
//  CHAVPlayerViewController.m
//  AudioDemo
//
//  Created by Eoin McCarthy on 6/08/13.
//  Copyright (c) 2013 Hydric Media Pty Ltd. All rights reserved.
//

#import "CHAVPlayerViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface CHAVPlayerViewController ()

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, weak) IBOutlet UILabel *state;
@property (nonatomic, weak) IBOutlet UIButton *playButton;

@end

@implementation CHAVPlayerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)setupRemote:(id)sender
{

    NSURL* URL = [NSURL URLWithString:@"http://50.56.91.184/choons/08%20Sound%20Of%20Silver.m4a"];
    self.player = [AVPlayer playerWithURL:URL];
    [self.player addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:nil];
}

- (IBAction)playRemote:(id)sender
{

    [self.player play];
    [self.player.currentItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:nil];
    
    [self.player addPeriodicTimeObserverForInterval:CMTimeMake(5, 100) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        CMTimeShow(time);
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
            self.state.text = weakSelf.player.currentItem.playbackLikelyToKeepUp ? @"Will Keep Up" : @"Won't keep up";
        } else {
            switch(weakSelf.player.status) {
                case AVPlayerStatusFailed:
                    weakSelf.state.text = @"Failed";
                    break;
                case AVPlayerStatusReadyToPlay:
                    weakSelf.state.text = @"Ready to Play";
                    weakSelf.playButton.enabled = YES;
                    break;
                case AVPlayerStatusUnknown:
                    weakSelf.state.text = @"Unknown";
            }
        }
    });
    
}
@end

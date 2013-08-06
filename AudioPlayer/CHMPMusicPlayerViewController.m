//
//  CHMPMusicPlayerViewController.m
//  AudioPlayer
//
//  Created by Eoin McCarthy on 6/08/13.
//  Copyright (c) 2013 Hydric Media Pty Ltd. All rights reserved.
//

#import "CHMPMusicPlayerViewController.h"
#import <MediaPlayer/MediaPlayer.h>

@interface CHMPMusicPlayerViewController () <MPMediaPickerControllerDelegate>

@property (nonatomic, strong) MPMusicPlayerController* player;
@property (nonatomic, strong) MPMediaItemCollection* queue;
@end

@implementation CHMPMusicPlayerViewController

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
    self.player = [MPMusicPlayerController iPodMusicPlayer];

	// Do any additional setup after loading the view.
}

- (IBAction)back:(id)sender
{
    [self.player skipToPreviousItem];
}
- (IBAction)next:(id)sender
{
    [self.player skipToNextItem];
}


- (IBAction)play:(id)sender
{
    if(self.queue) {
        if([self.player playbackState] == MPMusicPlaybackStatePlaying) {
            [self.player pause];
        } else if([self.player playbackState] == MPMusicPlaybackStatePaused) {
            [self.player play];
        } else {
            [self.player setQueueWithItemCollection:self.queue];
            [self.player play];
        }
    } else {
        [self setTrack];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setTrack
{
#if TARGET_IPHONE_SIMULATOR
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"This needs a real device" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
    
#else
    MPMediaPickerController* picker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeAnyAudio];
    picker.delegate = self;
    picker.allowsPickingMultipleItems = YES;
    picker.prompt =
    NSLocalizedString (@"Add songs to play",
                       "Prompt in media item picker");
    [self presentViewController:picker animated:YES completion:nil];
#endif
}

- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection
{
    self.queue = mediaItemCollection;
    [self play:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end

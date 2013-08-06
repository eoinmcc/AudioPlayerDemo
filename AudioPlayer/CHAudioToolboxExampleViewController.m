//
//  CHAudioToolboxExampleViewController.m
//  AudioPlayer
//
//  Created by Eoin McCarthy on 6/08/13.
//  Copyright (c) 2013 Hydric Media Pty Ltd. All rights reserved.
//

#import "CHAudioToolboxExampleViewController.h"

#import <AudioToolbox/AudioToolbox.h>

@interface CHAudioToolboxExampleViewController ()

@property (readwrite) SystemSoundID jump;
@property (readwrite) SystemSoundID coin;
@property (readwrite) SystemSoundID mushroom;

@end

@implementation CHAudioToolboxExampleViewController


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
    
    NSURL *tapSound   = [[NSBundle mainBundle] URLForResource: @"smb1"
                                                withExtension: @"caf"];
    
    CFURLRef soundFileURLRef = (__bridge CFURLRef)(tapSound);
    
    AudioServicesCreateSystemSoundID (soundFileURLRef,&_jump);
    tapSound   = [[NSBundle mainBundle] URLForResource: @"smb2"
                                                withExtension: @"caf"];
    
    soundFileURLRef = (__bridge CFURLRef)(tapSound);
    
    AudioServicesCreateSystemSoundID (soundFileURLRef, &_coin);
    tapSound   = [[NSBundle mainBundle] URLForResource: @"smb3"
                                         withExtension: @"caf"];
    
    soundFileURLRef = (__bridge CFURLRef)(tapSound);
    
    AudioServicesCreateSystemSoundID (
                                      soundFileURLRef,
                                      &_mushroom
                                      );

}

- (void)viewDidDisappear:(BOOL)animated
{
    AudioServicesDisposeSystemSoundID(_jump);
    AudioServicesDisposeSystemSoundID(_coin);
    AudioServicesDisposeSystemSoundID(_mushroom);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)playTone:(id)sender
{
    switch ([sender tag]) {
        case 0:
            AudioServicesPlayAlertSound(_jump);
            break;
        case 1:
            AudioServicesPlaySystemSound(_coin);
            break;
        case 2:
            AudioServicesPlaySystemSound(_mushroom);
            break;
        case 3:
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            break;
        default:
            break;
    }
}
@end

//
//  AudioManager.m
//  Tetris
//
//  Created by Vahe Karamyan on 27.08.17.
//  Copyright © 2017 Vahe Karamyan. All rights reserved.
//

#import "AudioManager.h"

@implementation AudioManager

-(void)playBackground
{
    NSString *background = [[NSBundle mainBundle] pathForResource:@"backgroundMusic" ofType:@"wav"];
    self.backgroundPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:background]
                                                                   error:nil];;
    self.backgroundPlayer.numberOfLoops = -1;
    self.backgroundPlayer.delegate = self;
    [self.backgroundPlayer play];

}

-(void)stopBackground
{
    [self.backgroundPlayer stop];
}

-(void)playMoveDown
{
    NSString *effect = [[NSBundle mainBundle] pathForResource:@"move" ofType:@"wav"];
    self.effectsPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:effect]
                                                                error:nil];
    self.effectsPlayer.delegate = self;
    [self.effectsPlayer play];
}

-(void)playLevelUp
{
    NSString *effect = [[NSBundle mainBundle] pathForResource:@"levelup" ofType:@"wav"];
    self.effectsPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:effect]
                                                                error:nil];
    self.effectsPlayer.delegate = self;
    [self.effectsPlayer play];
}

-(void)playDeleteRow
{
    NSString *effect = [[NSBundle mainBundle] pathForResource:@"rowClear" ofType:@"wav"];
    self.effectsPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:effect]
                                                                error:nil];
    self.effectsPlayer.delegate = self;
    [self.effectsPlayer play];

}
@end

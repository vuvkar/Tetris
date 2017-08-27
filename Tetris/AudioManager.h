//
//  AudioManager.h
//  Tetris
//
//  Created by Vahe Karamyan on 27.08.17.
//  Copyright © 2017 Vahe Karamyan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface AudioManager : NSObject <AVAudioPlayerDelegate>

@property (nonatomic, strong) AVAudioPlayer *backgroundPlayer;
@property (nonatomic, strong) AVAudioPlayer *effectsPlayer;

-(void)playBackground;
-(void)stopBackground;
-(void)playMoveDown;
-(void)playLevelUp;
-(void)playDeleteRow;


@end

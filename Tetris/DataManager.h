//
//  DataManager.h
//  Tetris
//
//  Created by Vahe Karamyan on 24.08.17.
//  Copyright © 2017 Vahe Karamyan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataManager : NSObject

@property NSString *currentPlayerName;
@property NSNumber *currentGameScore;
@property NSNumber *currentGameLevel;


@property NSMutableDictionary *allData;

-(instancetype)sharedManaer;

-(void)saveCurrentGame;
-(void)saveAllData;
-(void)load;

-(int)highestScore;


@end

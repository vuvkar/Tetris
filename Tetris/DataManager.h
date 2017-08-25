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

@property int highestScore;

@property NSMutableDictionary *allData;

+(instancetype)sharedManaer;

-(void)saveCurrentGameWithScore:(int)score andLevel:(int)level;
-(void)saveAllData;
-(void)load;
-(void)firstSetup;
-(void)changeUsername:(NSString *)username;

@end

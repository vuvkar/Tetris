//
//  GameEngine.h
//  Tetris
//
//  Created by Vahe Karamyan on 15.08.17.
//  Copyright © 2017 Vahe Karamyan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Definitions.h"
#import "Figure.h"
@class Figure;

@protocol GameEngineDelegate <NSObject>

-(void)rowsAreDeleted:(NSMutableArray <NSNumber *> *)rows;
-(void)newFigureIsCreated:(Figure*)figure;

@end

@interface GameEngine : NSObject

@property (nonatomic) NSMutableArray <NSMutableArray *> *board;
@property int score;
@property int level;
@property double tactSpeed;
@property Figure *currentFigure;
@property Figure *generatedFigure;
@property (weak) id <GameEngineDelegate> delegate;
@property NSTimer *timer;
@property BOOL isItTimeToCreateNewFigure;
@property BOOL shouldTheFigureGoLeftOrRight;
@property Directions goingDirection;
@property BOOL shouldRotate;

+(instancetype)sharedEngine;

-(void)deleteRows;
-(void)generateNewFigure;
-(void)startTact;
-(void)moveCurrentFigure;
-(void)startFalling;
-(BOOL)isPossibleToRotate;

@end

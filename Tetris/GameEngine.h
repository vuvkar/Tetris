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

-(void)newFigureIsGenerated:(Figure*)figure;
-(void)newFigureIsCreated:(Figure*)figure withAnchor:(MatrixPoint *)anchor;
-(void)rowsAreDeleted:(NSMutableArray <NSNumber *> *)rows;
-(void)figureIsRotated:(Figure *)figure withAnchor:(MatrixPoint *)anchor;
-(void)figureHasChangedPlace:(Directions)direction withCount:(int)count;
-(void)levelIsChanged:(int)newLevel;
-(void)pauseGame;
-(void)gameIsEnded;
-(void)stickFigure;

@end

@interface GameEngine : NSObject

@property (nonatomic) NSMutableArray <NSMutableArray *> *board;
@property int score;
@property int deletedRows;
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
@property BOOL isLastMove;
@property BOOL didSwipeDown;
@property BOOL isGameEnded;
@property NSMutableArray <MatrixPoint *> *figureTakenPlaces;
@property MatrixPoint *figureAnchorPoint;


+(instancetype)sharedEngine;

-(void)deleteRows;
-(void)generateNewFigure;
-(void)startTact;
-(void)createFigure;
-(BOOL)isPossibleToRotate;
-(void)forceDown;
-(void)endGame;
-(void)clearBoard;
-(void)startGame;

@end

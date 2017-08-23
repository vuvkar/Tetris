//
//  Figure.h
//  Tetris
//
//  Created by Vahe Karamyan on 15.08.17.
//  Copyright © 2017 Vahe Karamyan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MatrixPoint.h"
#import "Definitions.h"
#import "GameEngine.h"
@class Figure;

@protocol FigureDelegate <NSObject>

-(void)moveFigureDown:(Figure*)figure andHowManyRows:(int)rows;
-(void)moveFigure:(Figure*)figure;
-(void)rotateFigure:(Figure*)figure;

@end

@interface Figure : NSObject

@property NSArray <NSArray <NSNumber *> *>* matrix;
@property MatrixPoint* anchorPoint;
@property FigureTypes type;
@property int cellCount;
@property NSMutableArray <MatrixPoint *> *pointsOnBoard;
@property NSNumber *identificator;
@property NSArray <MatrixPoint *> *leftestAndRightestCells;
@property int orientation;
@property (weak) id <FigureDelegate> delegate;
@property BOOL notTheFirstStep;

-(void)rotate;
-(instancetype)initWithRandomType;
-(void)goTo:(Directions)direction;


@end

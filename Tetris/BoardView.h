//
//  BoardView.h
//  Tetris
//
//  Created by Vahe Karamyan on 16.08.17.
//  Copyright © 2017 Vahe Karamyan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Definitions.h"
#import "Figure.h"
#import "CellView.h"
#import "FigureView.h"
#import "ImageManager.h"
@class FigureView;

@interface BoardView : UIView

@property NSMutableArray <UIView *> *board;
@property FigureView *currentFigureView;
@property MatrixPoint *figureViewAnchorPoint;

-(void)createFigureView:(Figure*)figure;
-(void)moveFigureDownWithRows:(int)rows;
-(void)deleteRowsAtIndexes:(NSMutableArray <NSNumber *> *)indexes;
-(void)rotate:(Figure *)figure;
-(void)takeFigureToDirection:(Directions)direction withCount:(int)count;
-(void)stickFigure;

@end

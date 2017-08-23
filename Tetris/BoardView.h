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

@interface BoardView : UIView


-(void)createFigure:(Figure*)figure;
-(void)moveFigureDown:(Figure *)figure andHowManyRows:(int)rows;
-(void)deleteRowsAtIndexes:(NSMutableArray <NSNumber *> *)indexes;
-(void)rotate:(Figure*)figure;
-(void)updateFigurePlace:(Figure*)figure;

@end

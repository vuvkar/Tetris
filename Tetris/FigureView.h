//
//  FigureView.h
//  Tetris
//
//  Created by Vahe Karamyan on 17.08.17.
//  Copyright © 2017 Vahe Karamyan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Figure.h"
#import "CellView.h"
#import "BoardView.h"

@interface FigureView : UIView

@property NSMutableArray <CellView *> *cells;

-(instancetype)initFromFigure:(Figure *)figure;
-(instancetype)initForGeneratedFigure:(Figure *)figure;

@end

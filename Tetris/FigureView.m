//
//  FigureView.m
//  Tetris
//
//  Created by Vahe Karamyan on 17.08.17.
//  Copyright © 2017 Vahe Karamyan. All rights reserved.
//

#import "FigureView.h"

@implementation FigureView

-(instancetype)initFromFigure:(Figure *)figure;
{
    self = [super init];
    if(self)
    {
        self.cells = [NSMutableArray arrayWithArray:@[]];
        for(int i = 0; i < [figure.pointsOnBoard count]; i++)
        {
            CellView *cell = [[CellView alloc] initForFigure:(FigureTypes)figure.type];
            [self addSubview:cell];
            cell.row = figure.pointsOnBoard[i].row;
            cell.frame = CGRectMake((figure.pointsOnBoard[i].column - figure.anchorPoint.column) * CellSize, (figure.anchorPoint.row - figure.pointsOnBoard[i].row) * CellSize, CellSize, CellSize);
            [self.cells addObject:cell];
        }
    }
    return self;
}


/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end

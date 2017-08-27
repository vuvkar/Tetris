//
//  FigureView.m
//  Tetris
//
//  Created by Vahe Karamyan on 17.08.17.
//  Copyright © 2017 Vahe Karamyan. All rights reserved.
//

#import "FigureView.h"

@implementation FigureView



-(instancetype)initForGeneratedFigure:(Figure *)figure
{
    self = [super init];
    if(self)
    {
        for(int i = 0; i < [figure.matrix count]; i++)
        {
            for(int j = 0; j < [figure.matrix[0] count]; j++)
            {
                if([figure.matrix[i][j] isEqual:@1])
                {
                    CellView *cell = [[CellView alloc] initForFigure:(FigureTypes)figure.type andSize:GeneratedFigureCellSize];
                    [self addSubview:cell];
                    cell.frame = CGRectMake(j * GeneratedFigureCellSize, i * GeneratedFigureCellSize, GeneratedFigureCellSize, GeneratedFigureCellSize);
                }
            }
        }
        self.frame = CGRectMake(0, 0, [figure.matrix[0] count] * GeneratedFigureCellSize, [figure.matrix count] * GeneratedFigureCellSize);
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

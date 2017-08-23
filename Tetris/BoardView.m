//
//  BoardView.m
//  Tetris
//
//  Created by Vahe Karamyan on 16.08.17.
//  Copyright © 2017 Vahe Karamyan. All rights reserved.
//

#import "BoardView.h"

@implementation BoardView

-(void)createFigure:(Figure*)figure
{
    FigureView* figureView = [[FigureView alloc] initFromFigure:figure];
    CGFloat height = CellSize * [figure.matrix count];
    CGFloat width = CellSize * [figure.matrix[0] count];
    figureView.frame = CGRectMake(figure.anchorPoint.column  * CellSize, 0, width, height);
    [self addSubview:figureView];
    figureView.tag = [figure.identificator integerValue];
}

-(void)updateFigurePlace:(Figure *)figure
{
    [UIView animateWithDuration:0.1 animations:^{
        FigureView *figureView = [self viewWithTag:[figure.identificator integerValue]];
        figureView.frame = CGRectMake(figure.anchorPoint.column  * CellSize, (BoardRowSize -  figure.anchorPoint.row - 1)  * CellSize, figureView.frame.size.width, figureView.frame.size.height);
    }];
}

-(void)moveFigureDown:(Figure *)figure andHowManyRows:(int)rows
{
    FigureView* figureView = [self viewWithTag:[figure.identificator integerValue]];
    for (CellView *cellSubview in [figureView subviews]) {
        cellSubview.row -= rows;
    }
    [self updateFigurePlace:figure];
}


-(void)deleteRowsAtIndexes:(NSMutableArray<NSNumber *> *)indexes
{
    [UIView animateWithDuration:0.1 animations:^{
        for(int i = 0; i < [indexes count]; i++)
            for (FigureView* subFigureView in [self subviews]) {
                for (CellView* subCellView in [subFigureView subviews]) {
                    if(subCellView.row == [indexes[i] intValue]){
                        [subFigureView.cells removeObject:subCellView];
                        [subCellView removeFromSuperview];
                    }
                    else if(subCellView.row > [indexes[i] intValue])
                    {
                        subCellView.frame = CGRectMake(subCellView.frame.origin.x, subCellView.frame.origin.y + CellSize, subCellView.frame.size.width, subCellView.frame.size.height);
                        subCellView.row--;
                    }
                }
                if([subFigureView.cells count] == 0)
                    [subFigureView removeFromSuperview];
            }
    }];
}

-(void)rotate:(Figure *)figure{
    FigureView *figureView = [self viewWithTag:[figure.identificator integerValue]];
    [figureView removeFromSuperview];
    FigureView* figureViewRotated = [[FigureView alloc] initFromFigure:figure];
    CGFloat height = CellSize * [figure.matrix count];
    CGFloat width = CellSize * [figure.matrix[0] count];
    figureViewRotated.frame = CGRectMake(figure.anchorPoint.column  * CellSize, (BoardRowSize -  figure.anchorPoint.row - 1 )  * CellSize, width, height);
    figureViewRotated.tag = [figure.identificator integerValue];
    [self addSubview:figureViewRotated];
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end

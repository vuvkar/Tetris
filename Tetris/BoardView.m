//
//  BoardView.m
//  Tetris
//
//  Created by Vahe Karamyan on 16.08.17.
//  Copyright © 2017 Vahe Karamyan. All rights reserved.
//

#import "BoardView.h"

@implementation BoardView

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        self.board = [[NSMutableArray alloc] init];
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, CellSize * BoardColumnsNumber, CellSize * BoardRowsNumber);
        self.backgroundColor = LightGreen;
        UIImage *cellImage = [UIImage imageNamed:@"normalCell.png"];
        [ImageManager resizeImage:cellImage withWidth:CellSize withHeight:CellSize];
        for(int i = 0; i < BoardRowsNumber; i++)
        {
            UIView *row = [[UIView alloc] initWithFrame:CGRectMake(0, i * CellSize, CellSize * BoardColumnsNumber, CellSize)];
            for(int j = 0; j < BoardColumnsNumber; j++)
            {
                UIImageView *cellImageView = [[UIImageView alloc] initWithImage:cellImage];
                cellImageView.frame = CGRectMake(CellSize * j, 0, CellSize, CellSize);
                [row addSubview:cellImageView];
            }
            [self addSubview:row];
            [self.board addObject:row];
        }
    }
    return self;
}

-(void)clearBoard
{
    [self.currentFigureView removeFromSuperview];
    for(int i = 0; i < [self.board count]; i++)
        for (UIView *subview in self.board[i].subviews)
        {
            if([subview isMemberOfClass:[CellView class]])
               [subview removeFromSuperview];
        }
}

-(void)createFigureView:(Figure *)figure
{
    FigureView* figureView = [[FigureView alloc] initWithFrame:CGRectMake(self.figureViewAnchorPoint.column * CellSize , (BoardRowsNumber -  self.figureViewAnchorPoint.row - 1) * CellSize , [figure.matrix[0] count] * CellSize, [figure.matrix count] * CellSize)];
    for(int i = 0; i < [figure.matrix count]; i++)
        for(int j = 0; j < [figure.matrix[0] count]; j++)
        {
            if([figure.matrix[i][j] isEqual:@1])
            {
                CellView *cell = [[CellView alloc] initForFigure:(FigureTypes)figure.type andSize:CellSize];
                [figureView addSubview:cell];
                cell.frame = CGRectMake(j * CellSize, i * CellSize, CellSize, CellSize);
            }
            
        }
    [self addSubview:figureView];
    self.currentFigureView = figureView;
}

-(void)moveFigureDownWithRows:(int)rows
{
    [UIView animateWithDuration:FastAnimationSpeed animations:^{
        self.currentFigureView.frame = CGRectMake(self.currentFigureView.frame.origin.x, self.currentFigureView.frame.origin.y + CellSize * rows, self.currentFigureView.frame.size.width, self.currentFigureView.frame.size.height);
    }];
}


-(void)deleteRowsAtIndexes:(NSMutableArray<NSNumber *> *)indexes
{
    [UIView animateWithDuration:FastAnimationSpeed animations:^{
    for(int i = 0; i < [indexes count]; i++)
    {
        int row = BoardRowsNumber - [indexes[i] intValue] - 1;
        [self.board[row] removeFromSuperview];
        [self.board removeObjectAtIndex:row];
        for(int j = row - 1; j >= 0; j--)
            self.board[j].frame = CGRectMake(0, self.board[j].frame.origin.y + CellSize, self.board[j].frame.size.width, CellSize);
        UIImage *cellImage = [UIImage imageNamed:@"normalCell.png"];
        UIView *newRow = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CellSize * BoardColumnsNumber, CellSize)];
        for(int j = 0; j < BoardColumnsNumber; j++)
        {
            UIImageView *cellImageView = [[UIImageView alloc] initWithImage:cellImage];
            cellImageView.frame = CGRectMake(CellSize * j, 0, CellSize, CellSize);
            [newRow addSubview:cellImageView];
        }
        [self addSubview:newRow];
        [self.board insertObject:newRow atIndex:0];

    }
    }];
    
}

-(void)rotate:(Figure *)figure
{
    [[self.currentFigureView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.currentFigureView.frame = CGRectMake(self.figureViewAnchorPoint.column * CellSize, (BoardRowsNumber -  self.figureViewAnchorPoint.row - 1) * CellSize, [figure.matrix[0] count] * CellSize , [figure.matrix count] * CellSize);
    for(int i = 0; i < [figure.matrix count]; i++)
        for(int j = 0; j < [figure.matrix[0] count]; j++)
        {
            if([figure.matrix[i][j] isEqual:@1])
            {
                CellView *cell = [[CellView alloc] initForFigure:(FigureTypes)figure.type andSize:CellSize];
                [self.currentFigureView addSubview:cell];
                cell.frame = CGRectMake(j * CellSize, i * CellSize, CellSize, CellSize);
            }
        }
}

-(void) takeFigureToDirection:(Directions)direction withCount:(int)count
{
    switch (direction)
    {
        case Right:
        {
            self.currentFigureView.frame = CGRectMake(self.currentFigureView.frame.origin.x + CellSize, self.currentFigureView.frame.origin.y, self.currentFigureView.frame.size.width, self.currentFigureView.frame.size.height);
            [self.figureViewAnchorPoint moveRight];
            break;
        }
            
        case Left:
        {
            self.currentFigureView.frame = CGRectMake(self.currentFigureView.frame.origin.x - CellSize, self.currentFigureView.frame.origin.y, self.currentFigureView.frame.size.width, self.currentFigureView.frame.size.height);
            [self.figureViewAnchorPoint moveLeft];
            break;
        }
            
        case Down:
        {
            [self moveFigureDownWithRows:count];
            self.figureViewAnchorPoint = [MatrixPoint initWithRow:self.figureViewAnchorPoint.row - count andColumn:self.figureViewAnchorPoint.column];
            break;
        }
    }
    
}

-(void)stickFigure
{
    for (CellView *cell in [self.currentFigureView subviews])
    {
        CGRect frame = [self.currentFigureView convertRect:cell.frame toView:self];
        int row = frame.origin.y / CellSize;
        int column = frame.origin.x / CellSize;
        [self.board[row] addSubview:cell];
        cell.frame = CGRectMake(column * CellSize, 0, CellSize, CellSize);
    }
    [self.currentFigureView removeFromSuperview];
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end

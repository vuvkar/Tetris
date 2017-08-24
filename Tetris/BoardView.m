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
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, CellSize * BoardColumnsSize, CellSize * BoardRowSize);
        self.backgroundColor = LightGreen;
        self.layer.cornerRadius = 5;
        UIImage *cellImage = [UIImage imageNamed:@"normalCell.png"];
        [ImageManager resizeImage:cellImage withWidth:CellSize withHeight:CellSize];
        for(int i = 0; i < BoardRowSize; i++)
            for(int j = 0; j < BoardColumnsSize; j++)
            {
                UIImageView *cellImageView = [[UIImageView alloc] initWithImage:cellImage];
                cellImageView.layer.borderWidth = 0;
                cellImageView.frame = CGRectMake(CellSize * j, CellSize * i, CellSize, CellSize);
                [self addSubview:cellImageView];
            }
        self.cellSubviews = [NSMutableArray arrayWithArray:@[]];
    }
    return self;
}

-(void)createFigure:(Figure*)figure
{
    FigureView* figureView = [[FigureView alloc] initFromFigure:figure];
    for (CellView *temp in figureView.subviews) {
        [self.cellSubviews addObject:temp];
    }
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
#warning veryy baaaaad functiooooon
    //NSMutableArray <CellView *> *temp;
    for(int i = 0; i < [indexes count]; i++)
        for(FigureView *subFigureView in self.subviews)
            if([subFigureView isMemberOfClass:[FigureView class]]){
                for (CellView* subCellView in subFigureView.subviews) {
                    [UIView animateWithDuration:0.1 animations:^{
                        if(subCellView.row == [indexes[i] intValue]){
                            [subCellView removeFromSuperview];
                           // [temp addObject:subCellView];
                        }
                        else if(subCellView.row > [indexes[i] intValue])
                        {
                            subCellView.frame = CGRectMake(subCellView.frame.origin.x, subCellView.frame.origin.y + CellSize, subCellView.frame.size.width, subCellView.frame.size.height);
                            subCellView.row--;
                        }
                    }];
                }
    //for (CellView *tempView in temp) {
      //  [self.cellSubviews removeObject:tempView];
    }
    
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

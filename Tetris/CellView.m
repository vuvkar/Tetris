//
//  CellView.m
//  Tetris
//
//  Created by Vahe Karamyan on 16.08.17.
//  Copyright © 2017 Vahe Karamyan. All rights reserved.
//

#import "CellView.h"

@implementation CellView

-(instancetype)initForFigure:(FigureTypes)figure andSize:(double)size;
{
    self = [super init];
    if(self)
    {
        UIImage *image;
        switch (figure)
        {
            case Thunder:
                image = [UIImage imageNamed:@"block_brown.png"];
                break;
            case ReverseThunder:
                image = [UIImage imageNamed:@"block_brown.png"];
                break;
            case Seven:
                image = [UIImage imageNamed:@"block_green.png"];
                break;
            case ReverseSeven:
                image = [UIImage imageNamed:@"block_green.png"];
                break;
            case Cube:
                image = [UIImage imageNamed:@"block_orange.png"];
                break;
            case Mushroom:
                image = [UIImage imageNamed:@"block_red.png"];
                break;
            case Row:
                image = [UIImage imageNamed:@"block_yellow.png"];
                break;
        }
        image = [ImageManager resizeImage:image withWidth:size withHeight:size];
        UIImageView *cellImage = [[UIImageView alloc] initWithImage:image];
        [self addSubview: cellImage];
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

//
//  CellView.m
//  Tetris
//
//  Created by Vahe Karamyan on 16.08.17.
//  Copyright © 2017 Vahe Karamyan. All rights reserved.
//

#import "CellView.h"

@implementation CellView

-(instancetype)initForFigure:(FigureTypes)figure
{
    self = [super init];
    if(self)
    {
        UIImage *image;
        switch (figure) {
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
        image = [self resizeImage:image withWidth:CellSize withHeight:CellSize];
        UIImageView *cellImage = [[UIImageView alloc] initWithImage:image];
        [self addSubview: cellImage];
    }
    return self;
}

-(UIImage*)resizeImage:(UIImage *)image withWidth:(double)width withHeight:(double)height
{
    CGSize newSize = CGSizeMake(width, height);
    float widthRatio = newSize.width / image.size.width;
    float heightRatio = newSize.height / image.size.height;
    
    if(widthRatio > heightRatio)
    {
        newSize=CGSizeMake(image.size.width * heightRatio, image.size.height * heightRatio);
    }
    else
    {
        newSize=CGSizeMake(image.size.width * widthRatio, image.size.height * widthRatio);
    }
    
    
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end

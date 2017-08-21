//
//  MatrixPoint.m
//  Tetris
//
//  Created by Vahe Karamyan on 16.08.17.
//  Copyright © 2017 Vahe Karamyan. All rights reserved.
//

#import "MatrixPoint.h"

@implementation MatrixPoint

+(instancetype)initWithRow:(int)row andColumn:(int)column
{
    MatrixPoint* temp = [[MatrixPoint alloc] init];
    temp.row = row;
    temp.column = column;
    return temp;
}

-(void)moveDown
{
    self.row--;
}

-(void)moveUp
{
    self.row++;
}

-(void)moveLeft
{
    self.column--;
}

-(void)moveRight
{
    self.column++;
}
@end

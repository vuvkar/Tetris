//
//  Figure.m
//  Tetris
//
//  Created by Vahe Karamyan on 15.08.17.
//  Copyright © 2017 Vahe Karamyan. All rights reserved.
//

#import "Figure.h"

static int ident = 1;

@implementation Figure

-(instancetype)initWithRandomType{
    self = [super init];
    if(self){
        FigureTypes type = arc4random_uniform(HowManyFigures);
        self.type = type;
        self.identificator = [NSNumber numberWithInt:ident];
        ident++;
        self.notTheFirstStep = NO;
        switch (type){
            case Cube:{
                self.matrix = @[ @[@1, @1], @[@1, @1]];
                self.pointsOnBoard = [NSMutableArray arrayWithArray:@[[MatrixPoint initWithRow:BoardRowSize - 1 andColumn:BoardColumnsSize / 2 - 1], [MatrixPoint initWithRow:BoardRowSize - 1 andColumn:BoardColumnsSize / 2 ], [MatrixPoint initWithRow:BoardRowSize - 2 andColumn:BoardColumnsSize / 2 - 1], [MatrixPoint initWithRow:BoardRowSize - 2 andColumn:BoardColumnsSize / 2]]];
                self.anchorPoint = [MatrixPoint initWithRow:self.pointsOnBoard[0].row andColumn:self.pointsOnBoard[0].column];
                self.leftestAndRightestCells = @[self.pointsOnBoard[0], [self.pointsOnBoard lastObject]];
                self.cellCount = 4;
                break;
            }
            case Mushroom:{
                self.matrix = @[@[@1, @1, @1], @[@0, @1, @0]];
                self.pointsOnBoard = [NSMutableArray arrayWithArray:@[[MatrixPoint initWithRow:BoardRowSize - 1 andColumn:BoardColumnsSize / 2 - 2], [MatrixPoint initWithRow:BoardRowSize - 1 andColumn:BoardColumnsSize / 2 - 1], [MatrixPoint initWithRow:BoardRowSize - 1 andColumn:BoardColumnsSize / 2 ], [MatrixPoint initWithRow:BoardRowSize - 2 andColumn:BoardColumnsSize / 2  - 1]]];
                self.leftestAndRightestCells = @[self.pointsOnBoard[0], self.pointsOnBoard[[self.pointsOnBoard count] -2]];
                self.cellCount = 4;
                self.orientation = 0;
                self.anchorPoint = [MatrixPoint initWithRow:self.pointsOnBoard[0].row andColumn:self.pointsOnBoard[0].column];
                break;
            }
            case Row:{
                self.matrix = @[@[@1, @1, @1, @1]];
                self.pointsOnBoard = [NSMutableArray arrayWithArray:@[[MatrixPoint initWithRow:BoardRowSize - 1 andColumn:BoardColumnsSize / 2 - 2], [MatrixPoint initWithRow:BoardRowSize - 1 andColumn:BoardColumnsSize / 2 - 1], [MatrixPoint initWithRow:BoardRowSize - 1 andColumn:BoardColumnsSize / 2 ], [MatrixPoint initWithRow:BoardRowSize - 1 andColumn:BoardColumnsSize / 2  + 1]]];
                self.leftestAndRightestCells = @[self.pointsOnBoard[0], self.pointsOnBoard[[self.pointsOnBoard count] - 1]];
                self.cellCount = 4;
                self.orientation = 0;
                self.anchorPoint = [MatrixPoint initWithRow:self.pointsOnBoard[0].row andColumn:self.pointsOnBoard[0].column];
                break;
            }
            case Thunder:{
                self.matrix = @[ @[@1, @0], @[@1, @1], @[@0, @1]];
                self.pointsOnBoard = [NSMutableArray arrayWithArray:@[[MatrixPoint initWithRow:BoardRowSize - 1 andColumn:BoardColumnsSize / 2 - 1], [MatrixPoint initWithRow:BoardRowSize - 2 andColumn:BoardColumnsSize / 2 - 1 ],
                                                                      [MatrixPoint initWithRow:BoardRowSize - 2 andColumn:BoardColumnsSize / 2 ],
                                                                      [MatrixPoint initWithRow:BoardRowSize - 3 andColumn:BoardColumnsSize / 2 ]]];
                self.anchorPoint = [MatrixPoint initWithRow:self.pointsOnBoard[0].row andColumn:self.pointsOnBoard[0].column];
                self.leftestAndRightestCells = @[self.pointsOnBoard[0], [self.pointsOnBoard lastObject]];
                self.cellCount = 4;
                break;
                
            }
        }
        [GameEngine sharedEngine].generatedFigure = self;
    }
    return self;
}

-(void)goTo:(Directions)direction
{
    switch (direction) {
        case Left:
            if(self.leftestAndRightestCells[0].column - 1 >= 0){
                BOOL canMove = YES;
                for (MatrixPoint *point in self.pointsOnBoard) {
                    if([[GameEngine sharedEngine].board[point.row][point.column - 1] isEqual:@1]){
                        canMove = NO;
                        break;
                    }
                }
                if(canMove){
                    for (MatrixPoint *point in self.pointsOnBoard) {
                        [point moveLeft];
                    }
                    [self.anchorPoint moveLeft];
                    [self.delegate moveFigure:self];
                }
            }
            break;
        case Right:
            if([self.leftestAndRightestCells lastObject].column + 1 < BoardColumnsSize){
                BOOL canMove = YES;
                for (MatrixPoint *point in self.pointsOnBoard) {
                    if([[GameEngine sharedEngine].board[point.row][point.column + 1] isEqual:@1]){
                        canMove = NO;
                        break;
                    }
                }
                if(canMove){
                    for (MatrixPoint *point in self.pointsOnBoard) {
                        [point moveRight];
                    }
                    [self.anchorPoint moveRight];
                    [self.delegate moveFigure:self];
                }
            }
            break;
    }
}

-(void)rotate
{
    switch (self.type) {
        case Cube:
            break;
        case Mushroom:
        {
            switch (self.orientation) {
                case 0:{
                    if (self.pointsOnBoard[1].row + 1 < BoardRowSize && [GameEngine sharedEngine].board[self.pointsOnBoard[1].row + 1][self.pointsOnBoard[1].column] == [NSNull null]) {
                        self.matrix = @[@[@1, @0], @[@1, @1], @[@1, @0]];
                        [self.pointsOnBoard replaceObjectAtIndex:0 withObject:[MatrixPoint initWithRow:self.pointsOnBoard[1].row + 1 andColumn:self.pointsOnBoard[1].column]];
                        self.leftestAndRightestCells = @[self.pointsOnBoard[0], self.pointsOnBoard[2]];
                        self.orientation++;
                        self.anchorPoint = [MatrixPoint initWithRow:self.pointsOnBoard[0].row andColumn:self.pointsOnBoard[0].column];
                        [self.delegate rotateFigure:self];
                    }
                    break;
                }
                case 1:{
                    if (self.pointsOnBoard[1].column - 1 >= 0 && [GameEngine sharedEngine].board[self.pointsOnBoard[1].row ][self.pointsOnBoard[1].column - 1] == [NSNull null]){
                        self.matrix = @[@[@0, @1, @0], @[@1, @1, @1]];
                        [self.pointsOnBoard replaceObjectAtIndex:3 withObject:[MatrixPoint initWithRow:self.pointsOnBoard[1].row  andColumn:self.pointsOnBoard[1].column - 1]];
                        self.leftestAndRightestCells = @[self.pointsOnBoard[3], self.pointsOnBoard[[self.pointsOnBoard count] - 2]];
                        self.orientation++;
                        self.anchorPoint = [MatrixPoint initWithRow:(self.pointsOnBoard[3].row + 1) andColumn:self.pointsOnBoard[3].column];
                        [self.delegate rotateFigure:self];
                    }
                    break;
                }
                case 2:{
                    if (self.pointsOnBoard[1].row - 1 >= 0 && [GameEngine sharedEngine].board[self.pointsOnBoard[1].row - 1][self.pointsOnBoard[1].column] == [NSNull null]){
                        self.matrix = @[@[@0, @1], @[@1, @1], @[@0, @1]];
                        [self.pointsOnBoard replaceObjectAtIndex:2 withObject:[MatrixPoint initWithRow:self.pointsOnBoard[1].row - 1 andColumn:self.pointsOnBoard[1].column]];
                        self.leftestAndRightestCells = @[self.pointsOnBoard[3], self.pointsOnBoard[[self.pointsOnBoard count] - 2]];
                        self.orientation++;
                        self.anchorPoint = [MatrixPoint initWithRow:self.pointsOnBoard[0].row andColumn:self.pointsOnBoard[0].column - 1];
                        [self.delegate rotateFigure:self];
                    }
                    break;
                }
                case 3:{
                    if (self.pointsOnBoard[1].column + 1 < BoardColumnsSize && [GameEngine sharedEngine].board[self.pointsOnBoard[1].row][self.pointsOnBoard[1].column + 1] == [NSNull null]){
                        self.matrix = @[@[@1, @1, @1], @[@0, @1, @0]];
                        [self.pointsOnBoard replaceObjectAtIndex:0 withObject:[MatrixPoint initWithRow:self.pointsOnBoard[1].row  andColumn:self.pointsOnBoard[1].column + 1]];
                        [self.pointsOnBoard exchangeObjectAtIndex:0 withObjectAtIndex:3];
                        [self.pointsOnBoard exchangeObjectAtIndex:2 withObjectAtIndex:3];
                        self.leftestAndRightestCells = @[self.pointsOnBoard[0], self.pointsOnBoard[[self.pointsOnBoard count] - 2]];
                        self.orientation = 0;
                        self.anchorPoint = [MatrixPoint initWithRow:self.pointsOnBoard[0].row andColumn:self.pointsOnBoard[0].column];
                        [self.delegate rotateFigure:self];
                    }
                    break;
                }
            }
            break;
        }
        case Row:
        {
            switch (self.orientation){
                case 0:{
                    if(self.pointsOnBoard[1].row - 2 >= 0 && self.pointsOnBoard[1].row + 1 < BoardRowSize && [GameEngine sharedEngine].board[self.pointsOnBoard[1].row - 2][self.pointsOnBoard[1].column] == [NSNull null] && [GameEngine sharedEngine].board[self.pointsOnBoard[1].row - 1][self.pointsOnBoard[1].column] == [NSNull null] && [GameEngine sharedEngine].board[self.pointsOnBoard[1].row + 1][self.pointsOnBoard[1].column] == [NSNull null]){
                        self.matrix = @[@[@1], @[@1], @[@1], @[@1]];
                        MatrixPoint *point = self.pointsOnBoard[1];
                        self.pointsOnBoard = [NSMutableArray arrayWithArray:@[point, [MatrixPoint initWithRow:point.row + 1 andColumn:point.column], [MatrixPoint initWithRow:point.row - 1 andColumn:point.column], [MatrixPoint initWithRow:point.row - 2 andColumn:point.column]]];
                        self.leftestAndRightestCells = @[self.pointsOnBoard[1], self.pointsOnBoard[3]];
                        self.orientation ++;
                        self.anchorPoint = [MatrixPoint initWithRow:self.pointsOnBoard[1].row  andColumn:self.pointsOnBoard[1].column];
                        [self.delegate rotateFigure:self];
                    }
                    break;
                }
                case 1:{
                    if(self.pointsOnBoard[0].column - 1 >= 0 && self.pointsOnBoard[0].column + 2 < BoardColumnsSize && [GameEngine sharedEngine].board[self.pointsOnBoard[0].row ][self.pointsOnBoard[0].column - 1] == [NSNull null] && [GameEngine sharedEngine].board[self.pointsOnBoard[0].row ][self.pointsOnBoard[0].column + 1] == [NSNull null] && [GameEngine sharedEngine].board[self.pointsOnBoard[0].row ][self.pointsOnBoard[0].column + 2] == [NSNull null]){
                        self.matrix = @[@[@1, @1, @1, @1]];
                        MatrixPoint *point = self.pointsOnBoard[0];
                        self.pointsOnBoard = [NSMutableArray arrayWithArray:@[[MatrixPoint initWithRow:point.row  andColumn:point.column - 1], point, [MatrixPoint initWithRow:point.row  andColumn:point.column + 1], [MatrixPoint initWithRow:point.row  andColumn:point.column + 2]]];
                        self.leftestAndRightestCells = @[self.pointsOnBoard[0], self.pointsOnBoard[[self.pointsOnBoard count] - 1]];
                        self.orientation = 0;
                        self.anchorPoint = [MatrixPoint initWithRow:self.pointsOnBoard[0].row andColumn:self.pointsOnBoard[0].column];
                        [self.delegate rotateFigure:self];
                    }
                    break;
                }
            }
            break;
        }
        case Thunder:
        {
            switch (self.orientation) {
                case 0:
                    if(self.pointsOnBoard[0].column + 1 < BoardColumnsSize && self.pointsOnBoard[1].column - 1 >= 0 && [GameEngine sharedEngine].board[self.pointsOnBoard[0].row ][self.pointsOnBoard[0].column + 1] == [NSNull null] && [GameEngine sharedEngine].board[self.pointsOnBoard[1].row ][self.pointsOnBoard[1].column - 1] == [NSNull null] ) {
                        self.matrix = @[ @[@0, @1, @1], @[@1, @1, @0]];
                        self.pointsOnBoard = [NSMutableArray arrayWithArray:@[[MatrixPoint initWithRow:self.pointsOnBoard[2].row andColumn:self.pointsOnBoard[2].column - 2 ], self.pointsOnBoard[1], self.pointsOnBoard[0], [MatrixPoint initWithRow:self.pointsOnBoard[3].row + 2 andColumn:self.pointsOnBoard[3].column]]];
                        self.anchorPoint = [MatrixPoint initWithRow:self.pointsOnBoard[0].row + 1 andColumn:self.pointsOnBoard[0].column];
                        self.leftestAndRightestCells = @[self.pointsOnBoard[0], [self.pointsOnBoard lastObject]];
                        self.orientation++;
                        [self.delegate rotateFigure:self];
                    }
                    break;
                case 1:
                    self.matrix = @[ @[@1, @0], @[@1, @1], @[@0, @1]];
                    self.pointsOnBoard = [NSMutableArray arrayWithArray:@[self.pointsOnBoard[2], self.pointsOnBoard[1], [MatrixPoint initWithRow:self.pointsOnBoard[0].row andColumn:self.pointsOnBoard[2].column + 2 ],   [MatrixPoint initWithRow:self.pointsOnBoard[3].row - 2 andColumn:self.pointsOnBoard[3].column]]];
                    self.anchorPoint = [MatrixPoint initWithRow:self.pointsOnBoard[0].row andColumn:self.pointsOnBoard[0].column];
                    self.leftestAndRightestCells = @[self.pointsOnBoard[0], [self.pointsOnBoard lastObject]];
                    self.orientation = 0;
                    [self.delegate rotateFigure:self];
                    break;
                    
                default:
                    break;
            }
            break;
        }
    }
}
@end

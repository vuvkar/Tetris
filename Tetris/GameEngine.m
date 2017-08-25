//
//  GameEngine.m
//  Tetris
//
//  Created by Vahe Karamyan on 15.08.17.
//  Copyright © 2017 Vahe Karamyan. All rights reserved.
//

#import "GameEngine.h"

static GameEngine *sharedEngine = nil;

@implementation GameEngine

+(instancetype)sharedEngine
{
    if(sharedEngine == nil)
    {
        sharedEngine  = [[GameEngine alloc] init];
        sharedEngine.board = [[NSMutableArray alloc] init];
        sharedEngine.tactSpeed = InitalTactSpeed;
        for(int i = 0; i < BoardRowSize; i++)
        {
            NSMutableArray *temp = [[NSMutableArray alloc] init];
            for(int i = 0; i < BoardColumnsSize; i++)
                [temp addObject:[NSNull null]];
            [temp addObject:[NSNumber numberWithInt:BoardColumnsSize]];
            [sharedEngine.board addObject:temp];
        }
        sharedEngine.isItTimeToCreateNewFigure = YES;
        [sharedEngine generateNewFigure];
        [sharedEngine startTact];
    }
    return  sharedEngine;
}

-(void)startTact
{
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.tactSpeed repeats:YES block:^(NSTimer * _Nonnull timer) {
        if(self.didSwipeDown){
            [self forceDown];
            [self deleteRows];
            self.isItTimeToCreateNewFigure = YES;
            self.didSwipeDown = NO;
        }
        if(self.isItTimeToCreateNewFigure)
        {
            [self startFalling];
            [self generateNewFigure];
            self.isItTimeToCreateNewFigure = NO;
        }
        if(self.currentFigure.notTheFirstStep && !self.isLastMove){
            [self moveCurrentFigure];
        }
        else
            self.currentFigure.notTheFirstStep = YES;
        if(self.shouldTheFigureGoLeftOrRight)
        {
            [self.currentFigure goTo:self.goingDirection];
            self.shouldTheFigureGoLeftOrRight = NO;
        }
        if(self.shouldRotate)
        {
            if([self isPossibleToRotate])
                [self.currentFigure rotate];
            self.shouldRotate = NO;
        }
        BOOL flag = YES;
        for (MatrixPoint *temp in [self.currentFigure pointsOnBoard]) {
            if(((temp.row == 0 || [self.board[temp.row - 1][temp.column]  isEqual: @1])))
            {
                flag = NO;
                if(self.isLastMove){
                    for (MatrixPoint *point in [self.currentFigure pointsOnBoard]) {
                        if([self.board[point.row][point.column] isEqual:@1])
                        {
                            NSLog(@"%d, %d", point.row, point.column);
                        }
                        self.board[point.row][point.column] = @1;
                        [self.board[point.row] replaceObjectAtIndex:BoardColumnsSize withObject:@([[self.board[point.row] lastObject] intValue] - 1)];
                    }
                    self.isItTimeToCreateNewFigure = YES;
                    [self deleteRows];
                    break;
                }
                else{
                    self.isLastMove = YES;
                    self.tactSpeed = TimeForLastMove;
                    [self.timer invalidate];
                    [self startTact];
                    break;
                }
            }
        }
        if(flag){
            self.isLastMove = NO;
            self.tactSpeed = InitalTactSpeed + self.level * Speeding;
            [self.timer invalidate];
            [self startTact];
        }
    }];
}

-(void)endGame
{
    sharedEngine = nil;
}

-(void)moveCurrentFigure
{
    for (MatrixPoint *temp in self.currentFigure.pointsOnBoard) {
        [temp moveDown];
    }
    [self.currentFigure.anchorPoint moveDown];
    [self.currentFigure.delegate moveFigureDown:self.currentFigure andHowManyRows:1];
}

-(void)generateNewFigure
{
    Figure *newFigure = [[Figure alloc] initWithRandomType];
    [self.delegate newFigureIsGenerated:newFigure];
    self.generatedFigure = newFigure;
}

-(void)deleteRows
{
    NSMutableArray <NSNumber *> *rows = [NSMutableArray arrayWithArray:@[]];
    int score = 0;
    int counter = 0;
    for(int i = 0; i < BoardRowSize; i++)
        if([[self.board[i] lastObject] intValue] == 0){
            score += NormalScore + counter * AdditionalScoreForEachLine;
            [rows addObject:[NSNumber numberWithInt:i]];
            [self.board removeObjectAtIndex:i];
            NSMutableArray *temp = [[NSMutableArray alloc] init];
            for(int i = 0; i < BoardColumnsSize; i++)
                [temp addObject:[NSNull null]];
            [temp addObject:[NSNumber numberWithInt:BoardColumnsSize]];
            [sharedEngine.board addObject:temp];
            counter++;
            i--;
        }
    if([rows count] > 0)
    {
        self.deletedRows += (int)[rows count];
        self.score += score;
        if(self.deletedRows >= RowsNeedToDeleteToChangeLevel)
        {
            self.deletedRows -= RowsNeedToDeleteToChangeLevel;
            if(self.tactSpeed > 0.1)
                self.tactSpeed += Speeding;
            self.level++;
            [self.delegate levelIsChanged:self.level];
            [self.timer invalidate];
            [self startTact];
        }
        [self.delegate rowsAreDeleted:rows];
    }
}

-(void)forceDown
{
    int min = INT_MAX;
    for(MatrixPoint *temp in self.currentFigure.pointsOnBoard){
        int counter = 0;
        for(int i = temp.row - 1; i >= 0; i--){
            counter++;
            if([self.board[i][temp.column] isEqual:@1])
            {
                counter --;
                min = (counter < min) ? counter : min;
                break;
            }
            else if (i == 0)
            {
                min = (counter < min) ? counter : min;
                break;
            }
        }
    }
    for(MatrixPoint *temp in self.currentFigure.pointsOnBoard){
        self.board[temp.row - min][temp.column] = @1;
        [self.board[temp.row - min] replaceObjectAtIndex:BoardColumnsSize withObject:@([[self.board[temp.row - min] lastObject] intValue] - 1)];
    }
    self.currentFigure.anchorPoint = [MatrixPoint initWithRow:self.currentFigure.anchorPoint.row - min andColumn:self.currentFigure.anchorPoint.column];
    [self.currentFigure.delegate moveFigureDown:self.currentFigure andHowManyRows:min];
}

-(void)startFalling
{
    self.isLastMove = NO;
    self.currentFigure = self.generatedFigure;
    self.generatedFigure = nil;
    [self.delegate newFigureIsCreated:self.currentFigure];
}

-(BOOL)isPossibleToRotate
{
    switch (self.currentFigure.type) {
        case Cube:
            return NO; //Actually it can rotate, but wrote No, for not entering <if> in tact function
            break;
            
        case Row:
        {
            switch (self.currentFigure.orientation) {
                case 0:
                    return (self.currentFigure.pointsOnBoard[1].row - 2 >= 0
                            && self.currentFigure.pointsOnBoard[1].row + 1 < BoardRowSize
                            && self.board[self.currentFigure.pointsOnBoard[1].row - 2][self.currentFigure.pointsOnBoard[1].column] == [NSNull null]
                            && self.board[self.currentFigure.pointsOnBoard[1].row - 1][self.currentFigure.pointsOnBoard[1].column] == [NSNull null]
                            && self.board[self.currentFigure.pointsOnBoard[1].row + 1][self.currentFigure.pointsOnBoard[1].column] == [NSNull null]);
                    break;
                case 1:
                    return (self.currentFigure.pointsOnBoard[0].column - 1 >= 0
                            && self.currentFigure.pointsOnBoard[0].column + 2 < BoardColumnsSize
                            && self.board[self.currentFigure.pointsOnBoard[0].row ][self.currentFigure.pointsOnBoard[0].column - 1] == [NSNull null]
                            && self.board[self.currentFigure.pointsOnBoard[0].row ][self.currentFigure.pointsOnBoard[0].column + 1] == [NSNull null]
                            && self.board[self.currentFigure.pointsOnBoard[0].row ][self.currentFigure.pointsOnBoard[0].column + 2] == [NSNull null]);
                    break;
            }
            break;
        }
        case Thunder: //checked
        {
            switch (self.currentFigure.orientation) {
                case 0:
                    return (self.currentFigure.pointsOnBoard[2].column - 2 >= 0
                            && self.currentFigure.pointsOnBoard[3].row + 2 >= 0
                            && self.board[self.currentFigure.pointsOnBoard[2].row ][self.currentFigure.pointsOnBoard[2].column - 2] == [NSNull null]
                            && self.board[self.currentFigure.pointsOnBoard[3].row + 2][self.currentFigure.pointsOnBoard[3].column ] == [NSNull null]);
                    break;
                case 1:
                    return (self.currentFigure.pointsOnBoard[2].column + 1 < BoardColumnsSize
                            && self.currentFigure.pointsOnBoard[3].row - 2 - 1 >= 0
                            && self.board[self.currentFigure.pointsOnBoard[3].row - 2 ][self.currentFigure.pointsOnBoard[3].column] == [NSNull null]
                            && self.board[self.currentFigure.pointsOnBoard[0].row][self.currentFigure.pointsOnBoard[2].column + 1] == [NSNull null]);
                    break;
            }
            break;
        }
        case Mushroom:
        {
            switch (self.currentFigure.orientation) {
                case 0:
                    return (self.currentFigure.pointsOnBoard[1].row + 1 < BoardRowSize
                            && self.board[self.currentFigure.pointsOnBoard[1].row + 1][self.currentFigure.pointsOnBoard[1].column] == [NSNull null]);
                    break;
                case 1:
                    return (self.currentFigure.pointsOnBoard[1].column - 1 >= 0
                            && self.board[self.currentFigure.pointsOnBoard[1].row ][self.currentFigure.pointsOnBoard[1].column - 1] == [NSNull null]);
                    break;
                case 2:
                    return (self.currentFigure.pointsOnBoard[1].row - 1 >= 0
                            && self.board[self.currentFigure.pointsOnBoard[1].row - 1][self.currentFigure.pointsOnBoard[1].column] == [NSNull null]);
                    break;
                case 3:
                    return (self.currentFigure.pointsOnBoard[1].column + 1 < BoardColumnsSize
                            && self.board[self.currentFigure.pointsOnBoard[1].row][self.currentFigure.pointsOnBoard[1].column + 1] == [NSNull null]);
                    break;
            }
            break;
        }
        case ReverseThunder:
        {
            switch (self.currentFigure.orientation) {
                case 0:
                    return (self.currentFigure.pointsOnBoard[2].row + 1 < BoardRowSize
                            && self.currentFigure.pointsOnBoard[3].column + 2 < BoardColumnsSize
                            && self.board[self.currentFigure.pointsOnBoard[2].row + 1][self.currentFigure.pointsOnBoard[2].column] == [NSNull null]
                            && self.board[self.currentFigure.pointsOnBoard[1].row][self.currentFigure.pointsOnBoard[3].column + 2] == [NSNull null]);
                    break;
                    
                case 1:
                    return (self.currentFigure.pointsOnBoard[2].column - 1 >= 0
                            && self.currentFigure.pointsOnBoard[0].row - 2 >= 0
                            &&  self.board[self.currentFigure.pointsOnBoard[2].row][self.currentFigure.pointsOnBoard[2].column - 1] == [NSNull null]
                            && self.board[self.currentFigure.pointsOnBoard[0].row - 2][self.currentFigure.pointsOnBoard[0].column] == [NSNull null]);
                    break;
            }
            break;
        }
        case Seven:
        {
            switch (self.currentFigure.orientation) {
                case 0:
                    return (self.currentFigure.pointsOnBoard[1].row - 1 >= 0
                            && self.currentFigure.pointsOnBoard[1].row + 1 < BoardRowSize
                            && self.currentFigure.pointsOnBoard[1].column + 1 < BoardColumnsSize
                            && self.board[self.currentFigure.pointsOnBoard[1].row - 1][self.currentFigure.pointsOnBoard[1].column] == [NSNull null]
                            && self.board[self.currentFigure.pointsOnBoard[1].row + 1][self.currentFigure.pointsOnBoard[1].column] == [NSNull null]
                            && self.board[self.currentFigure.pointsOnBoard[1].row + 1][self.currentFigure.pointsOnBoard[1].column + 1] == [NSNull null]);
                    break;
                case 1:
                    return (self.currentFigure.pointsOnBoard[1].column - 1 >= 0
                            && self.currentFigure.pointsOnBoard[1].row + 1 < BoardRowSize
                            && self.currentFigure.pointsOnBoard[1].column + 1 < BoardColumnsSize
                            && self.board[self.currentFigure.pointsOnBoard[1].row + 1][self.currentFigure.pointsOnBoard[1].column - 1] == [NSNull null]
                            && self.board[self.currentFigure.pointsOnBoard[1].row ][self.currentFigure.pointsOnBoard[1].column - 1] == [NSNull null]
                            && self.board[self.currentFigure.pointsOnBoard[1].row ][self.currentFigure.pointsOnBoard[1].column + 1] == [NSNull null]);
                    break;
                case 2:
                    return (self.currentFigure.pointsOnBoard[2].row - 1 >= 0
                            && self.currentFigure.pointsOnBoard[2].row + 1 < BoardRowSize
                            && self.currentFigure.pointsOnBoard[2].column - 1 >= 0
                            && self.board[self.currentFigure.pointsOnBoard[2].row + 1][self.currentFigure.pointsOnBoard[2].column ] == [NSNull null]
                            && self.board[self.currentFigure.pointsOnBoard[2].row - 1][self.currentFigure.pointsOnBoard[2].column] == [NSNull null]
                            && self.board[self.currentFigure.pointsOnBoard[2].row - 1][self.currentFigure.pointsOnBoard[2].column - 1] == [NSNull null]);
                    break;
                case 3:
                    return (self.currentFigure.pointsOnBoard[1].column - 1 >= 0
                            && self.currentFigure.pointsOnBoard[1].row - 1 >= 0
                            && self.currentFigure.pointsOnBoard[1].column + 1 < BoardColumnsSize
                            && self.board[self.currentFigure.pointsOnBoard[1].row][self.currentFigure.pointsOnBoard[1].column - 1] == [NSNull null]
                            && self.board[self.currentFigure.pointsOnBoard[1].row ][self.currentFigure.pointsOnBoard[1].column + 1] == [NSNull null]
                            && self.board[self.currentFigure.pointsOnBoard[1].row - 1][self.currentFigure.pointsOnBoard[1].column + 1] == [NSNull null]);
                    break;
            }
            break;
        }
        case ReverseSeven:
        {
            switch (self.currentFigure.orientation) {
                case 0:
                    return (self.currentFigure.pointsOnBoard[2].row - 1 >= 0
                            && self.currentFigure.pointsOnBoard[2].row + 1 < BoardRowSize
                            && self.currentFigure.pointsOnBoard[2].column + 1 < BoardColumnsSize
                            && self.board[self.currentFigure.pointsOnBoard[2].row + 1][self.currentFigure.pointsOnBoard[2].column ] == [NSNull null]
                            && self.board[self.currentFigure.pointsOnBoard[2].row - 1][self.currentFigure.pointsOnBoard[2].column] == [NSNull null]
                            && self.board[self.currentFigure.pointsOnBoard[2].row - 1][self.currentFigure.pointsOnBoard[2].column + 1] == [NSNull null]);
                    break;
                case 1:
                    return (self.currentFigure.pointsOnBoard[1].column - 1 >= 0
                            && self.currentFigure.pointsOnBoard[1].row + 1 < BoardRowSize
                            && self.currentFigure.pointsOnBoard[1].column + 1 < BoardColumnsSize
                            && self.board[self.currentFigure.pointsOnBoard[1].row][self.currentFigure.pointsOnBoard[1].column - 1] == [NSNull null]
                            && self.board[self.currentFigure.pointsOnBoard[1].row ][self.currentFigure.pointsOnBoard[1].column + 1] == [NSNull null]
                            && self.board[self.currentFigure.pointsOnBoard[1].row + 1][self.currentFigure.pointsOnBoard[1].column + 1] == [NSNull null]);
                    break;
                case 2:
                    return (self.currentFigure.pointsOnBoard[1].column - 1 >= 0
                            && self.currentFigure.pointsOnBoard[1].row + 1 < BoardRowSize
                            && self.currentFigure.pointsOnBoard[1].row - 1 >= 0
                            && self.board[self.currentFigure.pointsOnBoard[1].row + 1][self.currentFigure.pointsOnBoard[1].column - 1] == [NSNull null]
                            && self.board[self.currentFigure.pointsOnBoard[1].row + 1 ][self.currentFigure.pointsOnBoard[1].column ] == [NSNull null]
                            && self.board[self.currentFigure.pointsOnBoard[1].row - 1][self.currentFigure.pointsOnBoard[1].column] == [NSNull null]);
                    break;
                case 3:
                    return (self.currentFigure.pointsOnBoard[2].row - 1 >= 0
                            && self.currentFigure.pointsOnBoard[2].column - 1 >= 0
                            && self.currentFigure.pointsOnBoard[2].column + 1 < BoardColumnsSize
                            && self.board[self.currentFigure.pointsOnBoard[2].row - 1][self.currentFigure.pointsOnBoard[2].column - 1] == [NSNull null]
                            && self.board[self.currentFigure.pointsOnBoard[2].row][self.currentFigure.pointsOnBoard[2].column - 1] == [NSNull null]
                            && self.board[self.currentFigure.pointsOnBoard[2].row][self.currentFigure.pointsOnBoard[2].column + 1] == [NSNull null]);
                    break;
            }
            break;
        }
    }
    return NO;
}
@end

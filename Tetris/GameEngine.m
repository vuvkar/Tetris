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
        
        if(self.isItTimeToCreateNewFigure)
        {
            [self startFalling];
            [self generateNewFigure];
            self.isItTimeToCreateNewFigure = NO;
        }
        if(self.currentFigure.notTheFirstStep){
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
            [self.currentFigure rotate];
            self.shouldRotate = NO;
        }
        for (MatrixPoint *temp in [self.currentFigure pointsOnBoard]) {
            if(temp.row == 0 || [self.board[temp.row - 1][temp.column]  isEqual: @1] )
            {
                for (MatrixPoint *point in [self.currentFigure pointsOnBoard]) {
                    if([self.board[point.row][point.column] isEqual:@1])
                    {
                        NSLog(@"%d, %d", point.row, point.column);
                    }
                    self.board[point.row][point.column] = @1;
                    [self.board[point.row] replaceObjectAtIndex:BoardColumnsSize withObject:@([[self.board[point.row] lastObject] intValue] - 1)];
                }
                self.isItTimeToCreateNewFigure = YES;
                break;
            }
        }
        [self deleteRows];
    }];
}

-(void)moveCurrentFigure
{
    for (MatrixPoint *temp in self.currentFigure.pointsOnBoard) {
        [temp moveDown];
    }
    [self.currentFigure.anchorPoint moveDown];
    [self.currentFigure.delegate moveFigureDown:self.currentFigure];
}

-(void)generateNewFigure
{
    Figure *newFigure = [[Figure alloc] initWithRandomType];
    self.generatedFigure = newFigure;
}

-(void)deleteRows
{
    NSMutableArray <NSNumber *> *rows = [NSMutableArray arrayWithArray:@[]];
    for(int i = 0; i < BoardRowSize; i++)
        if([[self.board[i] lastObject] intValue] == 0){
            [rows addObject:[NSNumber numberWithInt:i]];
            [self.board removeObjectAtIndex:i];
            NSMutableArray *temp = [[NSMutableArray alloc] init];
            for(int i = 0; i < BoardColumnsSize; i++)
                [temp addObject:[NSNull null]];
            [temp addObject:[NSNumber numberWithInt:BoardColumnsSize]];
            [sharedEngine.board addObject:temp];
            i--;
        }
    if([rows count] > 0)
    {
        [self.delegate rowsAreDeleted:rows];
    }
}


-(void)startFalling
{
    self.currentFigure = self.generatedFigure;
    self.generatedFigure = nil;
    [self.delegate newFigureIsCreated:self.currentFigure];
}
@end
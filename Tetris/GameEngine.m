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
        for(int i = 0; i < BoardRowsNumber; i++)
        {
            NSMutableArray *temp = [[NSMutableArray alloc] init]; //adding NSNulls to board, in order not to crush
            for(int j = 0; j < BoardColumnsNumber; j++)
                [temp addObject:[NSNull null]];
            [temp addObject:[NSNumber numberWithInt:BoardColumnsNumber]]; //this extra column will have number which keeps how many nils are in current row, so not to checking ecery cell for deletion
            [sharedEngine.board addObject:temp];
        }
        sharedEngine.isItTimeToCreateNewFigure = YES;
        [sharedEngine generateNewFigure]; //as it's the first move it board will need already generated figure
        [sharedEngine startTact]; //so it begins :]
    }
    return  sharedEngine;
}

-(void)startTact
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.tactSpeed repeats:YES block:^(NSTimer * _Nonnull timer)
                  {
                      if(self.didSwipeDown)
                      { //if the user used swipe down gesture
                          [self forceDown];
                          [self deleteRows];
                          self.isItTimeToCreateNewFigure = YES;
                          self.didSwipeDown = NO;
                      }
                      if(self.isItTimeToCreateNewFigure)
                      {
                          [self createFigure]; //takes already generated figure
                          [self generateNewFigure]; //generated, for the next start falling function
                          if(self.isGameEnded)
                          {
                              [self.timer invalidate];
                              return;
                          }
                          self.isItTimeToCreateNewFigure = NO;
                      }
                      if(self.currentFigure.notTheFirstStep && !self.isLastMove)
                          [self goTo:Down]; //just takes one row down
                      else
                          self.currentFigure.notTheFirstStep = YES; //it is meant, to keep figure one tact in initial place
                      if(self.shouldTheFigureGoLeftOrRight)
                      {
                          [self goTo:self.goingDirection];
                          self.shouldTheFigureGoLeftOrRight = NO;
                      }
                      if(self.shouldRotate)
                      {
                          if([self isPossibleToRotate]) //every figure, depending on it's orientation is to be checked, if the new bricks that it will take after rotation are available and free
                              [self rotate];
                          self.shouldRotate = NO;
                      }
                      BOOL thereArentAnyDeletableRows = YES; //now these are after brick hit the bottom or another brick. last move it's the state when it can still be moved
                      for (MatrixPoint *temp in [self figureTakenPlaces])
                      {
                          if(((temp.row == 0 || [self.board[temp.row - 1][temp.column]  isEqual: @1])))
                          {
                              thereArentAnyDeletableRows = NO;
                              if(self.isLastMove)
                              {
                                  for (MatrixPoint *point in [self figureTakenPlaces])
                                  {
                                      if([self.board[point.row][point.column]  isEqual: @1])
                                      {
                                          NSLog(@"type %ld, row %d, column %d", (long)self.currentFigure.type, point.row, point.column);
                                      }
                                      self.board[point.row][point.column] = @1;
                                      [self.board[point.row] replaceObjectAtIndex:BoardColumnsNumber withObject:@([[self.board[point.row] lastObject] intValue] - 1)];
                                  }
                                  self.isItTimeToCreateNewFigure = YES;
                                  [self.delegate stickFigure];
                                  [self deleteRows];
                                  break;
                              }
                              else
                              {
                                  self.isLastMove = YES;
                                  self.tactSpeed = TimeForLastMove; //this is the time that is given to user to do his dirty work :]
                                  [self.timer invalidate];
                                  [self startTact];
                                  break;
                              }
                          }
                      }
                      if(thereArentAnyDeletableRows)
                      {
                          self.isLastMove = NO;
                          self.tactSpeed = InitalTactSpeed + self.level * Speeding;
                          [self.timer invalidate];
                          [self startTact];
                      }
                  }];
}

-(void)generateNewFigure
{
    FigureTypes type = arc4random_uniform(HowManyFigures);
    Figure *generatedFigure = [[Figure alloc] init];
    generatedFigure.type = type;
    self.currentFigure.notTheFirstStep = NO;
    generatedFigure.cellCount = 4;
    switch (type) //these are initial setupd for each kind of figure
    {
        case Cube:
        {
            generatedFigure.matrix = @[ @[@1, @1], @[@1, @1]]; //shape of the figure
            break;
        }
        case Mushroom:
        {
            generatedFigure.matrix = @[@[@1, @1, @1], @[@0, @1, @0]];
            break;
        }
        case Seven:
        {
            generatedFigure.matrix = @[@[@1, @1, @1], @[@0, @0, @1]];
            break;
        }
        case ReverseSeven:
        {
            generatedFigure.matrix = @[@[@1, @1, @1], @[@1, @0, @0]];
            break;
        }
        case Row:
        {
            generatedFigure.matrix = @[@[@1, @1, @1, @1]];
            
            break;
        }
        case Thunder:
        {
            generatedFigure.matrix = @[ @[@1, @0], @[@1, @1], @[@0, @1]];
            break;
        }
        case ReverseThunder:
        {
            generatedFigure.matrix = @[ @[@0, @1], @[@1, @1], @[@1, @0]];
            break;
        }
    }
    generatedFigure.orientation = 0;
    self.generatedFigure = generatedFigure;
    [self.delegate newFigureIsGenerated:self.generatedFigure];
}

-(void)createFigure
{
    self.isLastMove = NO;
    self.currentFigure = self.generatedFigure;
    
    switch (self.generatedFigure.type)
    {
        case Cube:
            self.figureTakenPlaces =
            [NSMutableArray arrayWithArray:@[[MatrixPoint initWithRow:BoardRowsNumber - 1 andColumn:BoardColumnsNumber / 2 - 1],
                                             [MatrixPoint initWithRow:BoardRowsNumber - 1 andColumn:BoardColumnsNumber / 2 ],
                                             [MatrixPoint initWithRow:BoardRowsNumber - 2 andColumn:BoardColumnsNumber / 2 - 1],
                                             [MatrixPoint initWithRow:BoardRowsNumber - 2 andColumn:BoardColumnsNumber / 2]]];
            self.figureAnchorPoint = [MatrixPoint initWithRow:self.figureTakenPlaces[0].row andColumn:self.figureTakenPlaces[0].column];
            break;
            
        case Mushroom:
            self.figureTakenPlaces =
            [NSMutableArray arrayWithArray:@[[MatrixPoint initWithRow:BoardRowsNumber - 1 andColumn:BoardColumnsNumber / 2 - 2],
                                             [MatrixPoint initWithRow:BoardRowsNumber - 1 andColumn:BoardColumnsNumber / 2 - 1],
                                             [MatrixPoint initWithRow:BoardRowsNumber - 1 andColumn:BoardColumnsNumber / 2 ],
                                             [MatrixPoint initWithRow:BoardRowsNumber - 2 andColumn:BoardColumnsNumber / 2  - 1]]];
            self.figureAnchorPoint = [MatrixPoint initWithRow:self.figureTakenPlaces[0].row andColumn:self.figureTakenPlaces[0].column];
            break;
            
        case ReverseSeven:
            self.figureTakenPlaces =
            [NSMutableArray arrayWithArray:@[[MatrixPoint initWithRow:BoardRowsNumber - 2 andColumn:BoardColumnsNumber / 2 - 2],
                                             [MatrixPoint initWithRow:BoardRowsNumber - 1 andColumn:BoardColumnsNumber / 2 - 2],
                                             [MatrixPoint initWithRow:BoardRowsNumber - 1 andColumn:BoardColumnsNumber / 2 - 1],
                                             [MatrixPoint initWithRow:BoardRowsNumber - 1 andColumn:BoardColumnsNumber / 2 ]]];
            self.figureAnchorPoint = [MatrixPoint initWithRow:self.figureTakenPlaces[1].row andColumn:self.figureTakenPlaces[1].column];
            
            
            break;
            
        case Seven:
            self.figureTakenPlaces =
            [NSMutableArray arrayWithArray:@[[MatrixPoint initWithRow:BoardRowsNumber - 1 andColumn:BoardColumnsNumber / 2 - 2],
                                             [MatrixPoint initWithRow:BoardRowsNumber - 1 andColumn:BoardColumnsNumber / 2 - 1],
                                             [MatrixPoint initWithRow:BoardRowsNumber - 1 andColumn:BoardColumnsNumber / 2 ],
                                             [MatrixPoint initWithRow:BoardRowsNumber - 2 andColumn:BoardColumnsNumber / 2 ]]];
            self.figureAnchorPoint = [MatrixPoint initWithRow:self.figureTakenPlaces[0].row andColumn:self.figureTakenPlaces[0].column];
            break;
            
        case Row:
            self.figureTakenPlaces =
            [NSMutableArray arrayWithArray:@[[MatrixPoint initWithRow:BoardRowsNumber - 1 andColumn:BoardColumnsNumber / 2 - 2],
                                             [MatrixPoint initWithRow:BoardRowsNumber - 1 andColumn:BoardColumnsNumber / 2 - 1],
                                             [MatrixPoint initWithRow:BoardRowsNumber - 1 andColumn:BoardColumnsNumber / 2 ],
                                             [MatrixPoint initWithRow:BoardRowsNumber - 1 andColumn:BoardColumnsNumber / 2  + 1]]];
            self.figureAnchorPoint = [MatrixPoint initWithRow:self.figureTakenPlaces[0].row andColumn:self.figureTakenPlaces[0].column];
            break;
            
        case Thunder:
            self.figureTakenPlaces =
            [NSMutableArray arrayWithArray:@[[MatrixPoint initWithRow:BoardRowsNumber - 1 andColumn:BoardColumnsNumber / 2 - 1],
                                             [MatrixPoint initWithRow:BoardRowsNumber - 2 andColumn:BoardColumnsNumber / 2 - 1 ],
                                             [MatrixPoint initWithRow:BoardRowsNumber - 2 andColumn:BoardColumnsNumber / 2 ],
                                             [MatrixPoint initWithRow:BoardRowsNumber - 3 andColumn:BoardColumnsNumber / 2 ]]];
            self.figureAnchorPoint = [MatrixPoint initWithRow:self.figureTakenPlaces[0].row andColumn:self.figureTakenPlaces[0].column];
            break;
            
        case ReverseThunder:
            self.figureTakenPlaces =
            [NSMutableArray arrayWithArray:@[[MatrixPoint initWithRow:BoardRowsNumber - 1 andColumn:BoardColumnsNumber / 2 ],
                                             [MatrixPoint initWithRow:BoardRowsNumber - 2 andColumn:BoardColumnsNumber / 2  ],
                                             [MatrixPoint initWithRow:BoardRowsNumber - 2 andColumn:BoardColumnsNumber / 2 - 1],
                                             [MatrixPoint initWithRow:BoardRowsNumber - 3 andColumn:BoardColumnsNumber / 2 - 1]]];
            self.figureAnchorPoint = [MatrixPoint initWithRow:self.figureTakenPlaces[0].row andColumn:self.figureTakenPlaces[0].column - 1];
            break;
            
    }
    for (MatrixPoint *point in self.figureTakenPlaces)
    {
        if([self.board[point.row][point.column] isEqual:@1])
        {
            [self.delegate gameIsEnded];
            return;
        }
    }
    self.generatedFigure = nil;
    [self.delegate newFigureIsCreated:self.currentFigure withAnchor:self.figureAnchorPoint];
}


-(void)deleteRows
{
    NSMutableArray <NSNumber *> *rows = [NSMutableArray arrayWithArray:@[]];
    int score = 0;
    int counter = 0;
    for (int i = 0; i < [self.figureTakenPlaces count]; i++) {
        MatrixPoint *point = self.figureTakenPlaces[i];
        if([[self.board[point.row] lastObject] intValue] == 0){
            score += NormalScore + counter * AdditionalScoreForEachLine;
            [rows addObject:[NSNumber numberWithInt:point.row]];
            [self.board removeObjectAtIndex:point.row];
            NSMutableArray *temp = [[NSMutableArray alloc] init];
            for(int j = 0; j < BoardColumnsNumber; j++)
                [temp addObject:[NSNull null]];
            [temp addObject:[NSNumber numberWithInt:BoardColumnsNumber]];
            [sharedEngine.board addObject:temp];
            counter++;
            i--;
        }
    }
    if([rows count] > 0)
    {
        self.deletedRows += (int)[rows count]; //this is for determining next level
        self.score += score;
        if(self.deletedRows >= RowsNeedToDeleteToChangeLevel)
        {
            self.deletedRows -= RowsNeedToDeleteToChangeLevel;
            if(self.tactSpeed > 0.1) //the fastest speed
                self.tactSpeed += Speeding;
            self.level++;
            [self.delegate levelIsChanged:self.level];
            [self.timer invalidate];
            [self startTact];
        }
        [self.delegate rowsAreDeleted:rows];
    }
}

-(void)forceDown //finding the closest brick
{
    int min = INT_MAX;
    for(MatrixPoint *temp in self.figureTakenPlaces){
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
    for(MatrixPoint *temp in self.figureTakenPlaces){
        self.board[temp.row - min][temp.column] = @1;
        [self.board[temp.row - min] replaceObjectAtIndex:BoardColumnsNumber withObject:@([[self.board[temp.row - min] lastObject] intValue] - 1)];
        temp.row -= min;
    }
    self.figureAnchorPoint = [MatrixPoint initWithRow:self.figureAnchorPoint.row - min andColumn:self.figureAnchorPoint.column];
    [self.delegate figureHasChangedPlace:Down withCount:min];
    [self.delegate stickFigure];
    [self deleteRows];
}

-(BOOL)isPossibleToRotate
{
    switch (self.currentFigure.type) { //writing this fucking function, was the ugliest thing
        case Cube:
            return NO; //Actually it can rotate, but wrote No, for not entering <if> in tact function
            break;
            
        case Row:
        {
            switch (self.currentFigure.orientation) {
                case 0:
                    return (self.figureTakenPlaces[1].row - 2 >= 0
                            && self.figureTakenPlaces[1].row + 1 < BoardRowsNumber
                            && self.board[self.figureTakenPlaces[1].row - 2][self.figureTakenPlaces[1].column] == [NSNull null]
                            && self.board[self.figureTakenPlaces[1].row - 1][self.figureTakenPlaces[1].column] == [NSNull null]
                            && self.board[self.figureTakenPlaces[1].row + 1][self.figureTakenPlaces[1].column] == [NSNull null]);
                    break;
                case 1:
                    return (self.figureTakenPlaces[0].column - 1 >= 0
                            && self.figureTakenPlaces[0].column + 2 < BoardColumnsNumber
                            && self.board[self.figureTakenPlaces[0].row ][self.figureTakenPlaces[0].column - 1] == [NSNull null]
                            && self.board[self.figureTakenPlaces[0].row ][self.figureTakenPlaces[0].column + 1] == [NSNull null]
                            && self.board[self.figureTakenPlaces[0].row ][self.figureTakenPlaces[0].column + 2] == [NSNull null]);
                    break;
            }
            break;
        }
        case Thunder:
        {
            switch (self.currentFigure.orientation) {
                case 0:
                    return (self.figureTakenPlaces[2].column - 2 >= 0
                            && self.figureTakenPlaces[3].row + 2 >= 0
                            && self.board[self.figureTakenPlaces[2].row ][self.figureTakenPlaces[2].column - 2] == [NSNull null]
                            && self.board[self.figureTakenPlaces[3].row + 2][self.figureTakenPlaces[3].column ] == [NSNull null]);
                    break;
                case 1:
                    return (self.figureTakenPlaces[2].column + 1 < BoardColumnsNumber
                            && self.figureTakenPlaces[3].row - 2 - 1 >= 0
                            && self.board[self.figureTakenPlaces[3].row - 2 ][self.figureTakenPlaces[3].column] == [NSNull null]
                            && self.board[self.figureTakenPlaces[0].row][self.figureTakenPlaces[2].column + 1] == [NSNull null]);
                    break;
            }
            break;
        }
        case Mushroom:
        {
            switch (self.currentFigure.orientation) {
                case 0:
                    return (self.figureTakenPlaces[1].row + 1 < BoardRowsNumber
                            && self.board[self.figureTakenPlaces[1].row + 1][self.figureTakenPlaces[1].column] == [NSNull null]);
                    break;
                case 1:
                    return (self.figureTakenPlaces[1].column - 1 >= 0
                            && self.board[self.figureTakenPlaces[1].row ][self.figureTakenPlaces[1].column - 1] == [NSNull null]);
                    break;
                case 2:
                    return (self.figureTakenPlaces[1].row - 1 >= 0
                            && self.board[self.figureTakenPlaces[1].row - 1][self.figureTakenPlaces[1].column] == [NSNull null]);
                    break;
                case 3:
                    return (self.figureTakenPlaces[1].column + 1 < BoardColumnsNumber
                            && self.board[self.figureTakenPlaces[1].row][self.figureTakenPlaces[1].column + 1] == [NSNull null]);
                    break;
            }
            break;
        }
        case ReverseThunder:
        {
            switch (self.currentFigure.orientation) {
                case 0:
                    return (self.figureTakenPlaces[2].row + 1 < BoardRowsNumber
                            && self.figureTakenPlaces[3].column + 2 < BoardColumnsNumber
                            && self.board[self.figureTakenPlaces[2].row + 1][self.figureTakenPlaces[2].column] == [NSNull null]
                            && self.board[self.figureTakenPlaces[1].row][self.figureTakenPlaces[3].column + 2] == [NSNull null]);
                    break;
                    
                case 1:
                    return (self.figureTakenPlaces[2].column - 1 >= 0
                            && self.figureTakenPlaces[0].row - 2 >= 0
                            &&  self.board[self.figureTakenPlaces[2].row][self.figureTakenPlaces[2].column - 1] == [NSNull null]
                            && self.board[self.figureTakenPlaces[0].row - 2][self.figureTakenPlaces[0].column] == [NSNull null]);
                    break;
            }
            break;
        }
        case Seven:
        {
            switch (self.currentFigure.orientation) {
                case 0:
                    return (self.figureTakenPlaces[1].row - 1 >= 0
                            && self.figureTakenPlaces[1].row + 1 < BoardRowsNumber
                            && self.figureTakenPlaces[1].column + 1 < BoardColumnsNumber
                            && self.board[self.figureTakenPlaces[1].row - 1][self.figureTakenPlaces[1].column] == [NSNull null]
                            && self.board[self.figureTakenPlaces[1].row + 1][self.figureTakenPlaces[1].column] == [NSNull null]
                            && self.board[self.figureTakenPlaces[1].row + 1][self.figureTakenPlaces[1].column + 1] == [NSNull null]);
                    break;
                case 1:
                    return (self.figureTakenPlaces[1].column - 1 >= 0
                            && self.figureTakenPlaces[1].row + 1 < BoardRowsNumber
                            && self.figureTakenPlaces[1].column + 1 < BoardColumnsNumber
                            && self.board[self.figureTakenPlaces[1].row + 1][self.figureTakenPlaces[1].column - 1] == [NSNull null]
                            && self.board[self.figureTakenPlaces[1].row ][self.figureTakenPlaces[1].column - 1] == [NSNull null]
                            && self.board[self.figureTakenPlaces[1].row ][self.figureTakenPlaces[1].column + 1] == [NSNull null]);
                    break;
                case 2:
                    return (self.figureTakenPlaces[2].row - 1 >= 0
                            && self.figureTakenPlaces[2].row + 1 < BoardRowsNumber
                            && self.figureTakenPlaces[2].column - 1 >= 0
                            && self.board[self.figureTakenPlaces[2].row + 1][self.figureTakenPlaces[2].column ] == [NSNull null]
                            && self.board[self.figureTakenPlaces[2].row - 1][self.figureTakenPlaces[2].column] == [NSNull null]
                            && self.board[self.figureTakenPlaces[2].row - 1][self.figureTakenPlaces[2].column - 1] == [NSNull null]);
                    break;
                case 3:
                    return (self.figureTakenPlaces[1].column - 1 >= 0
                            && self.figureTakenPlaces[1].row - 1 >= 0
                            && self.figureTakenPlaces[1].column + 1 < BoardColumnsNumber
                            && self.board[self.figureTakenPlaces[1].row][self.figureTakenPlaces[1].column - 1] == [NSNull null]
                            && self.board[self.figureTakenPlaces[1].row ][self.figureTakenPlaces[1].column + 1] == [NSNull null]
                            && self.board[self.figureTakenPlaces[1].row - 1][self.figureTakenPlaces[1].column + 1] == [NSNull null]);
                    break;
            }
            break;
        }
        case ReverseSeven:
        {
            switch (self.currentFigure.orientation) {
                case 0:
                    return (self.figureTakenPlaces[2].row - 1 >= 0
                            && self.figureTakenPlaces[2].row + 1 < BoardRowsNumber
                            && self.figureTakenPlaces[2].column + 1 < BoardColumnsNumber
                            && self.board[self.figureTakenPlaces[2].row + 1][self.figureTakenPlaces[2].column ] == [NSNull null]
                            && self.board[self.figureTakenPlaces[2].row - 1][self.figureTakenPlaces[2].column] == [NSNull null]
                            && self.board[self.figureTakenPlaces[2].row - 1][self.figureTakenPlaces[2].column + 1] == [NSNull null]);
                    break;
                case 1:
                    return (self.figureTakenPlaces[1].column - 1 >= 0
                            && self.figureTakenPlaces[1].row + 1 < BoardRowsNumber
                            && self.figureTakenPlaces[1].column + 1 < BoardColumnsNumber
                            && self.board[self.figureTakenPlaces[1].row][self.figureTakenPlaces[1].column - 1] == [NSNull null]
                            && self.board[self.figureTakenPlaces[1].row ][self.figureTakenPlaces[1].column + 1] == [NSNull null]
                            && self.board[self.figureTakenPlaces[1].row + 1][self.figureTakenPlaces[1].column + 1] == [NSNull null]);
                    break;
                case 2:
                    return (self.figureTakenPlaces[1].column - 1 >= 0
                            && self.figureTakenPlaces[1].row + 1 < BoardRowsNumber
                            && self.figureTakenPlaces[1].row - 1 >= 0
                            && self.board[self.figureTakenPlaces[1].row + 1][self.figureTakenPlaces[1].column - 1] == [NSNull null]
                            && self.board[self.figureTakenPlaces[1].row + 1 ][self.figureTakenPlaces[1].column ] == [NSNull null]
                            && self.board[self.figureTakenPlaces[1].row - 1][self.figureTakenPlaces[1].column] == [NSNull null]);
                    break;
                case 3:
                    return (self.figureTakenPlaces[2].row - 1 >= 0
                            && self.figureTakenPlaces[2].column - 1 >= 0
                            && self.figureTakenPlaces[2].column + 1 < BoardColumnsNumber
                            && self.board[self.figureTakenPlaces[2].row - 1][self.figureTakenPlaces[2].column - 1] == [NSNull null]
                            && self.board[self.figureTakenPlaces[2].row][self.figureTakenPlaces[2].column - 1] == [NSNull null]
                            && self.board[self.figureTakenPlaces[2].row][self.figureTakenPlaces[2].column + 1] == [NSNull null]);
                    break;
            }
            break;
        }
    }
    return NO;
}

-(void)goTo:(Directions)direction
{
    switch (direction) {
        case Left:{
            BOOL canMove = YES;
            for (MatrixPoint *point in self.figureTakenPlaces) {
                if(point.column == 0 || [self.board[point.row][point.column - 1] isEqual:@1]){
                    canMove = NO;
                    break;
                }
            }
            if(canMove){
                for (MatrixPoint *point in self.figureTakenPlaces) {
                    [point moveLeft];
                }
                [self.figureAnchorPoint moveLeft];
                [self.delegate figureHasChangedPlace:Left withCount:1];
            }
            break;
        }
            
        case Right:{
            BOOL canMove = YES;
            for (MatrixPoint *point in self.figureTakenPlaces) {
                if(point.column + 1 >= BoardColumnsNumber || [self.board[point.row][point.column + 1] isEqual:@1]){
                    canMove = NO;
                    break;
                }
            }
            if(canMove){
                for (MatrixPoint *point in self.figureTakenPlaces) {
                    [point moveRight];
                }
                [self.figureAnchorPoint moveRight];
                [self.delegate figureHasChangedPlace:Right withCount:1];
            }
            break;
        }
            
        case Down:{
            for (MatrixPoint *temp in self.figureTakenPlaces) {
                [temp moveDown];
            }
            [self.figureAnchorPoint moveDown];
            [self.delegate figureHasChangedPlace:Down withCount:1];
            break;
        }
    }
}

-(void)rotate //changing orientation
{
    switch (self.currentFigure.type) {
        case Cube:
            break;
        case Mushroom:
        {
            switch (self.currentFigure.orientation) {
                case 0:{
                    
                    self.currentFigure.matrix = @[@[@1, @0], @[@1, @1], @[@1, @0]];
                    [self.figureTakenPlaces replaceObjectAtIndex:0 withObject:[MatrixPoint initWithRow:self.figureTakenPlaces[1].row + 1 andColumn:self.figureTakenPlaces[1].column]];
                    self.figureAnchorPoint = [MatrixPoint initWithRow:self.figureTakenPlaces[0].row andColumn:self.figureTakenPlaces[0].column];
                    
                    break;
                }
                case 1:{
                    self.currentFigure.matrix = @[@[@0, @1, @0], @[@1, @1, @1]];
                    [self.figureTakenPlaces replaceObjectAtIndex:3 withObject:[MatrixPoint initWithRow:self.figureTakenPlaces[1].row  andColumn:self.figureTakenPlaces[1].column - 1]];
                    self.figureAnchorPoint = [MatrixPoint initWithRow:(self.figureTakenPlaces[3].row + 1) andColumn:self.figureTakenPlaces[3].column];
                    
                    break;
                }
                case 2:{
                    
                    self.currentFigure.matrix = @[@[@0, @1], @[@1, @1], @[@0, @1]];
                    [self.figureTakenPlaces replaceObjectAtIndex:2 withObject:[MatrixPoint initWithRow:self.figureTakenPlaces[1].row - 1 andColumn:self.figureTakenPlaces[1].column]];
                    self.figureAnchorPoint = [MatrixPoint initWithRow:self.figureTakenPlaces[0].row andColumn:self.figureTakenPlaces[0].column - 1];
                    break;
                }
                case 3:{
                    self.currentFigure.matrix = @[@[@1, @1, @1], @[@0, @1, @0]];
                    [self.figureTakenPlaces replaceObjectAtIndex:0 withObject:[MatrixPoint initWithRow:self.figureTakenPlaces[1].row  andColumn:self.figureTakenPlaces[1].column + 1]];
                    [self.figureTakenPlaces exchangeObjectAtIndex:0 withObjectAtIndex:3];
                    [self.figureTakenPlaces exchangeObjectAtIndex:2 withObjectAtIndex:3];
                    self.currentFigure.orientation = -1;
                    self.figureAnchorPoint = [MatrixPoint initWithRow:self.figureTakenPlaces[0].row andColumn:self.figureTakenPlaces[0].column];
                    break;
                }
            }
            break;
        }
        case Seven:
        {
            switch (self.currentFigure.orientation) {
                case 0:
                    self.currentFigure.matrix = @[@[@1, @1], @[@1, @0], @[@1, @0]];
                    self.figureTakenPlaces = [NSMutableArray arrayWithArray:@[[MatrixPoint initWithRow:self.figureTakenPlaces[1].row - 1 andColumn:self.figureTakenPlaces[1].column], self.figureTakenPlaces[1], [MatrixPoint initWithRow:self.figureTakenPlaces[1].row + 1 andColumn:self.figureTakenPlaces[1].column], [MatrixPoint initWithRow:self.figureTakenPlaces[1].row + 1 andColumn:self.figureTakenPlaces[1].column + 1]]];
                    self.figureAnchorPoint = [MatrixPoint initWithRow:self.figureTakenPlaces[2].row andColumn:self.figureTakenPlaces[2].column];
                    break;
                case 1:
                    self.currentFigure.matrix = @[@[@1, @0, @0], @[@1, @1, @1]];
                    self.figureTakenPlaces = [NSMutableArray arrayWithArray:@[[MatrixPoint initWithRow:self.figureTakenPlaces[1].row + 1 andColumn:self.figureTakenPlaces[1].column - 1], [MatrixPoint initWithRow:self.figureTakenPlaces[1].row  andColumn:self.figureTakenPlaces[1].column - 1], self.figureTakenPlaces[1], [MatrixPoint initWithRow:self.figureTakenPlaces[1].row  andColumn:self.figureTakenPlaces[1].column + 1]]];
                    self.figureAnchorPoint = [MatrixPoint initWithRow:self.figureTakenPlaces[0].row andColumn:self.figureTakenPlaces[0].column];
                    
                    break;
                case 2:
                    self.currentFigure.matrix = @[@[@0, @1], @[@0, @1], @[@1, @1]];
                    self.figureTakenPlaces = [NSMutableArray arrayWithArray:@[[MatrixPoint initWithRow:self.figureTakenPlaces[2].row + 1 andColumn:self.figureTakenPlaces[2].column ], self.figureTakenPlaces[2], [MatrixPoint initWithRow:self.figureTakenPlaces[2].row - 1  andColumn:self.figureTakenPlaces[2].column ],  [MatrixPoint initWithRow:self.figureTakenPlaces[2].row - 1  andColumn:self.figureTakenPlaces[2].column - 1]]];
                    self.figureAnchorPoint = [MatrixPoint initWithRow:self.figureTakenPlaces[0].row andColumn:self.figureTakenPlaces[0].column - 1];
                    break;
                case 3:
                    self.currentFigure.matrix = @[@[@1, @1, @1], @[@0, @0, @1]];
                    self.figureTakenPlaces = [NSMutableArray arrayWithArray:@[[MatrixPoint initWithRow:self.figureTakenPlaces[1].row  andColumn:self.figureTakenPlaces[1].column - 1], self.figureTakenPlaces[1], [MatrixPoint initWithRow:self.figureTakenPlaces[1].row  andColumn:self.figureTakenPlaces[1].column + 1],  [MatrixPoint initWithRow:self.figureTakenPlaces[1].row - 1 andColumn:self.figureTakenPlaces[1].column + 1]]];
                    self.currentFigure.orientation = -1;
                    self.figureAnchorPoint = [MatrixPoint initWithRow:self.figureTakenPlaces[0].row andColumn:self.figureTakenPlaces[0].column];
                    break;
            }
            break;
        }
        case ReverseSeven:
        {
            switch (self.currentFigure.orientation) {
                case 0:
                    self.currentFigure.matrix = @[@[@1, @0], @[@1, @0], @[@1, @1]];
                    self.figureTakenPlaces = [NSMutableArray arrayWithArray:@[[MatrixPoint initWithRow:self.figureTakenPlaces[2].row + 1 andColumn:self.figureTakenPlaces[2].column], self.figureTakenPlaces[2], [MatrixPoint initWithRow:self.figureTakenPlaces[2].row - 1 andColumn:self.figureTakenPlaces[2].column], [MatrixPoint initWithRow:self.figureTakenPlaces[2].row - 1 andColumn:self.figureTakenPlaces[2].column + 1]]];
                    self.figureAnchorPoint = [MatrixPoint initWithRow:self.figureTakenPlaces[0].row andColumn:self.figureTakenPlaces[0].column];
                    break;
                case 1:
                    self.currentFigure.matrix = @[@[@0, @0, @1], @[@1, @1, @1]];
                    self.figureTakenPlaces = [NSMutableArray arrayWithArray:@[[MatrixPoint initWithRow:self.figureTakenPlaces[1].row  andColumn:self.figureTakenPlaces[1].column - 1], self.figureTakenPlaces[1],  [MatrixPoint initWithRow:self.figureTakenPlaces[1].row  andColumn:self.figureTakenPlaces[1].column + 1],  [MatrixPoint initWithRow:self.figureTakenPlaces[1].row + 1  andColumn:self.figureTakenPlaces[1].column + 1]]];
                    self.figureAnchorPoint = [MatrixPoint initWithRow:self.figureTakenPlaces[0].row + 1 andColumn:self.figureTakenPlaces[0].column];
                    break;
                case 2:
                    self.currentFigure.matrix = @[@[@1, @1], @[@0, @1], @[@0, @1]];
                    self.figureTakenPlaces = [NSMutableArray arrayWithArray:@[[MatrixPoint initWithRow:self.figureTakenPlaces[1].row + 1 andColumn:self.figureTakenPlaces[1].column - 1], [MatrixPoint initWithRow:self.figureTakenPlaces[1].row + 1  andColumn:self.figureTakenPlaces[1].column], self.figureTakenPlaces[1], [MatrixPoint initWithRow:self.figureTakenPlaces[1].row - 1  andColumn:self.figureTakenPlaces[1].column]]];
                    self.figureAnchorPoint = [MatrixPoint initWithRow:self.figureTakenPlaces[0].row andColumn:self.figureTakenPlaces[0].column];
                    break;
                case 3:
                    self.currentFigure.matrix = @[@[@1, @1, @1], @[@1, @0, @0]];
                    self.figureTakenPlaces = [NSMutableArray arrayWithArray:@[[MatrixPoint initWithRow:self.figureTakenPlaces[2].row - 1 andColumn:self.figureTakenPlaces[2].column - 1],  [MatrixPoint initWithRow:self.figureTakenPlaces[2].row  andColumn:self.figureTakenPlaces[2].column - 1], self.figureTakenPlaces[2],  [MatrixPoint initWithRow:self.figureTakenPlaces[2].row  andColumn:self.figureTakenPlaces[2].column + 1]]];
                    self.currentFigure.orientation = -1;
                    self.figureAnchorPoint = [MatrixPoint initWithRow:self.figureTakenPlaces[1].row andColumn:self.figureTakenPlaces[1].column];
                    break;
            }
            break;
        }
        case Row:
        {
            switch (self.currentFigure.orientation){
                case 0:{
                    
                    self.currentFigure.matrix = @[@[@1], @[@1], @[@1], @[@1]];
                    MatrixPoint *point = self.figureTakenPlaces[1];
                    self.figureTakenPlaces = [NSMutableArray arrayWithArray:@[point, [MatrixPoint initWithRow:point.row + 1 andColumn:point.column], [MatrixPoint initWithRow:point.row - 1 andColumn:point.column], [MatrixPoint initWithRow:point.row - 2 andColumn:point.column]]];
                    self.figureAnchorPoint = [MatrixPoint initWithRow:self.figureTakenPlaces[1].row  andColumn:self.figureTakenPlaces[1].column];
                    break;
                }
                case 1:{
                    self.currentFigure.matrix = @[@[@1, @1, @1, @1]];
                    MatrixPoint *point = self.figureTakenPlaces[0];
                    self.figureTakenPlaces = [NSMutableArray arrayWithArray:@[[MatrixPoint initWithRow:point.row  andColumn:point.column - 1], point, [MatrixPoint initWithRow:point.row  andColumn:point.column + 1], [MatrixPoint initWithRow:point.row  andColumn:point.column + 2]]];
                    self.currentFigure.orientation = -1;
                    self.figureAnchorPoint = [MatrixPoint initWithRow:self.figureTakenPlaces[0].row andColumn:self.figureTakenPlaces[0].column];
                    break;
                }
            }
            break;
        }
        case Thunder:
        {
            switch (self.currentFigure.orientation) {
                case 0:
                    self.currentFigure.matrix = @[ @[@0, @1, @1], @[@1, @1, @0]];
                    self.figureTakenPlaces = [NSMutableArray arrayWithArray:@[[MatrixPoint initWithRow:self.figureTakenPlaces[2].row andColumn:self.figureTakenPlaces[2].column - 2 ], self.figureTakenPlaces[1], self.figureTakenPlaces[0], [MatrixPoint initWithRow:self.figureTakenPlaces[3].row + 2 andColumn:self.figureTakenPlaces[3].column]]];
                    self.figureAnchorPoint = [MatrixPoint initWithRow:self.figureTakenPlaces[0].row + 1 andColumn:self.figureTakenPlaces[0].column];
                    break;
                case 1:
                    self.currentFigure.matrix = @[ @[@1, @0], @[@1, @1], @[@0, @1]];
                    self.figureTakenPlaces = [NSMutableArray arrayWithArray:@[self.figureTakenPlaces[2], self.figureTakenPlaces[1], [MatrixPoint initWithRow:self.figureTakenPlaces[0].row andColumn:self.figureTakenPlaces[2].column + 1 ],   [MatrixPoint initWithRow:self.figureTakenPlaces[3].row - 2 andColumn:self.figureTakenPlaces[3].column]]];
                    self.figureAnchorPoint = [MatrixPoint initWithRow:self.figureTakenPlaces[0].row andColumn:self.figureTakenPlaces[0].column];
                    self.currentFigure.orientation = -1;
                    break;
                    
                default:
                    break;
            }
            break;
        }
        case ReverseThunder:
        {
            switch (self.currentFigure.orientation) {
                case 0:
                    self.currentFigure.matrix = @[ @[@1, @1, @0], @[@0, @1, @1]];
                    self.figureTakenPlaces = [NSMutableArray arrayWithArray:@[[MatrixPoint initWithRow:self.figureTakenPlaces[2].row + 1 andColumn:self.figureTakenPlaces[2].column ], self.figureTakenPlaces[0], self.figureTakenPlaces[1], [MatrixPoint initWithRow:self.figureTakenPlaces[1].row  andColumn:self.figureTakenPlaces[3].column + 2]]];
                    self.figureAnchorPoint = [MatrixPoint initWithRow:self.figureTakenPlaces[0].row  andColumn:self.figureTakenPlaces[0].column];
                    break;
                    
                case 1:
                    self.currentFigure.matrix = @[ @[@0, @1], @[@1, @1], @[@1, @0]];
                    self.figureTakenPlaces = [NSMutableArray arrayWithArray:@[self.figureTakenPlaces[1], self.figureTakenPlaces[2], [MatrixPoint initWithRow:self.figureTakenPlaces[2].row andColumn:self.figureTakenPlaces[2].column - 1 ],   [MatrixPoint initWithRow:self.figureTakenPlaces[0].row - 2  andColumn:self.figureTakenPlaces[0].column ]]];
                    self.figureAnchorPoint = [MatrixPoint initWithRow:self.figureTakenPlaces[1].row andColumn:self.figureTakenPlaces[1].column - 1];
                    self.currentFigure.orientation = -1;
                    break;
            }
        }
    }
    self.currentFigure.orientation ++;
    [self.delegate figureIsRotated:self.currentFigure withAnchor:self.figureAnchorPoint];
}

-(void)clearBoard
{
    for(int i = 0; i < [self.board count]; i++){
        for(int j = 0; j < BoardColumnsNumber; j++)
            [self.board[i] replaceObjectAtIndex:j withObject:[NSNull null]];
        [self.board[i] replaceObjectAtIndex:BoardColumnsNumber withObject:[NSNumber numberWithInt:BoardColumnsNumber]];
    }
}

-(void)endGame
{
    [self.timer invalidate];
    [self clearBoard];
    [self.delegate gameIsEnded];
}

@end

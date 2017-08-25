//
//  Definitions.h
//  Tetris
//
//  Created by Vahe Karamyan on 15.08.17.
//  Copyright © 2017 Vahe Karamyan. All rights reserved.
//

#ifndef Definitions_h
#define Definitions_h

#define BoardRowSize 14
#define BoardColumnsSize 10
#define InitalTactSpeed 0.6
#define HowManyFigures 7
#define CellSize 25
#define Speeding -0.05
#define TimeForLastMove 0.2
#define RowsNeedToDeleteToChangeLevel 10.0
#define GeneratedFigureCellSize 20
#define FastAnimationSpeed 0.1
#define NormalScore 10
#define AdditionalScoreForEachLine 5
#define Green [UIColor colorWithRed:0.85 green:0.92 blue:0.85 alpha:1.0]
#define LightGreen [UIColor colorWithRed:0.95 green:0.97 blue:0.93 alpha:1.0]




typedef NS_ENUM(NSInteger, FigureTypes) {
    Thunder,
    Seven,
    ReverseSeven,
    ReverseThunder,
    Row,
    Cube,
    Mushroom 
};

typedef NS_ENUM(NSInteger, Directions) {
    Right,
    Left
};


#endif /* Definitions_h */

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
#define CellSize 290 / BoardColumnsSize


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

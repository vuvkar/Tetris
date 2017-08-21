//
//  Definitions.h
//  Tetris
//
//  Created by Vahe Karamyan on 15.08.17.
//  Copyright © 2017 Vahe Karamyan. All rights reserved.
//

#ifndef Definitions_h
#define Definitions_h

#define BoardRowSize 15
#define BoardColumnsSize 10
#define InitalTactSpeed 0.6
#define HowManyFigures 3
#define CellSize 290 / BoardColumnsSize


typedef NS_ENUM(NSInteger, FigureTypes) {
    Row,
    Cube,
    Mushroom,
    Thunder
    
   // ReverseIdeal,
   // Seven,
   // ReverseSeven,
};

typedef NS_ENUM(NSInteger, Directions) {
    Right,
    Left
};


#endif /* Definitions_h */

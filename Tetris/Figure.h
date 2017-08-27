//
//  Figure.h
//  Tetris
//
//  Created by Vahe Karamyan on 15.08.17.
//  Copyright © 2017 Vahe Karamyan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MatrixPoint.h"
#import "Definitions.h"
#import "GameEngine.h"
@class Figure;

@interface Figure : NSObject

@property NSArray <NSArray <NSNumber *> *>* matrix;
@property FigureTypes type;
@property int cellCount;
@property int orientation;
@property BOOL notTheFirstStep;

@end

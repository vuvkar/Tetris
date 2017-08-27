//
//  CellView.h
//  Tetris
//
//  Created by Vahe Karamyan on 16.08.17.
//  Copyright © 2017 Vahe Karamyan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Definitions.h"
#import "ImageManager.h"

@interface CellView : UIView

@property int row;

-(instancetype)initForFigure:(FigureTypes)figure andSize:(double)size;

@end

//
//  ImageManager.h
//  Tetris
//
//  Created by Vahe on 8/24/17.
//  Copyright © 2017 Vahe Karamyan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ImageManager : NSObject

+(UIImage*)resizeImage:(UIImage *)image withWidth:(double)width withHeight:(double)height;

@end

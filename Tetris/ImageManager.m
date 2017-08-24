//
//  ImageManager.m
//  Tetris
//
//  Created by Vahe on 8/24/17.
//  Copyright © 2017 Vahe Karamyan. All rights reserved.
//

#import "ImageManager.h"

@implementation ImageManager

+(UIImage*)resizeImage:(UIImage *)image withWidth:(double)width withHeight:(double)height
{
    CGSize newSize = CGSizeMake(width, height);
    float widthRatio = newSize.width / image.size.width;
    float heightRatio = newSize.height / image.size.height;
    
    if(widthRatio > heightRatio)
    {
        newSize=CGSizeMake(image.size.width * heightRatio, image.size.height * heightRatio);
    }
    else
    {
        newSize=CGSizeMake(image.size.width * widthRatio, image.size.height * widthRatio);
    }
    
    
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}


@end

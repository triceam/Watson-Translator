//
//  UIImageResizing.m
//  OCR-Test
//
//  Created by Andrew Trice on 8/5/15.
//  Copyright (c) 2015 Andrew Trice. All rights reserved.
//

#import "UIImageResizing.h"

@implementation UIImage (Resize)

- (UIImage*)scaleToSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0.0, size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, size.width, size.height), self.CGImage);
    
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

@end;

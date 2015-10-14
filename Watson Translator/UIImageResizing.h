//
//  UIImageResizing.h
//  OCR-Test
//
//  Created by Andrew Trice on 8/5/15.
//  Copyright (c) 2015 Andrew Trice. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIImage (Resize)
- (UIImage*)scaleToSize:(CGSize)size;
@end

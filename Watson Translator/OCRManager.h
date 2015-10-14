//
//  OCRManager.h
//  Watson Translator
//
//  Created by Andrew Trice on 9/11/15.
//  Copyright (c) 2015 Andrew Trice. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TesseractOCR/TesseractOCR.h>
#import "UIImageResizing.h"
#import "GPUImage.h"

@interface OCRManager : NSObject <G8TesseractDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (strong, nonatomic) NSString *recognizedText;
@property (strong, nonatomic) UIImage *selectedImage;
@property (strong, nonatomic) UIImage *processedImage;
@property (strong, nonatomic) G8Tesseract *tesseract;

@property (copy) void (^onProgress)(double);
@property (copy) void (^onCompletion)(void);
@property (copy) void (^onSelection)(void);

+(OCRManager*) sharedInstance;

-(void) recognizeFromCamera:(UIViewController*)vc onImageSelect:(void (^)(void))onSelection withProgress:(void (^)(double progress))onProgress withCompletion:(void (^)(void))onCompletion;
-(void) recognizeFromFile:(UIViewController*)vc onImageSelect:(void (^)(void))onSelection withProgress:(void (^)(double progress))onProgress withCompletion:(void (^)(void))onCompletion;
-(void) recognizeFromImage:(UIImage*)image;

@end

//
//  OCRManager.m
//  Watson Translator
//
//  Created by Andrew Trice on 9/11/15.
//  Copyright (c) 2015 Andrew Trice. All rights reserved.
//

#import "OCRManager.h"

@implementation OCRManager

@synthesize recognizedText;
@synthesize selectedImage;
@synthesize processedImage;
@synthesize tesseract;



+(OCRManager*) sharedInstance {
    
    static OCRManager *instance = nil;
    OCRManager *strongInstance = instance;
    
    @synchronized(self) {
        if (strongInstance == nil) {
            strongInstance = [[[self class] alloc] init];
            instance = strongInstance;
        }
    }
    
    return strongInstance;
}

- (id) init {
    self = [super init];
    if (self) {
        self.tesseract = [[G8Tesseract alloc] initWithLanguage:@"eng"];
        self.tesseract.delegate = self;
        self.tesseract.engineMode = G8OCREngineModeTesseractOnly;
        self.tesseract.charWhitelist = @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz123456789.,$?";
        self.processedImage = nil;
        self.recognizedText = nil;
    }
    return self;
}


-(void) recognizeFromCamera:(UIViewController*)vc onImageSelect:(void (^)(void))onSelection withProgress:(void (^)(double progress))onProgress withCompletion:(void (^)(void))onCompletion {
    self.onSelection = onSelection;
    self.onProgress = onProgress;
    self.onCompletion = onCompletion;
    [self presentImagePicker:UIImagePickerControllerSourceTypeCamera fromController:vc];
}

-(void) recognizeFromFile:(UIViewController*)vc onImageSelect:(void (^)(void))onSelection withProgress:(void (^)(double progress))onProgress withCompletion:(void (^)(void))onCompletion {
    self.onSelection = onSelection;
    self.onProgress = onProgress;
    self.onCompletion = onCompletion;
    [self presentImagePicker:UIImagePickerControllerSourceTypePhotoLibrary fromController:vc];
}







- (void) presentImagePicker:(UIImagePickerControllerSourceType) sourceType fromController:(UIViewController*) vc{
    
    self.selectedImage = nil;
    self.recognizedText = @"";
    
    if ( sourceType == UIImagePickerControllerSourceTypeCamera  && ![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                              message:@"Device has no camera"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles: nil];
        [myAlertView show];
    };
    
    if ( sourceType != UIImagePickerControllerSourceTypeCamera || [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] ){
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = NO;
        picker.sourceType = sourceType;
        
        [vc presentViewController:picker animated:YES completion:NULL];
    }
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    self.selectedImage = image;
    
    if (self.onSelection != nil) {
        self.onSelection();
    }
    
    if (image != nil ) {
        [[OCRManager sharedInstance] recognizeFromImage:image];
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
        
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}



-(void) recognizeFromImage:(UIImage*)image {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void) {
        
        self.tesseract.image = [self prepareImage:image];
        
        [self.tesseract recognize];
        //NSLog(@"%@", [self.tesseract recognizedText]);
        
        NSArray *words = [self.tesseract recognizedBlocksByIteratorLevel:G8PageIteratorLevelWord];
        self.processedImage = [self.tesseract imageWithBlocks:words drawText:YES thresholded:NO];
        
        self.recognizedText = [self getConfidentResponse];
        
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            if (self.onCompletion){
                self.onCompletion();
            }
        });
    });
}


-(UIImage*) prepareImage:(UIImage*)sourceImage {
    
    // there is probably a faster way to process the image
    // maybe chained filters?
    
    GPUImageAverageLuminanceThresholdFilter * avgLuminanceThresholdFilter = [[GPUImageAverageLuminanceThresholdFilter alloc] init];
    avgLuminanceThresholdFilter.thresholdMultiplier = 0.67;
    
    GPUImageAdaptiveThresholdFilter * adaptiveThresholdFilter = [[GPUImageAdaptiveThresholdFilter alloc] init];
    adaptiveThresholdFilter.blurRadiusInPixels = 0.67;
    
    GPUImageUnsharpMaskFilter *unsharpMaskFilter = [[GPUImageUnsharpMaskFilter alloc] init];
    unsharpMaskFilter.blurRadiusInPixels = 4.0;
    
    GPUImageAdaptiveThresholdFilter *stillImageFilter = [[GPUImageAdaptiveThresholdFilter alloc] init];
    stillImageFilter.blurRadiusInPixels = 1.0;
    
    GPUImageContrastFilter * contrastFilter = [[GPUImageContrastFilter alloc] init];
    contrastFilter.contrast = 0.75;
    
    GPUImageBrightnessFilter * brightnessFilter = [[GPUImageBrightnessFilter alloc] init];
    brightnessFilter.brightness = -0.25;
    
    float aspectRatio = sourceImage.size.width / sourceImage.size.height;
    float w = 800;
    float h = w/aspectRatio;
    
    
    //unsharpen
    UIImage *processingImage = [unsharpMaskFilter imageByFilteringImage:sourceImage];
    
    //adjust brightness and contrast
    processingImage = [contrastFilter imageByFilteringImage:processingImage];
    processingImage = [brightnessFilter imageByFilteringImage:processingImage];
    
    //make the image smaller (faster OCR)
    processingImage = [processingImage scaleToSize:CGSizeMake(w, h)];
    
    //convert to binary black/white pixels
    processingImage = [avgLuminanceThresholdFilter imageByFilteringImage:processingImage];
    
    return processingImage;
}



-(NSString*) getConfidentResponse {
    
    NSString *confidentResponse = @"";
    NSArray *recognizedWords = [self.tesseract recognizedBlocksByIteratorLevel:G8PageIteratorLevelWord];
    
    for (id object in recognizedWords) {
        G8RecognizedBlock *block = (G8RecognizedBlock*) object;
        
        if (block.confidence > 56.0) {
            
            NSString *format;
            
            if ( confidentResponse.length <= 0){
                confidentResponse = block.text;
            }
            else {
                format = @"%@ %@";
                confidentResponse = [NSString stringWithFormat:@"%@ %@", confidentResponse, block.text];
            }
            
            
        }
    }
    return confidentResponse;
}


- (void)progressImageRecognitionForTesseract:(G8Tesseract *)tesseract {
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        if (self.onProgress){
            self.onProgress((float)self.tesseract.progress/100.0);
        }
    });
}

- (BOOL)shouldCancelImageRecognitionForTesseract:(G8Tesseract *)tesseract {
    return NO;  // return YES, if you need to interrupt tesseract before it finishes
}


- (UIImage *)preprocessedImageForTesseract:(G8Tesseract *)tesseract sourceImage:(UIImage *)sourceImage{
    
    //return sourceImage to bypass tesseract preprocessing - we'll handle that on our own
    return sourceImage;
}

@end

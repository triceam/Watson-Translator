//
//  ViewController.m
//  Watson Translator
//
//  Created by Andrew Trice on 9/9/15.
//  Copyright (c) 2015 Andrew Trice. All rights reserved.
//

#import "ViewController.h"
#import "AudioManager.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize translationManager;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.translationManager = [[TranslationManager alloc] init];
    
    [self setInitialState];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)recognizeFromPhoto:(id)sender {
    
    [[OCRManager sharedInstance] recognizeFromCamera:self
                                       onImageSelect:^{ [self selectedImage]; }
                                        withProgress:^(double progress)  { [self setProgress:progress]; }
                                      withCompletion:^{ [self complete]; }];
}

- (IBAction)recognizeFromFile:(id)sender {
    
    [[OCRManager sharedInstance] recognizeFromFile:self
                                     onImageSelect:^{ [self selectedImage]; }
                                        withProgress:^(double progress)  { [self setProgress:progress]; }
                                      withCompletion:^{ [self complete]; }];
}

- (void) setInitialState {
    
    [self.progressView setProgress:0.0 animated:NO];
    self.originalImage.image = nil;
    self.originalImage.alpha = 1.0;
    self.preparedImage.alpha = 0.0;
}

-(void) selectedImage {
    self.gettingStartedLabel.alpha = 0.0;
    self.originalImage.alpha = 1.0;
    self.preparedImage.alpha = 0.0;
    [self.progressView setProgress:0.0 animated:YES];
    self.originalImage.image = [OCRManager sharedInstance].selectedImage;
}

- (void) setProgress:(double) progress {
    
    //NSLog( @"progress %f", progress);
    [self.progressView setProgress:progress  animated:YES];
}

- (void) complete {
    //NSLog( [OCRManager sharedInstance].recognizedText );
    [self updateOutputText];
    [self.progressView setProgress:1.0  animated:YES];
    self.preparedImage.image = [OCRManager sharedInstance].processedImage;
    [self requestTranslation];
    
    [UIView animateWithDuration:0.75
                          delay:0.25
                        options: UIViewAnimationCurveEaseOut
                     animations:^{
                         self.preparedImage.alpha = 1.0;
                         self.originalImage.alpha = 0.0;
                     }
                     completion:nil];
}

- (void) updateOutputText {
    
    self.outputText.text = [NSString stringWithFormat:@"RECOGNIZED TEXT:\n%@\n\nTRANSLATION:\n%@", [OCRManager sharedInstance].recognizedText, self.translationManager.lastTranslation];
}

- (void) requestTranslation {
    
    [self.translationManager requestTranslation:[OCRManager sharedInstance].recognizedText forLanguage:[self targetLanguage] onCompletion:^(NSString *translation) {
        
        [self updateOutputText];
    }];
}



- (IBAction)playAudioTranslation:(id)sender{
    
    [[AudioManager sharedInstance] playSynthesizedFLACAudio:self.translationManager.lastTranslation withLanguage:[self targetLanguage]];
}


- (IBAction)languageSelectionChange:(id)sender {
    
    [self requestTranslation];
}


-(NSString*) targetLanguage {
    switch (self.languagePicker.selectedSegmentIndex) {
        case 0: return @"es"; break;
        case 1: return @"fr"; break;
        default: return @"en"; break;
    }
}


@end

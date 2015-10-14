//
//  ViewController.h
//  Watson Translator
//
//  Created by Andrew Trice on 9/9/15.
//  Copyright (c) 2015 Andrew Trice. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OCRManager.h"
#import "TranslationManager.h"

@interface ViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

- (IBAction)recognizeFromPhoto:(id)sender;
- (IBAction)recognizeFromFile:(id)sender;
- (IBAction)playAudioTranslation:(id)sender;
- (IBAction)languageSelectionChange:(id)sender;


@property (nonatomic, strong) IBOutlet UIImageView *originalImage;
@property (nonatomic, strong) IBOutlet UIImageView *preparedImage;
@property (nonatomic, strong) IBOutlet UIProgressView *progressView;
@property (nonatomic, strong) IBOutlet UITextView *outputText;
@property (nonatomic, strong) IBOutlet UILabel *gettingStartedLabel;
@property (nonatomic, strong) IBOutlet UISegmentedControl *languagePicker;



@property (nonatomic, strong) TranslationManager *translationManager;

@end


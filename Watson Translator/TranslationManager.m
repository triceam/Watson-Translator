//
//  TranslationManager.m
//  Watson Translator
//
//  Created by Andrew Trice on 9/17/15.
//  Copyright (c) 2015 Andrew Trice. All rights reserved.
//

#import "TranslationManager.h"

@implementation TranslationManager

@synthesize lastTranslation;

-(void) requestTranslation:(NSString*)text forLanguage:(NSString*)language onCompletion:(void (^)(NSString* translation))onCompletion {
    
    self.lastTranslation = text;
    
    NSDictionary *params = @{   @"text":text,
                                @"source":@"en",
                                @"target":language
                                };
    
    IMFResourceRequest * imfRequest = [IMFResourceRequest requestWithPath:@"https://watson-mobile-translator.mybluemix.net/translate" method:@"GET" parameters:params];
    [imfRequest sendWithCompletionHandler:^(IMFResponse *response, NSError *error) {
        
        NSDictionary* json = response.responseJson;
        NSArray *translations = [json objectForKey:@"translations"];
        NSDictionary *translationObj = [translations objectAtIndex:0];
        self.lastTranslation = [translationObj objectForKey:@"translation"];
        
        NSLog(@"translation %@", language);
        
        
        if (onCompletion != nil) {
            onCompletion(self.lastTranslation);
        }
        /*dispatch_async(dispatch_get_main_queue(), ^{
            self.outputText.text = [NSString stringWithFormat:@"%@\n\nTRANSLATION:\n%@", self.outputText.text, translation];
        });
        [self playSynthesizedAudio:translation withLanguage:@""];*/
    }];
}

@end

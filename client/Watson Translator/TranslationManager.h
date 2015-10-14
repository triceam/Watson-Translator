//
//  TranslationManager.h
//  Watson Translator
//
//  Created by Andrew Trice on 9/17/15.
//  Copyright (c) 2015 Andrew Trice. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IMFURLProtocol.h>

@interface TranslationManager : NSObject

@property (strong, nonatomic) NSString *lastTranslation;

-(void) requestTranslation:(NSString*)text forLanguage:(NSString*)language onCompletion:(void (^)(NSString* translation))onCompletion;

@end

//
//  AudioManager.h
//  Watson Translator
//
//  Created by Andrew Trice on 9/11/15.
//  Copyright (c) 2015 Andrew Trice. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ORGMEngine.h"

@interface AudioManager : NSObject <ORGMEngineDelegate>

@property (strong, nonatomic) ORGMEngine *orgmPlayer;

+(AudioManager*) sharedInstance;

-(void) playSynthesizedFLACAudio:(NSString*) phrase withLanguage:(NSString*) language;
-(void) stop;


@end

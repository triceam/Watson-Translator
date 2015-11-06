//
//  AudioManager.m
//  Watson Translator
//
//  Created by Andrew Trice on 9/11/15.
//  Copyright (c) 2015 Andrew Trice. All rights reserved.
//

#import "AudioManager.h"

@implementation AudioManager

@synthesize orgmPlayer;


+(AudioManager*) sharedInstance {
    
    static AudioManager *instance = nil;
    AudioManager *strongInstance = instance;
    
    @synchronized(self) {
        if (strongInstance == nil) {
            strongInstance = [[[self class] alloc] init];
            instance = strongInstance;
        }
    }
    
    return strongInstance;
}


-(void) playSynthesizedFLACAudio:(NSString*) phrase withLanguage:(NSString*) language {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void) {
        
        if (self.orgmPlayer != nil) {
            [self.orgmPlayer stop];
        }
        
        NSString *voice = @"en-US_AllisonVoice";
        if ( [language  isEqual: @"es"] )
            voice = @"es-US_SofiaVoice";
        else if ([language  isEqual: @"fr"] )
            voice = @"fr-FR_ReneeVoice";
        
        
        NSString *urlString = [NSString stringWithFormat:@"https://appname.mybluemix.net/synthesize?text=%@&download=1&voice=%@&accept=audio/flac", phrase, voice ];
        NSString* webStringURL = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *flacURL = [NSURL URLWithString:webStringURL];
        
        NSData *audioData = [NSData dataWithContentsOfURL:flacURL];
        NSString *docDirPath = NSTemporaryDirectory() ;
        NSString *filePath = [NSString stringWithFormat:@"%@transcript.flac", docDirPath ];
        [audioData writeToFile:filePath atomically:YES];
        
        NSURL* fileUrl = [NSURL fileURLWithPath:filePath];
        
        if (self.orgmPlayer == nil) {
            self.orgmPlayer = [[ORGMEngine alloc] init];
            self.orgmPlayer.delegate = self;
        }
        
        [self.orgmPlayer playUrl:fileUrl];
    
    });
}


-(void) stop {
    [self.orgmPlayer stop];
}


- (NSURL*)engineExpectsNextUrl:(ORGMEngine*)engine {
    
    return nil;
}

- (void)engine:(ORGMEngine*)engine didChangeState:(ORGMEngineState)state {
    
    return;
}

@end

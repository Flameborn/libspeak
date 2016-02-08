////////////////////////////////////////////////
//
//  Listener.m
//  speak
//
//  Created by Edward Puccini on 08.02.16.
//  Copyright © 2016 Edward Puccini. All rights reserved.
//
////////////////////////////////////////////////

#import "Listener.h"

////////////////////////////////////////////////

@implementation Listener

@synthesize commands=_commands;
@synthesize command_dispatch=_command_dispatch;
@synthesize speechRecognizer=_speechRecognizer;
@synthesize done=_done;

- (id)init
{
    self = [super init];
    _speechRecognizer = [[NSSpeechRecognizer alloc] init];
    _commands = [[NSMutableArray alloc] init];
    
    [_speechRecognizer setCommands:[_commands copy]];
    [_speechRecognizer setDelegate:self];
    [_speechRecognizer setListensInForegroundOnly:YES];
    [_speechRecognizer setBlocksOtherRecognizers:YES];
    _done = NO;
    
    // start runloop
    [self performSelectorInBackground:@selector(mainLoop) withObject:nil];
    return self;
}

- (void)speechRecognizer:(NSSpeechRecognizer *)sender didRecognizeCommand:(id)aCmd {
    
    for (int i = 0; i < sizeof(_commands); i++) {
        NSString* command_string = _commands[i];

        if ([(NSString *)aCmd isEqualToString:command_string]) {
            char pszForeignText[1024];
            strcpy(pszForeignText, [command_string
                                        cStringUsingEncoding:[NSString defaultCStringEncoding]]);
            (*did_recognize_command_callback)(pszForeignText);
        }
    }
}

- (void)mainLoop
{
    // Add your sources or timers to the run loop and do any other setup.
    do
    {
        // Start the run loop but return after each source is handled.
        SInt32 result = CFRunLoopRunInMode(kCFRunLoopDefaultMode, 10, YES);
        
        // If a source explicitly stopped the run loop, or if there are no
        // sources or timers, go ahead and exit.
        if (result == kCFRunLoopRunStopped)// || (result == kCFRunLoopRunFinished))
            _done = YES;
        // Check for any other exit conditions here and set the
                // done variable as needed.
    }
    while (!_done);
    
    // Clean up code here. Be sure to release any allocated autorelease pools.
}

- (void)registerDidRecognizeCommand:(drc_callback)cb
{
    did_recognize_command_callback = cb;
}

- (void)addCommand:(NSString*)command_string
{
    [_commands addObject:command_string];
    [_speechRecognizer setCommands:[_commands copy]];
}

- (void)startListening
{
    [_speechRecognizer startListening];
}

- (void)stopListening
{
    [_speechRecognizer stopListening];
}

@end

//
//  AppDelegate.m
//  OSX
//
//  Created by TracyYih on 13-8-24.
//  Copyright (c) 2013年 TracyYih. All rights reserved.
//

#import "AppDelegate.h"

#import "ESCssParser.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    NSString *cssText = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"test" ofType:@"css"]
                                                  encoding:NSUTF8StringEncoding
                                                     error:nil];
    ESCssParser *parser = [[ESCssParser alloc] init];
    NSDictionary *styleSheet = [parser parseText:cssText];
    NSLog(@"styleSheet: %@", styleSheet);

}

@end

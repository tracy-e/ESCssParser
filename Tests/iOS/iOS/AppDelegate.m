//
//  AppDelegate.m
//  iOS
//
//  Created by TracyYih on 13-8-24.
//  Copyright (c) 2013年 TracyYih. All rights reserved.
//

#import "AppDelegate.h"

#import "ESCssParser.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    NSString *cssText = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"test" ofType:@"css"]
                                                  encoding:NSUTF8StringEncoding
                                                     error:nil];
    ESCssParser *parser = [[ESCssParser alloc] init];
    NSDictionary *styleSheet = [parser parseText:cssText];
    NSLog(@"styleSheet: %@", styleSheet);

    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

@end

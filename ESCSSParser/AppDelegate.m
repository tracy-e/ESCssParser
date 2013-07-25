//
//  ESAppDelegate.m
//  ESCSSParser
//
//  Created by TracyYih(tracy.cpp@gmail.com) on 12-11-12.
//  Copyright (c) 2012 EsoftMobile.com. All rights reserved.
//

#import "AppDelegate.h"
#import "ESCSSParser.h"

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"css"];
    NSString *cssText = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    
    ESCSSParser *parser = [[ESCSSParser alloc] init];
    NSDictionary *styleSheet = [parser parse:cssText];
    NSLog(@"styleSheet:%@",styleSheet);
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

@end

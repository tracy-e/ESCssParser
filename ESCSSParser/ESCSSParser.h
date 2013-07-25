//
//  ESCSSParser.h
//  ESCSSParser
//
//  Created by TracyYih(tracy.cpp@gmail.com) on 12-11-12.
//  Copyright (c) 2012 EsoftMobile.com. All rights reserved.
//

#if !__has_feature(objc_arc)
#error ESCSSParser must be built with ARC.
// You can turn on ARC for only ESCSSParser files by adding -fobjc-arc to the build phase for each of its files.
#endif

@interface ESCSSParser : NSObject{}

- (NSDictionary *)parse:(NSString *)cssText;

@end

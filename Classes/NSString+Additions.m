//
//  NSString+Additions.m
//  ShareBox
//
//  Created by Ryan Wang on 11-4-18.
//  Copyright 2011年 DDMap. All rights reserved.
//

#import "NSString+Additions.h"


@implementation NSString (Additions)

+ (NSString *)timestamp {
    return [NSString stringWithFormat:@"%d", time(NULL)];
}

+ (NSString *)qq_nonce {
	CFUUIDRef theUUID = CFUUIDCreate(NULL);
	CFStringRef string = CFUUIDCreateString(NULL, theUUID);
	CFRelease(theUUID);
	//	return [(NSString *)string autorelease];
	NSString *subString = [(NSString *)string substringToIndex:20];
	//	RLog(@"nonce :%d",[(NSString *)subString length]);
	[(NSString *)string autorelease];
	return subString;
	
}


+ (NSString *)nonce  {
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    NSMakeCollectable(theUUID);
    NSString *nonce = (NSString *)string;
    return [nonce autorelease];
}

@end

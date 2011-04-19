//
//  NSString+Additions.h
//  ShareBox
//
//  Created by Ryan Wang on 11-4-18.
//  Copyright 2011年 DDMap. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (Additions)

+ (NSString *)timestamp;
+ (NSString *)nonce;
+ (NSString *)qq_nonce;

@end

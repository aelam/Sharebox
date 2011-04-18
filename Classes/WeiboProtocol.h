//
//  WeiboProtocol.h
//  ShareBox
//
//  Created by Ryan Wang on 11-4-18.
//  Copyright 2011 DDMap. All rights reserved.
//


@protocol WeiboProtocol

//- (void)controller:(id)controller serviceProvider:(NSInteger)provider verifySuccess:(NSString *)tip;
//- (void)controller:(id)controller serviceProvider:(NSInteger)provider verifyFailed:(NSError *)error;

- (void)controller:(id)controller serviceProvider:(NSInteger)provider requestSuccess:(NSString *)tip;
- (void)controller:(id)controller serviceProvider:(NSInteger)provider requestFailed:(NSError *)error;


@end

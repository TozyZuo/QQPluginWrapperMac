//
//  QQPlugin.m
//  QQPlugin
//
//  Created by TozyZuo on 2018/3/20.
//  Copyright © 2018年 TozyZuo. All rights reserved.
//

#import <Foundation/Foundation.h>

void QQRedPackHelperInitialize(void) ;
static void __attribute__((constructor)) initialize(void) {
    QQRedPackHelperInitialize();
}


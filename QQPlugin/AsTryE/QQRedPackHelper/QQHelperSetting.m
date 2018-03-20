//
//  QQHelperSetting.m
//  QQRedPackHelper
//
//  Created by tangxianhai on 2018/3/2.
//  Copyright © 2018年 tangxianhai. All rights reserved.
//

#import "QQHelperSetting.h"

@implementation QQHelperSetting {
    
}

static NSString *hideRedDetailWindowKey = @"txh_hideRedDetailWindowKey";
static NSString *redPacketKey = @"txh_redPacketKeyy";
static NSString *messageRevokeKey = @"txh_messageRevokeKey";

static NSString *startTimeKey = @"txh_startTimeKey";
static NSString *endTimeKey = @"txh_endTimeKey";

static NSString *msgRandomKey = @"txh_msgRandomKey";
static NSString *filterKeywordKey = @"txh_filterKeywordKey";

static NSString *groupSessionIdsKey = @"txh_groupSessionIdsKey";
static NSString *personRedPacKey = @"txh_personRedPacKey";

static QQHelperSetting *instance = nil;

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] init];
    });
    return instance;
}

- (BOOL)isPersonRedPackage {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:personRedPacKey] != nil) {
        BOOL enable = [[[NSUserDefaults standardUserDefaults] objectForKey:personRedPacKey]boolValue];
        return enable;
    }
    return true;
}

- (void)setIsPersonRedPackage:(BOOL)isPersonRedPac {
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:isPersonRedPac] forKey:personRedPacKey];
}

- (NSNumber *)msgRandom {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:msgRandomKey] != nil) {
        NSNumber * randomValue = [[NSUserDefaults standardUserDefaults] objectForKey:msgRandomKey];
        return randomValue;
    }
    return nil;
}

- (void)setMsgRandom:(NSNumber *)msgRandom {
    [[NSUserDefaults standardUserDefaults] setObject:msgRandom forKey:msgRandomKey];
}

- (NSInteger)startTime {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:startTimeKey] != nil) {
        NSInteger time = [[[NSUserDefaults standardUserDefaults] objectForKey:startTimeKey]integerValue];
        return time;
    }
    return 0;
}

- (void)setStartTime:(NSInteger)startTime {
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:startTime] forKey:startTimeKey];
}

- (NSInteger)endTime {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:endTimeKey] != nil) {
        NSInteger time = [[[NSUserDefaults standardUserDefaults] objectForKey:endTimeKey]integerValue];
        return time;
    }
    return 0;
}

- (void)setEndTime:(NSInteger)endTime {
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:endTime] forKey:endTimeKey];
}

- (void)setIsEnableRedPacket:(BOOL)isEnableRedPacket {
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:isEnableRedPacket] forKey:redPacketKey];
}

- (BOOL)isEnableRedPacket {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:redPacketKey] != nil) {
        BOOL enable = [[[NSUserDefaults standardUserDefaults] objectForKey:redPacketKey]boolValue];
        return enable;
    }
    return true;
}

- (void)setIsHideRedDetailWindow:(BOOL)isHideRedDetailWindow {
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:isHideRedDetailWindow] forKey:hideRedDetailWindowKey];
}

- (BOOL)isHideRedDetailWindow {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:hideRedDetailWindowKey] != nil) {
        BOOL autoLogin = [[[NSUserDefaults standardUserDefaults] objectForKey:hideRedDetailWindowKey]boolValue];
        return autoLogin;
    }
    return false;
}

- (void)setIsMessageRevoke:(BOOL)isMessageRevoke {
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:isMessageRevoke] forKey:messageRevokeKey];
}

- (BOOL)isMessageRevoke {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:messageRevokeKey] != nil) {
        BOOL autoLogin = [[[NSUserDefaults standardUserDefaults] objectForKey:messageRevokeKey]boolValue];
        return autoLogin;
    }
    return false;
}

- (void)saveOneRedPacController:(NSViewController *)redPacVc {
    if (self.redPacControllers == nil) {
        self.redPacControllers = [NSMutableArray new];
    }
    [self.redPacControllers addObject:redPacVc];
}

- (void)closeRedPacWindowns {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.redPacControllers == nil || [self.redPacControllers count] == 0) {
            return;
        }
        NSArray *controllers = [self.redPacControllers copy];
        for (NSViewController *vc in controllers) {
            [vc performSelector:@selector(onClose:) withObject:nil];
            [self.redPacControllers removeObject:vc];
        }
    });
}

- (NSString *)filterKeyword {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:filterKeywordKey] != nil) {
        NSString * keyword = [[NSUserDefaults standardUserDefaults] objectForKey:filterKeywordKey];
        return keyword;
    }
    return nil;
}

- (void)setFilterKeyword:(NSString *)filterKeyword {
    [[NSUserDefaults standardUserDefaults] setObject:filterKeyword forKey:filterKeywordKey];
}

- (NSArray *)sessionIds {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:groupSessionIdsKey] != nil) {
        NSArray * tempSessionIds = [[NSUserDefaults standardUserDefaults] objectForKey:groupSessionIdsKey];
        return tempSessionIds;
    }
    return nil;
}

- (void)setSessionIds:(NSArray *)sessionIds {
    // groupSessionIdsKey
    [[NSUserDefaults standardUserDefaults] setObject:sessionIds forKey:groupSessionIdsKey];
}

#pragma mark - tools

- (NSInteger)getRandomNumber:(int)from to:(int)to
{
    int time = (int)(from + (arc4random() % (to - from + 1)));
    return [[NSNumber numberWithInt:time] integerValue];
}


- (void)showWarnMessage:(NSString *)msg {
    NSAlert *alert = [[NSAlert alloc]init];
    [alert addButtonWithTitle:@"确定"];
    alert.messageText = @"提示";
    alert.informativeText = msg;
    [alert setAlertStyle:NSAlertStyleWarning];
    //回调Block
    NSWindow *mainWindow = [NSApp mainWindow];
    [alert beginSheetModalForWindow:mainWindow completionHandler:^(NSModalResponse returnCode) {
        if (returnCode == NSAlertFirstButtonReturn ) {
            // 处理点击事件
        }
    }];
}

- (void)showMessage:(NSString *)msg {
    NSAlert *alert = [[NSAlert alloc]init];
    [alert addButtonWithTitle:@"确定"];
    alert.messageText = @"提示";
    alert.informativeText = msg;
    [alert setAlertStyle:NSAlertStyleInformational];
    //回调Block
    NSWindow *mainWindow = [NSApp mainWindow];
    [alert beginSheetModalForWindow:mainWindow completionHandler:^(NSModalResponse returnCode) {
        if (returnCode == NSAlertFirstButtonReturn ) {
            // 处理点击事件
        }
    }];
}

- (BOOL)keywordContainer:(NSString *)redPackKeyword {
    if ([redPackKeyword isEqualToString:@""]) {
        return NO;
    }
    NSString *localKeyword = [self filterKeyword];
    if (localKeyword == nil) {
        return NO;
    }
    if (![localKeyword containsString:@","] && ![localKeyword containsString:@"，"]) {
        // 单个字符
        return [redPackKeyword containsString:localKeyword];
    }
    
    // 多个字符判断，可以处理中英文状态下的逗号
    NSString *temp = @",";
    if ([localKeyword containsString:@"，"]) {
        temp = @"，";
    }
    NSArray *keywords = [localKeyword componentsSeparatedByString:temp];
    __block BOOL result = NO;
    if ([keywords count] >= 1) {
        [keywords enumerateObjectsUsingBlock:^(NSString * obj, NSUInteger idx, BOOL * stop) {
            NSString *keyword = [obj stringByReplacingOccurrencesOfString:@" " withString:@""];
            if ([redPackKeyword containsString:keyword]) {
                result = YES;
                *stop = YES;
            }
        }];
    }
    return result;
}

- (BOOL)groupSessionIdContainer:(NSInteger)sessionId {
    __block BOOL result = NO;
    NSArray *localSessionIds = [self sessionIds];
    if ([localSessionIds count] != 0)  {
        [localSessionIds enumerateObjectsUsingBlock:^(NSNumber * obj, NSUInteger idx, BOOL * stop) {
            NSInteger tempSessionId = [obj integerValue];
            if (tempSessionId == sessionId) {
                result = YES;
                *stop = YES;
            }
        }];
    }
    return result;
}

//- (BOOL)removeGroupById:(NSInteger)sessionId {
//    __block BOOL result = NO;
//    NSArray *localSessionIds = [self sessionIds];
//    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:localSessionIds];
//    if ([localSessionIds count] != 0)  {
//        [localSessionIds enumerateObjectsUsingBlock:^(NSNumber * obj, NSUInteger idx, BOOL * stop) {
//            NSInteger tempSessionId = [obj integerValue];
//            if (tempSessionId == sessionId) {
//                [tempArray removeObject:obj];
//            }
//        }];
//        [self setSessionIds:tempArray];
//    }
//    return result;
//}

@end

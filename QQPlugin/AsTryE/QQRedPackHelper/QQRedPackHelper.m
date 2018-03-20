//  weibo: http://weibo.com/xiaoqing28
//  blog:  http://www.alonemonkey.com
//
//
//  QQRedPackHelper.m
//  QQRedPackHelper
//
//  Created by tangxianhai on 2018/2/4.
//  Copyright © 2018年 tangxianhai. All rights reserved.
//

#import "QQRedPackHelper.h"
#import "substrate.h"
#import "QQHelperSetting.h"

@class MQAIOChatViewController;
@class MQAIORecentSessionViewController;

@class BHMsgListManager;
@class AppController;
@class MQAIOChatViewController;
@class TChatWalletTransferViewController;
@class RedPackWindowController;
@class RedPackViewController;

//static void (*origin_TChatWalletTransferViewController_updateUI)(TChatWalletTransferViewController *,SEL);
//static void new_TChatWalletTransferViewController_updateUI(TChatWalletTransferViewController* self,SEL _cmd) {
//    origin_TChatWalletTransferViewController_updateUI(self,_cmd);
//
//    if ([[QQHelperSetting sharedInstance] isEnableRedPacket]) {
//        id chatWalletVc = self;
//        id chatWalletTransferViewModel = [chatWalletVc valueForKey:@"_viewModel"];
//        if (chatWalletTransferViewModel) {
//            id helperRedPackViewMode = [chatWalletTransferViewModel valueForKey:@"_redPackViewModel"];
//            // 判读显示的单条消息是否红包
//            if (helperRedPackViewMode) {
//                NSDictionary *helperRedPackDic = [helperRedPackViewMode valueForKey:@"_redPackDic"];
//                id chatWalletContentView = [chatWalletVc valueForKey:@"_walletContentView"];
//                if (chatWalletContentView) {
//                    // 判断红包本机是否抢过
//                    id helperRedPackOpenStateText = [chatWalletVc valueForKey:@"_redPackOpenStateLabel"];
//                    if (helperRedPackOpenStateText) {
//                        NSString *redPackOpenState = [helperRedPackOpenStateText performSelector:@selector(stringValue)];
//                        if (![redPackOpenState isEqualToString:@"已拆开"]) {
//                            NSLog(@"QQRedPackHelper：抢到红包 - 红包信息: %@",helperRedPackDic);
//                            [chatWalletContentView performSelector:@selector(performClick)];
//                            [QQHelperNotification showNotificationWithTitle:@"红包助手提示" content:@"抢到红包😝😝😝"];
//                        } else {
//                            NSLog(@"QQRedPackHelper：检测到历史红包 - 红包信息: %@",helperRedPackDic);
//                        }
//                    }
//                }
//            }
//        }
//    }
//}

static void (*origin_MQAIORecentSessionViewController_setupMenuForSessionId)(MQAIORecentSessionViewController *,SEL,id,id);
static void new_MQAIORecentSessionViewController_setupMenuForSessionId(MQAIORecentSessionViewController* self,SEL _cmd,id a3,id a4) {
    origin_MQAIORecentSessionViewController_setupMenuForSessionId(self,_cmd,a3,a4);
    {
        NSInteger uin = [[a4 valueForKey:@"_uin"] integerValue];
        NSInteger sessionChatType = [[a4 valueForKey:@"_sessionChatType"] integerValue];
        if (sessionChatType == 2 && uin != 0) {
            {
                NSMenuItem *separatorItem1 = [NSMenuItem separatorItem];
                [a3 addItem:separatorItem1];
            }
            {
                RedPackSettingMenuItem *item = [RedPackSettingMenuItem sharedInstance];
                item.groupSessionId = uin;
                NSMenuItem *settingWindowItem = [item redPacSettingItem];
                BOOL ok = [[QQHelperSetting sharedInstance] groupSessionIdContainer:uin];
                if (ok) {
                    [settingWindowItem setState:NSControlStateValueOn];
                } else {
                    [settingWindowItem setState:NSControlStateValueOff];
                }
                [a3 addItem:settingWindowItem];
            }
        }
    }
}

static id (*origin_BHMsgListManager_getMessageKey)(BHMsgListManager *,SEL,id);
static id new_BHMsgListManager_getMessageKey(BHMsgListManager* self,SEL _cmd, id msgKey) {
    id key = origin_BHMsgListManager_getMessageKey(self,_cmd,msgKey);
    if ([[QQHelperSetting sharedInstance] isEnableRedPacket]) {
        id redPackHelper = NSClassFromString(@"RedPackHelper");
        if ([msgKey isKindOfClass:NSClassFromString(@"BHMessageModel")]) {
            int mType = [[msgKey valueForKey:@"_msgType"] intValue];
            int read = [[msgKey valueForKey:@"_read"] intValue];
            NSInteger groupCode = [[msgKey valueForKey:@"_groupCode"] integerValue];
            if (mType == 311 && read == 0) {
                if (groupCode == 0) {
                    // 个人红包处理逻辑
                    BOOL personOk = [[QQHelperSetting sharedInstance] isPersonRedPackage];
                    if (!personOk) {
                        return key;
                    }
                    NSString * content = [msgKey performSelector:@selector(content)];
                    NSDictionary * contentDic = [NSJSONSerialization JSONObjectWithData:[content dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
                    NSString *title = [contentDic objectForKey:@"title"];
                    // 1. 关键字过滤
                    BOOL ok = [[QQHelperSetting sharedInstance] keywordContainer:title];
                    if (ok) {
                        return key;
                    }
                    // 2. 红包延迟
                    QQHelperSetting *helper = [QQHelperSetting sharedInstance];
                    NSInteger delayInSeconds = [helper getRandomNumber:[helper startTime] to:[helper endTime]];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [redPackHelper performSelector:@selector(openRedPackWithMsgModel:operation:) withObject:msgKey withObject:@(0)];
                        if ([msgKey isKindOfClass:NSClassFromString(@"QQRecentMessageModel")]) {
                            [QQHelperNotification showNotificationWithTitle:@"红包助手提示" content:@"抢到红包😝😝😝"];
                            NSLog(@"QQRedPackHelper：抢到红包 %@ ---- 详细信息: %@",msgKey,content);
                        }
                    });
                }
                else {
                    // 群红包处理逻辑
                    NSString * content = [msgKey performSelector:@selector(content)];
                    NSDictionary * contentDic = [NSJSONSerialization JSONObjectWithData:[content dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
                    NSString *title = [contentDic objectForKey:@"title"];
                    // 1. 关键字过滤
                    BOOL ok = [[QQHelperSetting sharedInstance] keywordContainer:title];
                    if (ok) {
                        return key;
                    }
                    // 2. 指定群过滤
                    BOOL groupOk = [[QQHelperSetting sharedInstance] groupSessionIdContainer:groupCode];
                    if (groupOk) {
                        return key;
                    }
                    // 3. 红包延迟
                    QQHelperSetting *helper = [QQHelperSetting sharedInstance];
                    NSInteger delayInSeconds = [helper getRandomNumber:[helper startTime] to:[helper endTime]];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [redPackHelper performSelector:@selector(openRedPackWithMsgModel:operation:) withObject:msgKey withObject:@(0)];
                        if ([msgKey isKindOfClass:NSClassFromString(@"QQRecentMessageModel")]) {
                            [QQHelperNotification showNotificationWithTitle:@"红包助手提示" content:@"抢到红包😝😝😝"];
                            NSLog(@"QQRedPackHelper：抢到红包 %@ ---- 详细信息: %@",msgKey,content);
                        }
                    });
                }
            }
        }
    }
    return key;
}

static void (*origin_AppController_applicationDidFinishLaunching)(AppController *,SEL,NSNotification *);
static void new_AppController_applicationDidFinishLaunching(AppController* self,SEL _cmd,NSNotification * aNotification) {
    origin_AppController_applicationDidFinishLaunching(self,_cmd,aNotification);
    [[QQHelperMenu sharedInstance] addMenu];
}

static void (*origin_MQAIOChatViewController_revokeMessages)(MQAIOChatViewController*,SEL,id);
static void new_MQAIOChatViewController_revokeMessages(MQAIOChatViewController* self,SEL _cmd,id arrays){
    if (![[QQHelperSetting sharedInstance] isMessageRevoke]) {
        origin_MQAIOChatViewController_revokeMessages(self,_cmd,arrays);
    }
}

static void (*origin_QQMessageRevokeEngine_handleRecallNotify_isOnline)(QQMessageRevokeEngine*,SEL,void * ,BOOL);
static void new_QQMessageRevokeEngine_handleRecallNotify_isOnline(QQMessageRevokeEngine* self,SEL _cmd,void * notify,BOOL isOnline){
    if (![[QQHelperSetting sharedInstance] isMessageRevoke]) {
        origin_QQMessageRevokeEngine_handleRecallNotify_isOnline(self,_cmd,notify,isOnline);
    }
}

static void (*origin_RedPackViewController_viewDidLoad)(RedPackViewController*,SEL);
static void new_RedPackViewController_viewDidLoad(RedPackViewController* self,SEL _cmd) {
    origin_RedPackViewController_viewDidLoad(self,_cmd);
    NSViewController *redPackVc = (NSViewController *)self;
    [[QQHelperSetting sharedInstance] saveOneRedPacController:redPackVc];
    if ([[QQHelperSetting sharedInstance] isHideRedDetailWindow]) {
        [[QQHelperSetting sharedInstance] closeRedPacWindowns];
    }
}

NSArray *(*oldNSSearchPathForDirectoriesInDomains)(NSSearchPathDirectory directory, NSSearchPathDomainMask domainMask, BOOL expandTilde);
NSArray *newNSSearchPathForDirectoriesInDomains(NSSearchPathDirectory directory,
                                             NSSearchPathDomainMask domainMask,
                                             BOOL expandTilde)
{
    static NSDictionary *directoryMap;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *prefix = [[@"~" stringByExpandingTildeInPath] stringByAppendingString:@"/"];
        directoryMap = @{@(NSApplicationDirectory) : @[[prefix stringByAppendingString:@"Library/Containers/com.tencent.qq/Data/Applications"]],
                         @(NSDemoApplicationDirectory) : @[[prefix stringByAppendingString:@"Library/Containers/com.tencent.qq/Data/Applications/Demos"]],
                         @(NSDeveloperApplicationDirectory) : @[[prefix stringByAppendingString:@"Library/Containers/com.tencent.qq/Data/Developer/Applications"]],
                         @(NSAdminApplicationDirectory) : @[[prefix stringByAppendingString:@"Library/Containers/com.tencent.qq/Data/Applications/Utilities"]],
                         @(NSLibraryDirectory) : @[[prefix stringByAppendingString:@"Library/Containers/com.tencent.qq/Data/Library"]],
                         @(NSDeveloperDirectory) : @[[prefix stringByAppendingString:@"Library/Containers/com.tencent.qq/Data/Developer"]],
                         @(NSDocumentationDirectory) : @[[prefix stringByAppendingString:@"Library/Containers/com.tencent.qq/Data/Library/Documentation"]],
                         @(NSDocumentDirectory) : @[[prefix stringByAppendingString:@"Library/Containers/com.tencent.qq/Data/Documents"]],
                         @(NSAutosavedInformationDirectory) : @[[prefix stringByAppendingString:@"Library/Containers/com.tencent.qq/Data/Library/Autosave Information"]],
                         @(NSDesktopDirectory) : @[[prefix stringByAppendingString:@"Library/Containers/com.tencent.qq/Data/Desktop"]],
                         @(NSCachesDirectory) : @[[prefix stringByAppendingString:@"Library/Containers/com.tencent.qq/Data/Library/Caches"]],
                         @(NSApplicationSupportDirectory) : @[[prefix stringByAppendingString:@"Library/Containers/com.tencent.qq/Data/Library/Application Support"]],
                         @(NSDownloadsDirectory) : @[[prefix stringByAppendingString:@"Library/Containers/com.tencent.qq/Data/Downloads"]],
                         @(NSInputMethodsDirectory) : @[[prefix stringByAppendingString:@"Library/Containers/com.tencent.qq/Data/Library/Input Methods"]],
                         @(NSMoviesDirectory) : @[[prefix stringByAppendingString:@"Library/Containers/com.tencent.qq/Data/Movies"]],
                         @(NSMusicDirectory) : @[[prefix stringByAppendingString:@"Library/Containers/com.tencent.qq/Data/Music"]],
                         @(NSPicturesDirectory) : @[[prefix stringByAppendingString:@"Library/Containers/com.tencent.qq/Data/Pictures"]],
                         @(NSSharedPublicDirectory) : @[[prefix stringByAppendingString:@"Library/Containers/com.tencent.qq/Data/Public"]],
                         @(NSPreferencePanesDirectory) : @[[prefix stringByAppendingString:@"Library/Containers/com.tencent.qq/Data/Library/PreferencePanes"]],
                         @(NSAllApplicationsDirectory) :
                             @[[prefix stringByAppendingString:@"Library/Containers/com.tencent.qq/Data/Applications"],
                               [prefix stringByAppendingString:@"Library/Containers/com.tencent.qq/Data/Applications/Utilities"],
                               [prefix stringByAppendingString:@"Library/Containers/com.tencent.qq/Data/Developer/Applications"],
                               [prefix stringByAppendingString:@"Library/Containers/com.tencent.qq/Data/Applications/Demos"],],
                         @(NSAllLibrariesDirectory) :
                             @[[prefix stringByAppendingString:@"Library/Containers/com.tencent.qq/Data/Library"],
                               [prefix stringByAppendingString:@"Library/Containers/com.tencent.qq/Data/Developer"],],
                         };
    });

    NSArray *result = oldNSSearchPathForDirectoriesInDomains(directory, domainMask, expandTilde);
    if (domainMask & NSUserDomainMask) {
        NSArray *correctDirs = directoryMap[@(directory)];
        if (correctDirs) {
            NSArray *wrongDirs = oldNSSearchPathForDirectoriesInDomains(directory, NSUserDomainMask, expandTilde);
            NSMutableArray *mResult = result.mutableCopy;
            [mResult removeObjectsInArray:wrongDirs];
            [mResult addObjectsFromArray:correctDirs];
            result = mResult.copy;
        }
    }

    return result;
}

static NSString *(*origin_DirHelper_QQ_AcountDir)(id,SEL);
static NSString *new_DirHelper_QQ_AcountDir(id self,SEL _cmd)
{
    NSString *path = origin_DirHelper_QQ_AcountDir(self, _cmd);
    static NSString *wrongPrefix;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        wrongPrefix = [@"~/Library/Application Support/QQ" stringByExpandingTildeInPath];
    });
    if ([path hasPrefix:wrongPrefix]) {
        path = [path stringByReplacingOccurrencesOfString:wrongPrefix withString:[@"~/Library/Containers/com.tencent.qq/Data/Library/Application Support/QQ" stringByExpandingTildeInPath]];
    }

    return path;
}

void QQRedPackHelperInitialize(void) {
//static void __attribute__((constructor)) initialize(void) {

    NSLog(@"QQRedPackHelper111：抢红包插件2.0 开启 ----------------------------------");
    
    // 初始化红包关键字配置
    if ([[QQHelperSetting sharedInstance] filterKeyword] == nil) {
        [[QQHelperSetting sharedInstance] setFilterKeyword:@"外挂,测试"];
    }
    
    // 消息防撤回 1
    MSHookMessageEx(objc_getClass("MQAIOChatViewController"),  @selector(revokeMessages:), (IMP)&new_MQAIOChatViewController_revokeMessages, (IMP*)&origin_MQAIOChatViewController_revokeMessages);
    
    // 消息防撤回 2
    MSHookMessageEx(objc_getClass("QQMessageRevokeEngine"),  @selector(handleRecallNotify:isOnline:), (IMP)&new_QQMessageRevokeEngine_handleRecallNotify_isOnline, (IMP*)&origin_QQMessageRevokeEngine_handleRecallNotify_isOnline);
    
    // 助手设置菜单项
    MSHookMessageEx(objc_getClass("AppController"), @selector(applicationDidFinishLaunching:), (IMP)&new_AppController_applicationDidFinishLaunching, (IMP *)&origin_AppController_applicationDidFinishLaunching);
    
    // 群右键设置选项
    MSHookMessageEx(objc_getClass("MQAIORecentSessionViewController"), @selector(setupMenu:forSessionId:), (IMP)&new_MQAIORecentSessionViewController_setupMenuForSessionId, (IMP *)&origin_MQAIORecentSessionViewController_setupMenuForSessionId);
    
    // 自动关闭红包弹框
     MSHookMessageEx(objc_getClass("RedPackViewController"), @selector(viewDidLoad), (IMP)&new_RedPackViewController_viewDidLoad, (IMP *)&origin_RedPackViewController_viewDidLoad);
    
    // 模拟抢红包，底层调用
    MSHookMessageEx(objc_getClass("BHMsgListManager"), @selector(getMessageKey:), (IMP)&new_BHMsgListManager_getMessageKey, (IMP *)&origin_BHMsgListManager_getMessageKey);
    
    // 解决历史记录
    MSHookFunction(&NSSearchPathForDirectoriesInDomains, &newNSSearchPathForDirectoriesInDomains, &oldNSSearchPathForDirectoriesInDomains);
    MSHookMessageEx(objc_getMetaClass("DirHelper"), @selector(QQ_AcountDir), (IMP)&new_DirHelper_QQ_AcountDir, (IMP *)&origin_DirHelper_QQ_AcountDir);
}

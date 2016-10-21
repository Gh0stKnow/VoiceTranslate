//
//  ZZiflyTool.h
//  语音识别
//
//  Created by ghostknow on 16/5/20.
//  Copyright © 2016年 ZZBelieve. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iflyMSC/iflyMSC.h"

/**
 *  回调
 */
typedef void (^RecognizerBlock)(IFlySpeechError *error,NSString *result);



@interface ZZiflyTool : NSObject

+ (instancetype)shareTool;


- (void)startRecognizer:(RecognizerBlock)block;

@end

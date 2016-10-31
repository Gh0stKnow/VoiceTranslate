//
//  ZZiflyTool.m
//  语音识别
//
//  Created by ghostknow on 16/5/20.
//  Copyright © 2016年 xiaodong. All rights reserved.
//

#import "ZZiflyTool.h"
#import "IATConfig.h"
#import "ISRDataHelper.h"
@interface ZZiflyTool()<IFlyRecognizerViewDelegate>

/**带界面的识别对象**/
@property (nonatomic, strong) IFlyRecognizerView *iflyRecognizerView;

@property(nonatomic,copy)RecognizerBlock block;

@end


@implementation ZZiflyTool


// iflyRV的get方法 在里面做设置
- (IFlyRecognizerView *)iflyRecognizerView{
    
    if (!_iflyRecognizerView) {
        
        UIWindow *keyWindow =  [UIApplication sharedApplication].keyWindow;
        
        IFlyRecognizerView *iflyRecognizerView = [[IFlyRecognizerView alloc] initWithCenter:keyWindow.center];
        iflyRecognizerView.delegate = self;
        [iflyRecognizerView setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
        
        //设置听写模式
        [iflyRecognizerView setParameter:@"iat" forKey:[IFlySpeechConstant IFLY_DOMAIN]];
        
        
        IATConfig *instance = [IATConfig sharedInstance];
        //设置最长录音时间
        [iflyRecognizerView setParameter:instance.speechTimeout forKey:[IFlySpeechConstant SPEECH_TIMEOUT]];
        //设置后端点
        [iflyRecognizerView setParameter:instance.vadEos forKey:[IFlySpeechConstant VAD_EOS]];
        //设置前端点
        [iflyRecognizerView setParameter:instance.vadBos forKey:[IFlySpeechConstant VAD_BOS]];
        //网络等待时间
        [iflyRecognizerView setParameter:@"20000" forKey:[IFlySpeechConstant NET_TIMEOUT]];
        
        //设置采样率，推荐使用16K
        [iflyRecognizerView setParameter:instance.sampleRate forKey:[IFlySpeechConstant SAMPLE_RATE]];
        if ([instance.language isEqualToString:[IATConfig chinese]]) {
            //设置语言
            [iflyRecognizerView setParameter:instance.language forKey:[IFlySpeechConstant LANGUAGE]];
            //设置方言
            [iflyRecognizerView setParameter:instance.accent forKey:[IFlySpeechConstant ACCENT]];
            
        }else if ([instance.language isEqualToString:[IATConfig english]]) {
            //设置语言
            [iflyRecognizerView setParameter:instance.language forKey:[IFlySpeechConstant LANGUAGE]];
        }
        //设置是否返回标点符号
        [iflyRecognizerView setParameter:instance.dot forKey:[IFlySpeechConstant ASR_PTT]];
        
        self.iflyRecognizerView = iflyRecognizerView;
        
        
    }
    
    return _iflyRecognizerView;
    
    
}

+ (instancetype)shareTool{


    static ZZiflyTool *_tool = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _tool = [[self alloc] init];
    });
    
    
    return _tool;

}


- (void)startRecognizer:(RecognizerBlock)block{

    self.block = block;
    
    
    [self.iflyRecognizerView start];


}


/**
 有界面，听写结果回调
 resultArray：听写结果
 isLast：表示最后一次
 ****/
- (void)onResult:(NSArray *)resultArray isLast:(BOOL)isLast
{
    NSMutableString *result = [[NSMutableString alloc] init];
    NSDictionary *dic = [resultArray objectAtIndex:0];
    
    for (NSString *key in dic) {
        [result appendFormat:@"%@",key];
    }
    
    NSString * resultFromJson =  [ISRDataHelper stringFromJson:result];
    NSLog(@"result---%@",resultFromJson);
    
        
    self.block(nil,resultFromJson);


}


/**
 听写结束回调（注：无论听写是否正确都会回调）
 error.errorCode =
 0     听写正确
 other 听写出错
 ****/
- (void) onError:(IFlySpeechError *) error{
    
    if (error.errorCode!=0) {
        
        
        NSLog(@"%@,error",error.errorDesc);
        self.block(error,nil);
    }
    
    
    
    
}

@end

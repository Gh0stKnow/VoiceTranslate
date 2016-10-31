//
//  ViewController.m
//  语音识别
//
//  Created by ghostknow on 16/5/17.
//  Copyright © 2016年 xiaodong. All rights reserved.
//

#import "ViewController.h"
#import "iflyMSC/iflyMSC.h"
#import "ZZiflyTool.h"
#import "NSString+MD5.h"
#import "AFNetworking.h"
#import "PcmPlayer.h"
#import "TTSConfig.h"

#define TuringAPIKey @"499e70503ca944a48a2260fc36bd6673"

// 时间宏
#define TICK   NSDate *startTime = [NSDate date]
#define TOCK   NSLog(@"Time: %f", -[startTime timeIntervalSinceNow])

typedef NS_OPTIONS(NSInteger, SynthesizeType) {
    NomalType           = 5,//普通合成
    UriType             = 6, //uri合成
};
typedef NS_OPTIONS(NSInteger, Status) {
    NotStart            = 0,
    Playing             = 2, //高异常分析需要的级别
    Paused              = 4,
};

@interface ViewController () <IFlySpeechSynthesizerDelegate>

@property (weak, nonatomic) IBOutlet UITextView *oriTextView;
@property (weak, nonatomic) IBOutlet UITextView *transTextView;

@property (nonatomic, strong) IFlySpeechSynthesizer * iFlySpeechSynthesizer;
@property (nonatomic, strong) NSString *uriPath;
@property (nonatomic, strong) PcmPlayer *audioPlayer;
@property (nonatomic, assign) SynthesizeType synType;
@property (nonatomic, assign) Status state;



@end



@implementation ViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    //pcm播放器初始化
    _audioPlayer = [[PcmPlayer alloc] init];
    
    
}

- (IBAction)isrBtnClick:(id)sender {
    
        _oriTextView.text = @"";
    
    [[ZZiflyTool shareTool] startRecognizer:^(IFlySpeechError *error, NSString *result) {
        
        NSDate *oriDate = [NSDate date];
        NSLog(@"oriDatea ===  %@", oriDate);
        // 错误回调
        if (error) {
            _oriTextView.text = error.errorDesc;
            return;
        } else {
            _oriTextView.text = [_oriTextView.text stringByAppendingString:(result ? result:@"没听到你说啥")];
    
            [self translateText];

            
        }
    }];
    
}


// 翻译按钮
- (IBAction)transBtnClick:(id)sender {
    
    [self translateText];
    
}

// 翻译方法
- (void)translateText
{
    // 初始化string
    
    NSString *oriText = _oriTextView.text;
    NSString *appid = @"20161021000030532";
    NSString *salt = @"858585858";
    NSString *sercet = @"7MV4OqhEgUC5hmqlYGj1";
    
    NSString *baseURL = @"http://api.fanyi.baidu.com/api/trans/vip/translate";
    NSString *sign = [NSString stringWithFormat:@"%@%@%@%@",appid,oriText,salt,sercet];
    NSString *singMd5= [NSString stringWithMD5:sign];
    
    // 初始化AFN
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] init];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    
    // baidu翻译sdk参数
    NSDictionary *paras = @{
                            @"q":oriText,
                            @"from":@"zh",
                            @"to":@"en",
                            @"appid":appid,
                            @"salt":salt,
                            @"sign":singMd5
                            };
    
    
    [manager GET:baseURL parameters:paras progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDate *afterDate = [NSDate date];
        NSLog(@"afterDatea ===  %@", afterDate);
        
        //成功后的回调
        NSLog(@"%@",responseObject);
        NSDictionary *dict = responseObject;
        if ([dict valueForKey:@"error_code"]) {
            _transTextView.text = [dict valueForKey:@"error_msg"];
            return;
        } else {
            
            
            
            _transTextView.text = [[dict valueForKey:@"trans_result"][0] valueForKey:@"dst"];
            
            
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        
    }];
    

}

// 清除文本按钮
- (IBAction)clearBtnClick:(id)sender {
    
    _oriTextView.text = @"";
    
}

- (IBAction)speekBtnClick:(id)sender {
    [self speakText];
}



- (void)speakText {
    
    TICK;
    
    NSString* str= _transTextView.text;
    
    [_iFlySpeechSynthesizer startSpeaking:str];
    
    
    
    _iFlySpeechSynthesizer = [IFlySpeechSynthesizer sharedInstance];
    
    _iFlySpeechSynthesizer.delegate = self;
    
    TOCK;
    
    _synType = NomalType;
    
    [_iFlySpeechSynthesizer
     setParameter:@"50"
     forKey:[IFlySpeechConstant SPEED]];
    
    //合成的音量;取值范围
    
    [_iFlySpeechSynthesizer
     setParameter:@"50"
     forKey:[IFlySpeechConstant VOLUME]];
    
    //发音人,默认为”xiaoyan”;可以设置的参数列表可参考个性化发音人列表
    
    [_iFlySpeechSynthesizer
     setParameter:@"xiaoyan"
     
     forKey:[IFlySpeechConstant VOICE_NAME]];
    
    //音频采样率,目前支持的采样率有
    
    [_iFlySpeechSynthesizer
     setParameter:@"8000"
     forKey:[IFlySpeechConstant SAMPLE_RATE]];
    
    ////asr_audio_path保存录音文件路径，如不再需要，设置value为nil表示取消，默认目录是documents
    
    [_iFlySpeechSynthesizer
     setParameter:nil
     
     forKey:[IFlySpeechConstant TTS_AUDIO_PATH]];
    



}





@end

##一.集成
- 首先到 <http://www.xfyun.cn> 注册并登陆下

    1 创建新应用(获得后续的appid以及开通服务)
    
    

![new.jpeg](http://upload-images.jianshu.io/upload_images/668391-7e2944467191376b.jpeg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

    
    
    2 得到appid,点击开通服务选择->语音听写,自动跳转下载sdk界面
    
   
![chuangjian.jpeg](http://upload-images.jianshu.io/upload_images/668391-541ecf10d8d65540.jpeg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

    
    
    
 - 新建工程开始集成 
 
    1.添加系统库<libz.tbd,AVFoundation.framework,SystemConfiguration.framework,Foundation.framework,CoreTelephoney.framework,AudioToolbox.framework,UIKit.framework,CoreLocation.framework,AddressBook.framework,AddressBook.framework,AddressBook.framework> 
    
    
    
![systemFrame.png](http://upload-images.jianshu.io/upload_images/668391-c3dfd42739b49ab5.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

    
    
    2.添加iflyMSC.framework(在下载的ZIP->lib 目录下)
    
  
![iflyframe.png](http://upload-images.jianshu.io/upload_images/668391-4324c905beb5e5e1.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

    
    
    
    
    ***

##二.初始化

1.AppDelegate添加如下代码

````objc

	//设置sdk的log等级，log保存在下面设置的工作路径中
	    [IFlySetting setLogFile:LVL_ALL];
	    
	//    打开输出在console的log开关
	    [IFlySetting showLogcat:YES];
    
    //设置sdk的工作路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [paths objectAtIndex:0];
    [IFlySetting setLogFilePath:cachePath];
    
    
    NSString *initString = [[NSString alloc] initWithFormat:@"appid=%@",@"573b1d27"];
    
    
    [IFlySpeechUtility createUtility:initString];




2.讯飞的语音识别主要有2个类 **IFlySpeechRecognizer(不带界面)** 和 **IFlyRecognizerView(界面)**,用法差不多,主要介绍带界面的用法.
````
	- (IFlyRecognizerView *)iflyRecognizerView{
	    
	    if (!_iflyRecognizerView) {
        
        IFlyRecognizerView *iflyRecognizerView = [[IFlyRecognizerView alloc] initWithCenter:self.view.center];
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
	````
	
然后启动服务 **[self.iflyRecognizerView start];**

3 然后通过代理 **IFlyRecognizerViewDelegate** 该代理就2个方法如下

	/*!
	 *  回调返回识别结果
	 *
	 *  @param resultArray 识别结果，NSArray的第一个元素为NSDictionary，NSDictionary的key为识别结果，sc为识别结果的置信度
	 *  @param isLast      -[out] 是否最后一个结果
	 */
	- (void)onResult:(NSArray *)resultArray isLast:(BOOL) isLast;
	
	/*!
	 *  识别结束回调
	 *
	 *  @param error 识别结束错误码
	 */
	- (void)onError: (IFlySpeechError *) error;



##三.代理模式到Block的转换(简单封装)

	1.抽取一个工具类,通过block传递结果
	/**
	 *  回调
	 */
	typedef void (^RecognizerBlock)(IFlySpeechError *error,NSString *result);
	
	
	
	@interface ZZiflyTool : NSObject
	
	+ (instancetype)shareTool;
	
	
	- (void)startRecognizer:(RecognizerBlock)block;
	
	@end
	
	
	
	
	外界只需要一句话就可以调用了
	
	[[ZZiflyTool shareTool] startRecognizer:^(IFlySpeechError *error, NSString *result) {
        
        
        if (error) {
            
            [self showMes:error.errorDesc];
            
            return;
        }
        
       NSString *str =  result.length ? result:@"没听到你说啥";
        
        [self showMes:str];
        
    }];




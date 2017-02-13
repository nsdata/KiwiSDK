//
//  KWMediaStreamingSDK.m
//  KWMediaStreamingSDK
//
//  Created by zhaoyichao on 2016/12/10.
//  Copyright © 2016年 KWMediaStreamingSDK. All rights reserved.
//

#import "KiwiFaceSDK.h"



#import "KWStickerDownloadManager.h"

#import "SlimFaceDistortionFilter.h"
#import "FatFaceDistortionFilter.h"
#import "ETDistortionFilter.h"
#import "KWPointsRenderer.h"
#import "PearFaceDistortionFilter.h"
#import "GPUImageBeautifyFilter.h"
#import "SquareFaceDistortionFilter.h"
#import "SmallFaceBigEyeFilter.h"

#import "KWStickerRenderer.h"



#import "Global.h"


@interface KiwiFaceSDK()

@end


@implementation KiwiFaceSDK
{
    //隐藏菜单的响应View
    UIView *tapView;
    UIButton *btnBeautify1;
    UIButton *btnBeautify2;
    UIButton *btnBeautify3;
    UIButton *btnBeautify4;
}
KiwiFaceSDK *sharedAccountManagerInstance = nil;

+ (KiwiFaceSDK *)sharedManager
{
#if TARGET_IPHONE_SIMULATOR
    NSLog(@"sdk不支持 模拟器运行！请连接真机运行！|| The SDK does not support the simulator run! Please connect the machine run!");
    NSAssert(!(TARGET_IPHONE_SIMULATOR), @"sdk不支持 模拟器运行！请连接真机运行！|| The SDK does not support the simulator run! Please connect the machine run!");
    return nil;
#endif
    
    
//    static dispatch_once_t predicate;
//    dispatch_once(&predicate, ^{
    if (sharedAccountManagerInstance == nil) {
        sharedAccountManagerInstance = [[KiwiFaceSDK alloc] init];
        sharedAccountManagerInstance.renderer = [KWRenderer new];
    }
        
//    });
    return sharedAccountManagerInstance;
}

+ (void)releaseManager
{
    [(KWStickerRenderer *)sharedAccountManagerInstance.filters[1] setSticker:nil];
    [sharedAccountManagerInstance.renderer removeAllFilters];
    
    sharedAccountManagerInstance.renderer = nil;
    
    destory();
    sharedAccountManagerInstance.filters = nil;
    sharedAccountManagerInstance.distortionFilters = nil;
    sharedAccountManagerInstance.beautifyFilters = nil;
    sharedAccountManagerInstance.currentLookupFilter.lookupImageSource = nil;
    sharedAccountManagerInstance.currentLookupFilter.currentImage = nil;
    sharedAccountManagerInstance.currentLookupFilter = nil;
    sharedAccountManagerInstance.lookupFilters = nil;
    sharedAccountManagerInstance.beautifyNewFilters = nil;
    
    sharedAccountManagerInstance.stickers = nil;
    sharedAccountManagerInstance.distortionTitleInfosArr = nil;
    sharedAccountManagerInstance.globalBeatifyFilterTitleInfosArr = nil;
    sharedAccountManagerInstance.textArr = nil;
    sharedAccountManagerInstance = nil;
    
}

+ (BOOL)isSdkDueTheTime
{
    BOOL isDue = YES;
    isDue = [KWDueTime isSdkDueTheTime];
    return isDue;
}

- (void)initSdk
{
    if (self) {
        
        [self.renderer removeAllFilters];
        
        self.currentStickerIndex = -2;
        
        //加载贴图模板并且默认选择第一张模板贴图
        [[KWStickerManager sharedManager] loadStickersWithCompletion:^(NSMutableArray<KWSticker *> *stickers) {
            self.stickers = stickers;
//            [(KWStickerRenderer *)self.filters[1] setSticker:[stickers firstObject]];
                //贴纸信息读取完成
                [[NSNotificationCenter defaultCenter] postNotificationName:@"KW_STICKERSLOADED_COMPLETE" object:nil];
        }];
        //普通滤镜或贴纸集合（需要人脸）
        self.filters = @[
                         [KWPointsRenderer new],
                         [KWStickerRenderer new]
                         ];
        
        /* 哈哈镜滤镜集合*/
        self.distortionFilters = @[
                                   [SquareFaceDistortionFilter new],
                                   [ETDistortionFilter new],
                                   [FatFaceDistortionFilter new],
                                   [SlimFaceDistortionFilter new],
                                   [PearFaceDistortionFilter new]
                                   ];
        
        
        //美颜滤镜集合
        self.beautifyFilters = @[
//                                 [GPUImageBulgeEyeFilter new],
//                                 [GPUImageThinFaceFilter new],
                                 [SmallFaceBigEyeFilter new]
//                                 [GPUImageBeautifyFilter new]
                                 ];
        
        self.beautifyNewFilters = @[
                                    [GPUImageBeautifyFilter new],
                                    [NewBeautyFilter new]
                                    ];

        //全局滤镜集合（不需要人脸）
        self.lookupFilters = @[
                               [[KWColorFilter alloc] initWithType:KWColorTypeBlueberrt],
                               [[KWColorFilter alloc] initWithType:KWColorTypeDreamy],
                               [[KWColorFilter alloc] initWithType:KWColorTypeHabana],
                               [[KWColorFilter alloc] initWithType:KWColorTypeHappy],
                               [[KWColorFilter alloc] initWithType:KWColorTypeHarvest],
                               [[KWColorFilter alloc] initWithType:KWColorTypeMisty],
                               [[KWColorFilter alloc] initWithType:KWColorTypeSpring]
                               ];
        
        self.distortionTitleInfosArr = [NSMutableArray arrayWithObjects:@"cancel",@"distortion_SquareFace.png",@"distortion_ET.png",@"distortion_FatFace",@"distortion_SmallFace",@"distortion_PearFace",nil];
        
        self.globalBeatifyFilterTitleInfosArr = [NSMutableArray arrayWithObjects:@"artwork master",@"BLUEBERRY_icon.png", @"DREAMY_icon.png",@"HABANA_icon.png",@"HAPPY_icon.png",@"HARVEST_icon.png",@"MISTY_icon.png",@"SPRING_icon.png", nil];
        
        if (IsEnglish) {
            self.textArr = [NSMutableArray arrayWithObjects:@"Origin",@"BLUE",@"DREAMY",@"HABANA",@"HAPPY",@"HARVEST",@"MISTY",@"SPRING", nil];
        }
        else
        {
            self.textArr = [NSMutableArray arrayWithObjects:@"原图",@"BLUE",@"DREAMY",@"HABANA",@"HAPPY",@"HARVEST",@"MISTY",@"SPRING", nil];
        }
        
        self.varWidth = ScreenWidth_KW;
        self.varHeight = ScreenHeight_KW;
        
        
        [self resetDistortionParams];
//        [self toggleCamera];
    }
}

- (void)resetDistortionParams
{
    if ([[Global sharedManager] isPixcelBufferRotateVertical]) {
        ((SmallFaceBigEyeFilter *)self.beautifyFilters[0]).y_scale = self.varHeight / self.varWidth  ;
        //    ((NewBeautyFilter *)self.beautifyNewFilters[1])
        ((ETDistortionFilter *) self.distortionFilters[1]).y_scale = self.varHeight / self.varWidth;
        ((FatFaceDistortionFilter *) self.distortionFilters[2]).y_scale =  self.varHeight / self.varWidth;
        ((SlimFaceDistortionFilter *) self.distortionFilters[3]).y_scale = self.varHeight / self.varWidth;
        ((PearFaceDistortionFilter *) self.distortionFilters[4]).y_scale = self.varHeight / self.varWidth;
    }
    else
    {
        ((SmallFaceBigEyeFilter *)self.beautifyFilters[0]).y_scale = self.varWidth / self.varHeight;
        //    ((NewBeautyFilter *)self.beautifyNewFilters[1])
        ((ETDistortionFilter *) self.distortionFilters[1]).y_scale = self.varWidth / self.varHeight;
        ((FatFaceDistortionFilter *) self.distortionFilters[2]).y_scale = self.varWidth / self.varHeight;
        ((SlimFaceDistortionFilter *) self.distortionFilters[3]).y_scale = self.varWidth / self.varHeight;
        ((PearFaceDistortionFilter *) self.distortionFilters[4]).y_scale = self.varWidth / self.varHeight;
    }
    
}

- (void)initDefaultParams
{
    [self onEnableBeauty:YES];
    
    [self onFilterChanged:0];
    
}

///* 点阵 按钮 */
//- (UIButton *)pointBtn
//{
//    if (!_pointBtn) {
//        _pointBtn = [[UIButton alloc]initWithFrame:CGRectMake((ScreenWidth_KW - 46 * 4) / 5 * 4 + 46 * 3, 6, 46, 46)];
//        [_pointBtn setImage:[UIImage imageNamed:@"face drk"] forState:UIControlStateNormal];
//        [_pointBtn setImage:[UIImage imageNamed:@"face"] forState:UIControlStateSelected];
//        [_pointBtn setHidden:YES];
//        [_pointBtn addTarget:self action:@selector(pointBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
//    }
//    return _pointBtn;
//}

/******
 * 清空所有特效
 */
- (void)clearAllFilter
{
    [self.renderer removeAllFilters];
}

/* 点阵切换
 * support：YES（开启点阵）NO（关闭点阵）
 */
- (void)onEnableDrawPoints:(BOOL) support
{
    if (support) {
        [self.renderer removeAllFilters];
        [self.renderer addFilter:self.filters[0]];
    }
    else
    {
        [self.renderer removeFilter:self.filters[0]];
    }
    
}

/* 哈哈镜切换
 * filterType：滤镜类型
 */
- (void)onDistortionChanged:(NSInteger)filterType
{
    if (self.currentDistortionFilter) {
        [self.renderer removeFilter:self.currentDistortionFilter];
        self.currentDistortionFilter = nil;
    }
    if (filterType >= 0) {
        self.currentDistortionFilter = (GPUImageOutput<GPUImageInput,KWRenderProtocol> *)[self.distortionFilters objectAtIndex:(filterType)];
        
        [self.renderer addFilter:self.currentDistortionFilter];
    }
    else
    {
        [self.renderer removeFilter:self.currentDistortionFilter];
        self.currentDistortionFilter = nil;
    }
}

/* 全局滤镜切换
 * filterType：滤镜类型
 */
- (void)onFilterChanged:(NSInteger) filterType
{
    if (self.currentLookupFilter) {
        [self.renderer removeFilter:self.currentLookupFilter];
        self.currentLookupFilter = nil;
    }
    if (filterType >= 0) {
        self.currentLookupFilter = (KWColorFilter *)[self.lookupFilters objectAtIndex:(filterType)];
        
        [self.renderer addFilter:self.currentLookupFilter];
    }
    else
    {
        [self.renderer removeFilter:self.currentLookupFilter];
        self.currentLookupFilter = nil;
    }
    
}



/* 是否开启美颜
 * support：YES（开启） NO(关闭)
 */
- (void)onEnableBeauty:(BOOL) support
{
    if (support) {
        [self.renderer addFilter:self.beautifyFilters[0]];
    }
    else
    {
        [self.renderer removeFilter:self.beautifyFilters[0]];
    }
}

/* 贴纸选择
 * stickerIndex: 贴纸索引
 */
- (void)onStickerChanged:(NSInteger) pos
{
    self.currentStickerIndex = pos;
    
    [self.renderer removeFilter:self.filters[1]];
    
    if (self.currentStickerIndex >= 0 && self.currentStickerIndex < self.stickers.count + 1) {
        [(KWStickerRenderer *)self.filters[1] setSticker:self.stickers[self.currentStickerIndex]];
        [self.renderer addFilter:self.filters[1]];
//        if (self.movieWriter) {
//            [self.filters[1] addTarget:self.movieWriter];
//        }
    } else {
        [(KWStickerRenderer *)self.filters[1] setSticker:nil];
//        if (self.movieWriter) {
//            [self.filters[1] removeTarget:self.movieWriter];
//        }
    }
}


/*
 * 调节美颜参数
 * type：参数类型
 * value：参数调节值
 */
- (void)onBeautyParamsChanged:(KW_BEAUTYPARAMS_TYPE)type Value:(float) value
{
    switch (type) {
            //大眼
        case KW_BEAUTYPARAMS_TYPE_BULGEEYE:
            ((SmallFaceBigEyeFilter *)self.beautifyFilters[0]).eyeparam = value;
            break;
            //瘦脸
        case KW_BEAUTYPARAMS_TYPE_THINFACE:
            ((SmallFaceBigEyeFilter *)self.beautifyFilters[0]).thinparam = value;
            break;
            //磨皮
        case KW_BEAUTYPARAMS_TYPE_BILATERAL:
            NSLog(@"磨皮hueparam:%lf",value);
            ((NewBeautyFilter *)self.beautifyNewFilters[1]).hueparam = value;
            break;
            //美白
        case KW_BEAUTYPARAMS_TYPE_BRIGHTNESS:
            NSLog(@"美白smoothparam:%lf",value);
            ((NewBeautyFilter *)self.beautifyNewFilters[1]).smoothparam = value;
            break;
            //饱和
        case KW_BEAUTYPARAMS_TYPE_ROU:
            NSLog(@"饱和rouparam:%lf",value);
            ((NewBeautyFilter *)self.beautifyNewFilters[1]).rouparam = value;
            break;
            //粉嫩
        case KW_BEAUTYPARAMS_TYPE_SAT:
            NSLog(@"粉嫩satparam:%lf",value);
            ((NewBeautyFilter *)self.beautifyNewFilters[1]).satparam = value;
            break;
            
        default:
            break;
    }
}

- (void)dealloc
{
    [sharedAccountManagerInstance.renderer removeAllFilters];
    [((KWStickerRenderer *)self.filters[1]) setSticker:nil];
    self.filters = nil;
    self.distortionFilters = nil;
    self.beautifyFilters = nil;
    self.lookupFilters = nil;
    self.beautifyNewFilters = nil;
    self.stickers = nil;
    self.distortionTitleInfosArr = nil;
    self.globalBeatifyFilterTitleInfosArr = nil;
    self.textArr = nil;
    self.renderer = nil;
    sharedAccountManagerInstance = nil;
    sharedAccountManagerInstance.renderer = nil;
}


@end

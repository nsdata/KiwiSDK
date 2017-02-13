//
//  KWMediaStreamingSDK.h
//  KWMediaStreamingSDK
//
//  Created by zhaoyichao on 2016/12/10.
//  Copyright © 2016年 KWMediaStreamingSDK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Reachability.h"
#import <asl.h>
#import "KWRenderer.h"
#import "KWStickerManager.h"
#import "KWColorFilter.h"
#import "KWConst.h"
#import "KWDueTime.h"
#import "NewBeautyFilter.h"

@interface KiwiFaceSDK : NSObject


/**
 A video rendering classes
 */
@property (nonatomic, strong) KWRenderer *renderer;

/**
 Ordinary filter collection
 */
@property (nonatomic, strong) NSArray<GPUImageOutput<GPUImageInput, KWRenderProtocol> *> *filters;

/**
   Beauty filter collection
 */
@property (nonatomic, strong) NSArray<GPUImageOutput<GPUImageInput, KWRenderProtocol> *> *beautifyFilters;

/**
New beauty filter collection Milled skin whitening powder
 */
@property (nonatomic, strong) NSArray<GPUImageOutput<GPUImageInput, KWRenderProtocol> *> *beautifyNewFilters;

/**
 stickers collection
 */
@property (nonatomic, strong) NSMutableArray<KWSticker *> *stickers;

/* distorting mirror filter collection */
@property (nonatomic, strong) NSArray<GPUImageOutput<GPUImageInput, KWRenderProtocol> *> *distortionFilters;

/**
 The global filter collection
 */
@property (nonatomic, strong) NSArray<GPUImageLookupFilter *> *lookupFilters;

/**
 The currently selected sticker item
 */
@property (nonatomic) NSInteger currentStickerIndex;

/**
 The currently selected global filter item
 */
@property (nonatomic, strong) KWColorFilter *currentLookupFilter;

/**
 Maximum number of face captures
 */
@property (nonatomic, assign) NSUInteger maxFaceNumber;

/**
 The currently selected distorting mirror filter
 */
@property (nonatomic, strong) GPUImageOutput<GPUImageInput, KWRenderProtocol> *currentDistortionFilter;

/**
 The Class of Camera for recording video
 */
@property (nonatomic, weak) GPUImageStillCamera *videoCamera;

/**
  The class for recording video
 */
@property (nonatomic, weak) GPUImageMovieWriter *movieWriter;

/**
 Compatible with the width of the screen
 */
@property (nonatomic, assign) CGFloat varWidth;

/**
 Compatible with the height of the screen
 */
@property (nonatomic, assign) CGFloat varHeight;

/**
 Distorting mirror filters array
 */
@property (nonatomic, strong) NSMutableArray *distortionTitleInfosArr;

/**
 Global beauty icons of filters array
 */
@property (nonatomic, strong) NSMutableArray *globalBeatifyFilterTitleInfosArr;

/**
  Global beauty title of filters array
 */
@property (nonatomic, strong) NSMutableArray *textArr;

@property (nonatomic, assign) BOOL cameraPositionBack;

/**
 Gets a single instance

 @return a instance class of KiwiFaceSDK
 */
+ (KiwiFaceSDK *)sharedManager;


+ (void)releaseManager;

/**
 Initialize sdk
 */
- (void)initSdk;

/**
 Initialize sdk params
 */
- (void)initDefaultParams;

/**
 If you change the mirror parameters to update the mirror
 */
- (void)resetDistortionParams;

/**
 Switch face-lift big face effect
 
 @param support The value is YES:open or NO:close
 */
- (void)onEnableBeauty:(BOOL) support;

/**
 Switch the sticker filter

 @param pos sticker index
 */
- (void)onStickerChanged:(NSInteger) pos;

/**
 Switching distorting mirror filters

 @param filterType filterType of distorting mirror
 */
- (void)onDistortionChanged:(NSInteger)filterType;

/**
 Global filter switch

 @param filterType filterType of Global
 */
- (void)onFilterChanged:(NSInteger) filterType;

/**
 Determines whether the SDK expires

 @return YES(expired)  NO(not expired）
 */
+ (BOOL)isSdkDueTheTime;

/**
 Clear all effects of filters
 */
- (void)clearAllFilter;

/**
 Adjust beauty parameters

 @param type the type of beatifully filter params
 @param value Parameter adjustment value
 */
- (void)onBeautyParamsChanged:(KW_BEAUTYPARAMS_TYPE)type Value:(float) value;

/**
 Switch the face depicting points

 @param support The value is YES:open or NO:close
 */
- (void)onEnableDrawPoints:(BOOL) support;


@end

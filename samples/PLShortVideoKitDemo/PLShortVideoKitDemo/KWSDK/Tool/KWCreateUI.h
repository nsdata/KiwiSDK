//
//  FTCreateUI.h
//  PLMediaStreamingSDK
//
//  Created by zhaoyichao on 2016/12/10.
//  Copyright © 2016年 PLMediaStreamingSDK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KWCreateUI : NSObject
/**
 Ordinary filters

 - KW_FILTER_TYPE_NONE: NO filter
 - KW_FILTER_TYPE_STICKER: sticker filter
 */
typedef NS_ENUM(NSInteger,KW_FILTER_TYPE)
{
    KW_FILTER_TYPE_NONE = -1,
    KW_FILTER_TYPE_STICKER,
};

//Beauty parameter adjustment type
typedef NS_ENUM(NSInteger,KW_BEAUTYPARAMS_TYPE)
{
    /* Big eye */
    KW_BEAUTYPARAMS_TYPE_BULGEEYE,
    /* Face-lift */
    KW_BEAUTYPARAMS_TYPE_THINFACE,
    /* Microdermabrasion */
    KW_BEAUTYPARAMS_TYPE_BILATERAL,
    /* Whitening */
    KW_BEAUTYPARAMS_TYPE_BRIGHTNESS,
    
};



/* Distorting mirror enumeration */
typedef NS_ENUM(NSInteger,KW_DISTORTION_TYPE)
{
    KW_DISTORTION_TYPE_NONE = -1,
    /* Square face */
    KW_DISTORTION_TYPE_SQUAREFACE = 0,
    /* ET */
    KW_DISTORTION_TYPE_ET,
    /* fat face */
    KW_DISTORTION_TYPE_FATFACE,
    /* small face */
    KW_DISTORTION_TYPE_SMALLFACE
};
@end

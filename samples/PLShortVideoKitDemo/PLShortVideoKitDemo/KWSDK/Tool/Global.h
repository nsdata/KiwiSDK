//
//  Global.h
//  KWKitDemo
//
//  Created by zhaoyichao on 2017/1/17.
//  Copyright © 2017年 0dayZh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Global : NSObject

typedef enum {
    KW_PIXELBUFFER_ROTATE_0 = 0,	///< The image does not need steering
    KW_PIXELBUFFER_ROTATE_90 = 1,	///< The image needs to be rotated 90 degrees clockwise
    KW_PIXELBUFFER_ROTATE_180 = 2,	///< The image needs to be rotated 180 degrees clockwise
    KW_PIXELBUFFER_ROTATE_270 = 3	///< The image needs to be rotated 270 degrees clockwise
} KW_PIXELBUFFER_ROTATE;

+ (Global *)sharedManager;

/* Whether the project is based on seven cattle (seven cattle video home page default orientation towards the default rotation 0 degrees non-seven cattle home to the right that is rotated 90 degrees) */
@property (nonatomic, assign) KW_PIXELBUFFER_ROTATE PIXCELBUFFER_ROTATE;

//Determine whether the default video frame image portrait
-(BOOL)isPixcelBufferRotateVertical;

@end

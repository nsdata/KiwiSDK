//
//  KWFacePoint.h
//  KWMediaStreamingKitDemo
//
//  Created by ChenHao on 16/7/15.
//  Copyright © 2016年 0dayZh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
typedef enum {
    KWFacePositionHair    = 1,
    KWFacePositionEye     = 2,
    KWFacePositionEar     = 3,
    KWFacePositionNose    = 4,
    KWFacePositionNostril = 5,
    KWFacePositionUperMouth   = 6,
    KWFacePositionMouth   = 7,
    KWFacePositionLip     = 8,
    KWFacePositionChin    = 9,
    KWFacePositionEyebrow,
    KWFacePositionCheek,
    KWFacePositionNeck,
    KWFacePositionFace,
} KWFacePosition;


/**
Returns the point corresponding to a position
 */
@interface KWFacePoint : NSObject

@property (nonatomic) int left;
@property (nonatomic) int center;
@property (nonatomic) int right;

+ (instancetype)facePointForPosition:(KWFacePosition)position;

@end

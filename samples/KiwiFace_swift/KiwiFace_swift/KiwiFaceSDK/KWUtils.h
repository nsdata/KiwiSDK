//
//  KWUtils.h
//  KiwiFaceKitDemo
//
//  Created by jacoy on 2017/5/31.
//  Copyright © 2017年 0dayZh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreVideo/CoreVideo.h>

@class KWSDK;

@interface KWUtils : NSObject

+ (instancetype)sharedInstance;

+ (void)processPixelBuffer:(CVPixelBufferRef)pixelBuffer andRender:(KWSDK *)kwSdk;

- (void)takePhotoWithImage:(CIImage *)outputImage width:(size_t)outputWidth height:(size_t)outputHeight isMirrored:(BOOL)mirrored completion:(void(^)(NSError *error))completion;


@end

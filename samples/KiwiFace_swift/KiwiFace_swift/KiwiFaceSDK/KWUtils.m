//
//  KWUtils.m
//  KiwiFaceKitDemo
//
//  Created by jacoy on 2017/5/31.
//  Copyright © 2017年 0dayZh. All rights reserved.
//

#import "KWUtils.h"
#import "KWSDK.h"

typedef void(^CompletionBlock)(NSError *error);

@interface KWUtils ()

@property (nonatomic, copy) CompletionBlock completion;

@end

@implementation KWUtils

+ (instancetype)sharedInstance{
    static id instance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

+ (void)processPixelBuffer:(CVPixelBufferRef)pixelBuffer andRender:(KWSDK *)kwSdk{
    
    UIDeviceOrientation iDeviceOrientation = [[UIDevice currentDevice] orientation];
    BOOL mirrored;

    mirrored = !kwSdk.cameraPositionBack;
    
    cv_rotate_type cvMobileRotate;
    
    switch (iDeviceOrientation) {
        case UIDeviceOrientationPortrait:
            cvMobileRotate = CV_CLOCKWISE_ROTATE_90;
            [Global sharedManager].PIXCELBUFFER_ROTATE = KW_PIXELBUFFER_ROTATE_0;
            break;
            
        case UIDeviceOrientationLandscapeLeft:
            cvMobileRotate = mirrored ? CV_CLOCKWISE_ROTATE_180 : CV_CLOCKWISE_ROTATE_0;
            [Global sharedManager].PIXCELBUFFER_ROTATE = KW_PIXELBUFFER_ROTATE_270;
            break;
            
        case UIDeviceOrientationLandscapeRight:
            cvMobileRotate = mirrored ? CV_CLOCKWISE_ROTATE_0 : CV_CLOCKWISE_ROTATE_180;
            [Global sharedManager].PIXCELBUFFER_ROTATE = KW_PIXELBUFFER_ROTATE_90;
            break;
            
        case UIDeviceOrientationPortraitUpsideDown:
            cvMobileRotate = CV_CLOCKWISE_ROTATE_270;
            [Global sharedManager].PIXCELBUFFER_ROTATE = KW_PIXELBUFFER_ROTATE_180;
            break;
            
        default:
            cvMobileRotate = CV_CLOCKWISE_ROTATE_0;
            break;
    }
    
    
    [kwSdk.renderer processPixelBuffer:pixelBuffer withRotation:cvMobileRotate mirrored:mirrored];
}

- (void)takePhotoWithImage:(CIImage *)outputImage width:(size_t)outputWidth height:(size_t)outputHeight isMirrored:(BOOL)mirrored completion:(void(^)(NSError *error))completion{
    
    self.completion = completion;

    /* 录制demo 前置摄像头修正图片朝向*/
    UIImage *processedImage = [self image:[self convertBufferToImage:outputImage width:outputWidth height:outputHeight] rotation:UIImageOrientationRight isMirrored:mirrored];
    UIImageWriteToSavedPhotosAlbum(processedImage, self, @selector(image:finishedSavingWithError:contextInfo:), nil);
}

- (UIImage *)convertBufferToImage:(CIImage *)outputImage width:(size_t)outputWidth height:(size_t)outputHeight
{
    CIContext *temporaryContext = [CIContext contextWithOptions:nil];
    CGImageRef videoImage = [temporaryContext
                             createCGImage:outputImage
                             fromRect:CGRectMake(0, 0,
                                                 outputWidth,
                                                 outputHeight)];
    
    UIImage *uiImage = [UIImage imageWithCGImage:videoImage];
    CGImageRelease(videoImage);
    return uiImage;
}

- (UIImage *)image:(UIImage *)image rotation:(UIImageOrientation)orientation isMirrored:(BOOL)mirrored
{
    long double rotate = 0.0;
    CGRect rect;
    float translateX = 0;
    float translateY = 0;
    float scaleX = 1.0;
    float scaleY = 1.0;
    
    switch (orientation) {
        case UIImageOrientationLeft:
            rotate = M_PI_2;
            rect = CGRectMake(0, 0, image.size.height, image.size.width);
            translateX = 0;
            translateY = -rect.size.width;
            scaleY = rect.size.width/rect.size.height;
            scaleX = rect.size.height/rect.size.width;
            break;
        case UIImageOrientationRight:
            rotate = 3 * M_PI_2;
            rect = CGRectMake(0, 0, image.size.height, image.size.width);
            translateX = -rect.size.height;
            translateY = 0;
            scaleY = rect.size.width/rect.size.height;
            scaleX = rect.size.height/rect.size.width;
            break;
        case UIImageOrientationDown:
            rotate = M_PI;
            rect = CGRectMake(0, 0, image.size.width, image.size.height);
            translateX = -rect.size.width;
            translateY = -rect.size.height;
            break;
        default:
            rotate = 0.0;
            rect = CGRectMake(0, 0, image.size.width, image.size.height);
            translateX = 0;
            translateY = 0;
            break;
    }
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    //做CTM变换
    CGContextTranslateCTM(context, 0.0, rect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextRotateCTM(context, rotate);
    CGContextTranslateCTM(context, translateX, translateY);
    
    CGContextScaleCTM(context, scaleX, scaleY);
    //绘制图片
    CGContextDrawImage(context, CGRectMake(0, 0, rect.size.width, rect.size.height), image.CGImage);
    
    UIImage *newPic = UIGraphicsGetImageFromCurrentImageContext();

    if (mirrored) {
        newPic = [self convertMirrorImage:newPic];
    }
    
    
    return newPic;
}

- (UIImage *)convertMirrorImage:(UIImage *)image
{
    
    //Quartz重绘图片
    CGRect rect =  CGRectMake(0, 0, image.size.width , image.size.height);//创建矩形框
    //根据size大小创建一个基于位图的图形上下文
    UIGraphicsBeginImageContextWithOptions(rect.size, false, 2);
    CGContextRef currentContext =  UIGraphicsGetCurrentContext();//获取当前quartz 2d绘图环境
    CGContextClipToRect(currentContext, rect);//设置当前绘图环境到矩形框
    CGContextRotateCTM(currentContext, (CGFloat)M_PI); //旋转180度
    //平移， 这里是平移坐标系，跟平移图形是一个道理
    CGContextTranslateCTM(currentContext, -rect.size.width, -rect.size.height);
    CGContextDrawImage(currentContext, rect, image.CGImage);//绘图
    
    //翻转图片
    UIImage *drawImage =  UIGraphicsGetImageFromCurrentImageContext();//获得图片
    UIImage *flipImage =  [[UIImage alloc]initWithCGImage:drawImage.CGImage];
    
    
    return flipImage;
}

- (void)image:(UIImage *)image finishedSavingWithError:(NSError *)error contextInfo: (void *) contextInfo
{    
    self.completion(error);
}

@end

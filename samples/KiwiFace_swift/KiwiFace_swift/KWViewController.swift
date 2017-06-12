//
//  KWViewController.swift
//  KiwiFace_swift
//
//  Created by 伍科 on 17/6/1.
//  Copyright © 2017年 KiwiFaceSDK. All rights reserved.
//

import UIKit
import AssetsLibrary

class KWViewController: UIViewController {

    let ScreenWidth_KW = UIScreen.main.bounds.size.width
    let ScreenHeight_KW = UIScreen.main.bounds.size.height
    
    var movieWriter : GPUImageMovieWriter?
    var movieURL :URL?
    var exportURL :URL?
    var asset: AVURLAsset?
    var emptyFilter = GPUImageFilter()
    var outputImage = CIImage()
    var outputWidth = size_t()
    var outputheight = size_t()
    var KWSDKUI: KWSDK_UI!
    
    lazy var watermarkLayer : CALayer = {
        let watermark = UIImage.init(named: "watermark")
        let watermarkLayer = CALayer.init()
        watermarkLayer.contents = watermark?.cgImage
        watermarkLayer.frame = CGRect(x: 0, y: 0, width: watermark!.size.width, height: watermark!.size.height)
        return watermarkLayer
    }()

    
    lazy var labRecordState : UILabel = {
        
        let labRecordState = UILabel(frame: CGRect(x: CGFloat(0), y: CGFloat(400), width: CGFloat(self.ScreenWidth_KW), height: CGFloat(50)))
        labRecordState.isHidden = true
        labRecordState.text = "Recording..."
        labRecordState.font = UIFont.systemFont(ofSize: CGFloat(25.0))
        labRecordState.textAlignment = .center
        labRecordState.textColor = UIColor.white
        
        return labRecordState
    }()
    
    
    lazy var previewView:GPUImageView = {
        
        let previewView = GPUImageView(frame: self.view.frame)
        previewView.fillMode = kGPUImageFillModeStretch
        previewView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill
        self.view.addSubview(previewView)
        
        return previewView
    }()

//    lazy var movieWriter:GPUImageMovieWriter = {
//        
//        let videoSettings: [AnyHashable: Any] = [AVVideoCodecKey: AVVideoCodecH264, AVVideoWidthKey: (480), AVVideoHeightKey: (640), AVVideoScalingModeKey: AVVideoScalingModeResizeAspectFill]
//        let movieWriter = GPUImageMovieWriter(movieURL: self.movieURL, size: CGSize(width: CGFloat(480.0), height: CGFloat(640.0)), fileType: AVFileTypeQuickTimeMovie, outputSettings: videoSettings)
//
//        return movieWriter!
//        
//    }()
    
    
    lazy var videoCamera:GPUImageStillCamera = {
        
        let videoCamera = GPUImageStillCamera(sessionPreset: AVCaptureSessionPreset640x480, cameraPosition: .front)
        
        videoCamera!.frameRate = 25
        videoCamera!.outputImageOrientation = .portrait
        videoCamera!.horizontallyMirrorFrontFacingCamera = true
        videoCamera!.horizontallyMirrorRearFacingCamera = false
        videoCamera!.addAudioInputsAndOutputs()
        videoCamera!.delegate = self
        
        return videoCamera!
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        navigationController?.isNavigationBarHidden = true
        
        commitInit()

        initKwSDK()
        
        /*
         you should capture camera after you initialize kwsdk
         */
        setupCamera()
  
        initKwSDKUI()
        
        view.addSubview(labRecordState)
        
    }
    
    
    /*
     set video export url
     */
    private func commitInit(){
        
        let fileName = UUID().uuidString
        let pathToMovie = NSTemporaryDirectory().appending("\(fileName).MOV")
        movieURL = URL(fileURLWithPath: pathToMovie)
        
        let pathToExport = NSTemporaryDirectory().appending("\(fileName)_export.MOV")
        exportURL = URL(fileURLWithPath: pathToExport)
    }
    

    private func setupCamera(){
        
        setupMovieWritter()
        
        videoCamera.addTarget(movieWriter)
        videoCamera.addTarget(previewView)

        videoCamera.horizontallyMirrorFrontFacingCamera = true
        videoCamera.horizontallyMirrorRearFacingCamera = false
        videoCamera.startCapture()
        
        KWSDKUI.kwSdk.videoCamera = videoCamera
        KWSDKUI.previewView = previewView
        KWSDKUI.kwSdk.movieWriter = movieWriter
    }
    
    fileprivate func setupMovieWritter(){
        
        let videoSettings: [AnyHashable: Any] = [AVVideoCodecKey: AVVideoCodecH264, AVVideoWidthKey: (480), AVVideoHeightKey: (640), AVVideoScalingModeKey: AVVideoScalingModeResizeAspectFill]
        
        movieWriter = GPUImageMovieWriter(movieURL: self.movieURL, size: CGSize(width: CGFloat(480.0), height: CGFloat(640.0)), fileType: AVFileTypeQuickTimeMovie, outputSettings: videoSettings)
    }
    
    // MARK: - 拍照开始
    
    fileprivate func takePhoto(){
        
        let mirrored = !KWSDKUI.kwSdk.cameraPositionBack
        
        KWUtils.sharedInstance().takePhoto(with: outputImage, width: outputWidth, height: outputheight, isMirrored:mirrored) { (error) in
            
            let alertView = UIAlertController()
            let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertView.addAction(cancelAction)
            alertView.title = "Message"
            if error != nil {
                alertView.message = "failed reason：\(String(describing: error))"
            }
            else {
                alertView.message = "photos saved to album success!"
            }
            
            self.present(alertView, animated: false, completion: { _ in })
  
        }
        
    }
    
    // MARK: - 拍照结束
    
    fileprivate func startRecording(){
        
        labRecordState.text = "Recording..."
        labRecordState.isHidden = false
        if KWSDKUI.kwSdk.currentStickerIndex >= 0 {
            
            KWSDKUI.kwSdk.filters.last!.addTarget(movieWriter)
        }else if KWSDKUI.kwSdk.currentDistortionFilter != nil{
            
            KWSDKUI.kwSdk.currentDistortionFilter.addTarget(movieWriter)
        }else if KWSDKUI.kwSdk.currentColorFilter != nil{
            
            (KWSDKUI.kwSdk.currentColorFilter as! GPUImageOutput).addTarget(movieWriter)
        }
        
        videoCamera.audioEncodingTarget = self.movieWriter
        
        try? FileManager.default.removeItem(at: movieURL!)
        
        videoCamera.startCapture()
        
        Global.sharedManager().pixcelbuffer_ROTATE = KW_PIXELBUFFER_ROTATE_0
        
        KWSDKUI.kwSdk.resetDistortionParams()
        
        movieWriter?.startRecording()
    }
    
    fileprivate func endRecording(){
        labRecordState.text = "Saving Video..."
        
        KWSDKUI.setCloseBtnEnable(false)
        
        if KWSDKUI.kwSdk.currentStickerIndex >= 0 {
            
            KWSDKUI.kwSdk.filters.last!.removeTarget(movieWriter)
        }else if KWSDKUI.kwSdk.currentDistortionFilter != nil{
            
            KWSDKUI.kwSdk.currentDistortionFilter.removeTarget(movieWriter)
        }else if KWSDKUI.kwSdk.currentColorFilter != nil{
            
            (KWSDKUI.kwSdk.currentColorFilter as! GPUImageOutput).removeTarget(movieWriter)
        }
        
        videoCamera.audioEncodingTarget = nil
        
        movieWriter?.finishRecording {
            
            self.addWatermarkToVideo()
        }
        
    }
    
    func addWatermarkToVideo(){
        
        asset = AVURLAsset(url: movieURL!, options: nil)
        
        let comosition = AVMutableComposition.init()
        
        let videoTrack = comosition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        let audioTrack = comosition.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: kCMPersistentTrackID_Invalid)

        let duration = asset!.duration
        
        let clipTime = CMTimeMakeWithSeconds(0.1, duration.timescale)
        
        let clipDurationTime = CMTimeSubtract(duration, clipTime)
        
        let videoTimeRange = CMTimeRangeMake(clipTime, clipDurationTime);
        
        let videoAssetTrack = asset!.tracks(withMediaType: AVMediaTypeVideo).first
        
        try? videoTrack.insertTimeRange(videoTimeRange, of: videoAssetTrack!, at: kCMTimeZero)
        
        let audioAssetTrack = asset!.tracks(withMediaType: AVMediaTypeAudio).first
        
        try? audioTrack.insertTimeRange(videoTimeRange, of: audioAssetTrack!, at: kCMTimeZero)
        
        /*****************************************************/
        
        let passThroughLayer = AVMutableVideoCompositionLayerInstruction.init(assetTrack: videoAssetTrack!)
        
        let passThroughInstruction = AVMutableVideoCompositionInstruction.init()
        
        passThroughInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, comosition.duration)
        
        passThroughInstruction.layerInstructions = [passThroughLayer]
        
        let videoComposition = AVMutableVideoComposition.init()
        
        videoComposition.frameDuration = CMTimeMake(1, videoCamera.frameRate)
        
        videoComposition.renderSize = videoAssetTrack!.naturalSize
        
        videoComposition.instructions = [passThroughInstruction]

        let renderSize = videoComposition.renderSize
        
        let ratio: CGFloat = min(renderSize.width / previewView.frame.width, renderSize.height / previewView.frame.height)
        
        let watermarkWidth: CGFloat = ceil(renderSize.width / 5.0)
        
        let watermarkHeight: CGFloat = ceil(watermarkWidth * watermarkLayer.frame.height / watermarkLayer.frame.width)
        
        let exportWatermarkLayer = CALayer()
        
        exportWatermarkLayer.contents = watermarkLayer.contents
        
        exportWatermarkLayer.frame = CGRect(x: CGFloat(renderSize.width - watermarkWidth - ceil(ratio * 16)), y: CGFloat(ceil(ratio * 16)), width: watermarkWidth, height: watermarkHeight)
        
        let parentLayer = CALayer.init()
        
        let videoLayer = CALayer.init()
        
        parentLayer.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(renderSize.width), height: CGFloat(renderSize.height))
        
        videoLayer.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(renderSize.width), height: CGFloat(renderSize.height))
        
        parentLayer.addSublayer(videoLayer)
        
        parentLayer.addSublayer(exportWatermarkLayer)
        
        videoComposition.animationTool = AVVideoCompositionCoreAnimationTool.init(postProcessingAsVideoLayer: videoLayer, in: parentLayer)
        
        let exportSession = AVAssetExportSession.init(asset:comosition.copy() as! AVAsset, presetName: AVAssetExportPresetHighestQuality)
        
        exportSession?.videoComposition = videoComposition
        exportSession?.shouldOptimizeForNetworkUse = false
        exportSession?.outputURL = exportURL
        exportSession?.outputFileType = AVFileTypeQuickTimeMovie
        
        try? FileManager.default.removeItem(at: exportURL!)
        
        weak var weakExportSession = exportSession
        exportSession?.exportAsynchronously(completionHandler: {
            if (weakExportSession?.status == .completed){
                
                try? FileManager.default.removeItem(at: self.movieURL!)

                self.saveVideoToAssetsLibrary()
                
            }else{
                
                let alert = UIAlertView(title: "Error", message: "Video Saving Failed", delegate: nil, cancelButtonTitle: "OK", otherButtonTitles: "Cancel")
                alert.show()
                self.KWSDKUI.setCloseBtnEnable(true)
                self.labRecordState.isHidden = true
                self.videoCamera.removeTarget(self.movieWriter)
//                 TODO: 销毁movieWritter
                self.movieWriter = nil
                self.setupMovieWritter()
           self.videoCamera.addTarget(self.movieWriter)
                
            }
        })
        
        
    }
    
    
    func saveVideoToAssetsLibrary(){
        
        let library = ALAssetsLibrary()
        
        if library.videoAtPathIs(compatibleWithSavedPhotosAlbum: exportURL) {
            
            library .writeVideoAtPath(toSavedPhotosAlbum: exportURL, completionBlock: { (assetURL, error) in
                
                try? FileManager.default.removeItem(at: self.exportURL!)
                DispatchQueue.main.sync(execute: {() -> Void in
                    if error != nil{
                        let alert = UIAlertView(title: "Error", message: "Video Saving Failed", delegate: nil, cancelButtonTitle: "OK", otherButtonTitles: "Cancel")
                        alert.show()
                        
                    }else{
                        let alert = UIAlertView(title: "Video Saved", message: "Saved To Photo Album", delegate: nil, cancelButtonTitle: "OK", otherButtonTitles: "Cancel")
                        alert.show()
                        
                    }
                    self.KWSDKUI.setCloseBtnEnable(true)
                    self.labRecordState.isHidden = true
                    self.videoCamera.removeTarget(self.movieWriter)
//                     TODO: 销毁movieWritter
                    self.movieWriter = nil
                    self.setupMovieWritter()
                    self.videoCamera.addTarget(self.movieWriter)
                    
                })
            })
            
            
        }else{
            
            let alert = UIAlertView(title: "Error", message: "Video Cannot Be Saved", delegate: nil, cancelButtonTitle: "OK", otherButtonTitles: "Cancel")
            alert.show()
            KWSDKUI.setCloseBtnEnable(true)
            labRecordState.isHidden = true
            videoCamera.removeTarget(movieWriter)
//             TODO: 销毁movieWritter
            self.movieWriter = nil
            self.setupMovieWritter()
            videoCamera.addTarget(movieWriter)
            
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
}

extension KWViewController {
    
    fileprivate func initKwSDK(){
        
        KWSDKUI = KWSDK_UI.shareManager()
        KWSDKUI.delegate = self
        KWSDKUI.kwSdk = KWSDK.sharedManager()
        KWSDKUI.kwSdk.renderer = KWRenderer.init(modelPath: nil)
        KWSDKUI.kwSdk.cameraPositionBack = false
        if (KWRenderer.isSdkInitFailed()) {
            print("Lic file overdue")
            
            return;
        }
        
        KWSDKUI.setViewDelegate(self)
        KWSDKUI.kwSdk.initSdk();
    }
    
    fileprivate func initKwSDKUI(){
        
        KWSDKUI.setViewDelegate(self);
        KWSDKUI.isClearOldUI = false
        KWSDKUI.initSDKUI()
        KWSDKUI.setCloseVideoBtnHidden(false)
        
        KWSDKUI.toggleBtnBlock = { Void ->Void in
            /*
             rotate camera
             */
            self.KWSDKUI.kwSdk.cameraPositionBack = !self.KWSDKUI.kwSdk.cameraPositionBack
            self.videoCamera.rotateCamera()
            
        }
        
        KWSDKUI.closeVideoBtnBlock = { [weak self] Void ->Void in
            
            self!.dismiss(animated: true, completion: {
                self!.KWSDKUI.popAllView()
                self!.KWSDKUI.kwSdk.videoCamera.stopCapture()
                
                /*
                 release memory
                 */
                KWSDK_UI.releaseManager()
                KWSDK.releaseManager()
            })
        }
    }
    
    
    
}

extension KWViewController: GPUImageVideoCameraDelegate {
    
    func willOutputSampleBuffer(_ sampleBuffer: CMSampleBuffer!) {
        
        let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        
        KWUtils.processPixelBuffer(pixelBuffer, andRender: KWSDKUI.kwSdk)
        
        /*
         add code below if you want to take photo
         */
        outputImage = CIImage.init(cvPixelBuffer: pixelBuffer!)
        outputWidth = CVPixelBufferGetWidth(pixelBuffer!)
        outputheight = CVPixelBufferGetHeight(pixelBuffer!)
    }
}


extension KWViewController: KWSDKUIDelegate {

    func didClickOffPhoneButton() {
        
        takePhoto()
    }
    
    func didBeginLongPressOffPhoneButton() {
        startRecording()
    }
    
    func didEndLongPressOffPhoneButton() {
        endRecording()
    }


}


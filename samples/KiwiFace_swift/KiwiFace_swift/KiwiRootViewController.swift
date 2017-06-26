//
//  KiwiRootViewController.swift
//  KiwiFace_swift
//
//  Created by 伍科 on 17/6/1.
//  Copyright © 2017年 KiwiFaceSDK. All rights reserved.
//

import UIKit

class KiwiRootViewController: UIViewController {

    let ScreenWidth_KW = UIScreen.main.bounds.size.width
    let ScreenHeight_KW = UIScreen.main.bounds.size.height
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let imageView = UIImageView()
        let width: CGFloat = ScreenWidth_KW / 3
        imageView.frame = CGRect(x: CGFloat((ScreenWidth_KW - width) / 2), y: CGFloat(ScreenHeight_KW - 2 * width - 50), width: width, height: CGFloat(width / 1.176))
        imageView.image = UIImage(named: "logo")
        
        let btnTest = UIButton()
        btnTest.frame = CGRect(x: CGFloat((ScreenWidth_KW - ScreenWidth_KW / 3) / 2), y: CGFloat(ScreenHeight_KW - ScreenWidth_KW / 3 - 50), width: CGFloat(ScreenWidth_KW / 3), height: CGFloat(ScreenWidth_KW / 3))
        btnTest.setImage(UIImage(named: "enterVideo_sys"), for: .normal)
        
        btnTest.addTarget(self, action:#selector(testOnTap(sender:)), for: .touchUpInside)
        
        let backImg = UIImageView(frame: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(ScreenWidth_KW), height: CGFloat(ScreenHeight_KW)))
        backImg.image = UIImage(named: "entranceBackground_sys")
        backImg.isUserInteractionEnabled = true
        
        backImg.addSubview(imageView)
        backImg.addSubview(btnTest)
        view.addSubview(backImg)
        
        // Do any additional setup after loading the view.
    }

    func testOnTap(sender: UIButton) {
    
        let recordView = KWViewController()

        present(recordView, animated: true, completion: {() -> Void in
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

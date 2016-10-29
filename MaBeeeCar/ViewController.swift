//
//  ViewController.swift
//  MaBeeeCar
//
//  Created by 増田崇 on 2016/09/18.
//  Copyright © 2016年 umiryu. All rights reserved.
//

import UIKit
import MaBeeeSDK

class ViewController: UIViewController {

    @IBOutlet weak var ハンドルスライダー: UISlider!
    @IBOutlet weak var アクセルスライダー: UISlider!

    @IBOutlet weak var 左MaBeee出力: UILabel!
    @IBOutlet weak var 右MaBeee出力: UILabel!

    @IBOutlet weak var 左MaBeee: UILabel!
    @IBOutlet weak var 右MaBeee: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // スライダー初期化
        self.アクセルスライダー.value = 0
        self.ハンドルスライダー.value = 0.5
        // ハンドルスライダー方向変換
        self.アクセルスライダー.transform = CGAffineTransform(rotationAngle: CGFloat(-M_PI_2))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func 計算(アクセル: Float, ハンドル: Float) {
        var ベース = アクセル
        if(アクセル < 0.2) { ベース = 0 }
        var 左 = ベース
        var 右 = ベース
        if(ハンドル < 0.4) {
            左 -= (0.4 - ハンドル)
        } else if(ハンドル > 0.6) {
            右 -= (ハンドル - 0.6)
        }
        // 右イナスになったら0にする
        if(左 < 0) { 左 = 0 }
        if(右 < 0) { 右 = 0 }
        self.左MaBeee出力.text = String(Int32(左*100))
        self.右MaBeee出力.text = String(Int32(右*100))
        
        for device in MaBeeeApp.instance().devices() {
            if(self.左MaBeee.text == device.name) {
                device.pwmDuty = Int32(左*100)
                continue
            }
            if(self.右MaBeee.text == device.name) {
                device.pwmDuty = Int32(右*100)
                continue;
            }
        }
        
    }

    func 接続チェック() {
        if let mabeee = MaBeeeApp.instance() {
//            if(mabeee.devices().count == 0) {
//                return;
//            }
            for device in mabeee.devices() {
                if(self.左MaBeee.text == "接続なし") {
                    self.左MaBeee.text = device.name
                    continue
                }
                if(self.右MaBeee.text == "接続なし") {
                    self.右MaBeee.text = device.name
                    break;
                }
            }
            if(self.左MaBeee.text == "接続なし" || self.右MaBeee.text == "接続なし") {
                let when = DispatchTime.now() + 2.0
                DispatchQueue.main.asyncAfter(deadline: when, execute: {
                    self.接続チェック()
                })
            }
        }
    }
    
    @IBAction func ハンドル動作(_ sender: UISlider) {
        計算(アクセル: self.アクセルスライダー.value, ハンドル: ハンドルスライダー.value)
    }
    @IBAction func アクセル動作(_ sender: UISlider) {
        計算(アクセル: self.アクセルスライダー.value, ハンドル: ハンドルスライダー.value)
    }
    @IBAction func MaBeee接続(_ sender: UIButton) {
        let mabeee = MaBeeeScanViewController()
        mabeee.show(self)
        self.左MaBeee.text = "接続なし"
        self.右MaBeee.text = "接続なし"
        self.接続チェック()
    }
    
    @IBAction func MaBeee交換(_ sender: UIButton) {
        let tmp = self.左MaBeee.text
        self.左MaBeee.text = self.右MaBeee.text
        self.右MaBeee.text = tmp
    }
}


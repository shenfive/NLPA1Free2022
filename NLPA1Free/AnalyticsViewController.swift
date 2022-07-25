//
//  AnalyticsViewController.swift
//  NLPA1Free
//
//  Created by 申潤五 on 2022/7/19.
//

import UIKit
import Social
import WebKit

class AnalyticsViewController: UIViewController {
    
    @IBOutlet weak var chartWeb: WKWebView!
    var userAnswers = [Int]()
    var analyRes = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chartWeb.isOpaque = false
        chartWeb.backgroundColor = UIColor.clear
        chartWeb.scrollView.isScrollEnabled = true
        
        view.backgroundColor = UIColor(patternImage: UIImage(named: "background")!)
        let a = Float(countInt(number: 0, inIntArray: userAnswers)) / Float(userAnswers.count) * 100
        let b = Float(countInt(number: 1, inIntArray: userAnswers)) / Float(userAnswers.count) * 100
        let c = Float(countInt(number: 2, inIntArray: userAnswers)) / Float(userAnswers.count) * 100
        let d = Float(countInt(number: 4, inIntArray: userAnswers)) / Float(userAnswers.count) * 100
        
        
        let analyticsTheArray = ["<p style='text-align:center' ><strong>根據本次的測試,你比較是視覺型（Visual）</strong></p><br />特點：<br />您習慣先用雙眼去看和接收外在信息，眼睛的學習和處理能力最快，所以他們喜歡顏色鮮明、外觀漂亮的人事物；常坐不安定，小動作多，能夠在同一時間做幾件事；在乎事情的重點，不在乎事情的細節，喜歡清楚、簡單的表達重點和在一開始就直入話題；喜歡節奏快的事物。<br /><br />身形／姿勢：<br />大多數情況下視覺形的人都偏瘦，當然也有胖的。他們頭多向上昂、行動快捷，說話時手的動作多且通常手活動在胸部以上。<br /><br />呼吸：<br />呼吸較淺，常止於胸腔上半部分。<br /><br />語調／語速：<br />語調簡單而單一，語速快。<br /><br />語言文字：<br />常使用和表達的文字有，我看到、清晰、模糊、漂亮、悅目、焦點、速度、彩色、燦爛、觀點、觀察、圖案、出現、凝望、光明、朦朧、明白、明顯地、鮮豔奪目、多彩多姿等等。",
                                 "<p style='text-align:center' ><strong>根據本次的測試,你比較是聽覺型（Auditory）</strong></p><br />特點：<br />您習慣先用耳朵去聽和接收信息，所以在許多時候他們的耳朵非常靈敏，十分重視寧靜的環境及聲音的質量，同時他們善於文字處理和在乎事情的細節，做事情非常注重程序和步驟，喜歡有條不紊的進行；善於歌唱和聆聽。<br/><br/>身形／姿勢：<br />您不會像視覺型那樣偏瘦也不會像觸覺型那樣強壯和有力，他們的身形可能會豐滿而鬆垮，當然他們也存在於每種身材當中。說話時可能會將手靠近或託住耳朵和嘴附近。<br/><br />呼吸：<br />呼吸平穩、有規律和有節奏，在胸腔與腹部之間。<br/><br/>語調／語速：<br />語調抑揚頓挫、高低快慢十分有節奏感，語速中等。<br/><br/>語言文字：<br />我聽到、聆聽、響亮、談談、聽懂、刺耳、溝通、寧靜、韻律、耳邊風、無話可說、值得一聽、清楚、清晰、詢問、討論、悅耳等等",
                                 "<p style='text-align:center' ><strong>根據本次的測試,你比較是觸覺型（Kinesthetic）</strong></p><br />特點：<br />觸覺型包含了觸覺、嗅覺、味覺，他們慣於先用感覺去感受和接收信息，所以在許多時候他們對自我的感覺非常的注重；在乎與人之間的關係、感覺及重要意義；言語中​​常提及感受或經歷。<br/><br/>身形／姿勢：<br />因為視覺型和聽覺型的人對觸碰感的要求遠沒有觸覺型的人高，所以相比之下觸覺型的人較為強壯和結實。<br/><br/>呼吸：<br />呼吸慢而深沉，會用到胸部以下及腹部。<br/><br/>語調／語速：<br />語調低沉，語速慢。<br/><br/>語言文字：<br />我感覺、壓迫、氣氛、把握、安全、危險、激動、口福、自然、壓力、匆忙、行動、難受、謹慎、順利、開心、快樂、幸福、成功、支持、一點都不怕、趁熱打鐵、興奮、冰冷、緊張、等等。"]
        
        
        
        
        if a > b  && a > c && a > d{
            analyRes = 0
        }else if b > c && b > d {
            analyRes = 1
        }else if c > d {
            analyRes = 2
        }else {
            analyRes = 2
        }
        
        print("a:\(a)b:\(b)c:\(c)")
        
        
        
        let webString = String(format:"<br/><br/><br/><br/><br/><br/><div style='background-color:transparent'><div style='text-align:center'><canvas id='canvas' width='400' height='400'></canvas></div><br/><div style='text-align:center;color:#fff'><samp style='width:20px;height:20px;background-color:#454FDF;font-size:56px;border-radius:5px'>&nbsp;V:%2.1f%%&nbsp;</samp>&nbsp;<samp style='width:20px;height:20px;background-color:#F28107;font-size:56px;border-radius:5px'>&nbsp;A:%2.1f%%&nbsp;</samp>&nbsp;<samp style='width:20px;height:20px;background-color:#48990B;font-size:56px;border-radius:5px'>&nbsp;K:%2.1f%%&nbsp;</samp><div style='color:#000000;font-size:48px;text-align:left'>%@</div><script type='text/javascript'>var myColor = ['#454FDF','#F28107','#48990B','#542437','#53777A'];var myData = [%2.4f,%2.4f,%2.4f,0,0];function getTotal(){var myTotal = 0;for (var j = 0; j < myData.length; j++) {myTotal += (typeof myData[j] == 'number') ? myData[j] : 0;}return myTotal;}function plotData() {var canvas;var ctx;var lastend = 0;var myTotal = getTotal();canvas = document.getElementById('canvas');ctx = canvas.getContext('2d');ctx.clearRect(0, 0, canvas.width, canvas.height);for (var i = 0; i < myData.length; i++) {ctx.fillStyle = myColor[i];ctx.beginPath();ctx.moveTo(200,200);ctx.arc(200,200,200,lastend,lastend+(Math.PI*2*(myData[i]/myTotal)),false);ctx.lineTo(200,200);ctx.fill();lastend += Math.PI*2*(myData[i]/myTotal);}}plotData();</script><br/><br/></div>",
                               a,b,c,
                               analyticsTheArray[analyRes],
                               a,b,c
        )
        print(webString)
        
        chartWeb.loadHTMLString(webString, baseURL: nil )//URL(string: "https://www.apple.com.tw"))
        
        
        
        
    }
    
    func countInt(number:Int, inIntArray:[Int]) -> Int{
        
        var count = 0
        for int in inIntArray{
            print("in:\(int) =? \(number) \(int == number)")
            if int == number {
                count += 1
            }
        }
        print("count=\(count)")
        
        return count
    }
    
    @IBAction func backHome(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    @IBAction func fbShare(_ sender: UIButton){
        print("share")
        let shareAddress = ["https://www.facebook.com/732906446875789/photos/ms.c.eJwzNzayNDIxNDKzMDcxMDLUM4fwjSF8Azjf2NTEwMzCHADkIgmB.bps.a.732924006874033.1073741828.732906446875789/732924133540687/?type=3&theater","https://www.facebook.com/732906446875789/photos/ms.c.eJwzNzayNDIxNDKzMDcxMDLUM4fwjSF8Azjf2NTEwMzCHADkIgmB.bps.a.732924006874033.1073741828.732906446875789/732924126874021/?type=3&theater","https://www.facebook.com/732906446875789/photos/ms.c.eJwzNzayNDIxNDKzMDcxMDLUM4fwjSF8Azjf2NTEwMzCHADkIgmB.bps.a.732924006874033.1073741828.732906446875789/732924136874020/?type=3&theater"]
        
        let items:[Any] = [URL(string: shareAddress[analyRes])!]
        let nextVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(nextVC, animated: true)
        
    }
}

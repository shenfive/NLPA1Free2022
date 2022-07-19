//
//  TestViewController.swift
//  NLPA1Free
//
//  Created by 申潤五 on 2022/7/19.
//

import UIKit
import Firebase
import Reachability
import AVFoundation

class TestViewController: UIViewController {
    
    let speaker = AVSpeechSynthesizer()
    
    //Vpon
//    var vponAd:VpadnBanner?
//    var vpadInterstitial:VpadnInterstitial?
    
    
    var qustions:NSMutableArray = NSMutableArray()
    var rechablity:Reachability? = nil //= Reachability.init()
    let 最大問題數 = 19
    var 目前問題指標 = 0
    var 問題序 = [Int]()

    var userAnswers = [Int]()
    
    let currentDBver = 1
    var dbVer = 0
    var waitForAnswer = true

    @IBOutlet weak var qustion: UILabel!

    @IBOutlet weak var ans1: UIButton!
    @IBOutlet weak var ans2: UIButton!
    @IBOutlet weak var ans3: UIButton!
    
    @IBOutlet weak var answerArea: UIView!
    
    
    override func viewDidLoad() {
        showWaiting()
        
        answerArea.isHidden = true

        ans1.titleLabel?.numberOfLines = 2
        ans2.titleLabel?.numberOfLines = 2
        ans3.titleLabel?.numberOfLines = 2
        
        
        super.viewDidLoad()
        do{
            rechablity = try Reachability.init()
            try rechablity?.startNotifier()
            print("start Notifier")
        }catch{
            print(error.localizedDescription)
        }
        
        view.backgroundColor = UIColor(patternImage: UIImage(named: "background")!)


    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        let userDefult = UserDefaults.standard
        dbVer = userDefult.integer(forKey: "dbversion")
        if dbVer < currentDBver {
            updateQustions()
        }else{
            qustions = userDefult.mutableArrayValue(forKey: "qustions")
            startTest()
        }
        
    }
    
    // MARK：開始測驗
    
    func startTest(){
        userAnswers = [Int]()
        stopWaiting()
        問題序 = getNumberList(qustions.count)
        nextQustion()
    }
    
    func nextQustion(){
        
        waitForAnswer = true
        answerArea.isHidden = true
        answerArea.alpha = 0
        
        let 目前題號 = 問題序[目前問題指標]
        let 目前題目 = qustions.object(at: 目前題號) as! NSDictionary
        
        let 答案陣列 = [目前題目.object(forKey: "a") as! String ,
                        目前題目.object(forKey: "b") as! String,
                        目前題目.object(forKey: "c") as! String]
        let 答案序 = getNumberList(3)
        
        self.qustion.alpha = 0

        UIView.animate(withDuration: 1.4, delay: 0.1,  animations: {
            self.qustion.alpha = 1
        }, completion: { (complete) in
            UIView.animate(withDuration: 1.2, delay: 0.2, animations: {
                self.answerArea.isHidden = false
                self.answerArea.alpha = 1
            }, completion: { (complete) in
                if complete{
                    self.waitForAnswer = false
                }
            })
        })
        
        
        self.qustion.text = 目前題目.object(forKey: "qustion") as? String
        ans1.tag = 答案序[0]
        ans1.setTitle(答案陣列[ans1.tag], for: .normal)
        ans2.tag = 答案序[1]
        ans2.setTitle(答案陣列[ans2.tag], for: .normal)
        ans3.tag = 答案序[2]
        ans3.setTitle(答案陣列[ans3.tag], for: .normal)
        
        
        let utterance = AVSpeechUtterance(string: self.qustion.text!)
        utterance.rate = 0.53
        utterance.pitchMultiplier = 0.8
        
        //強制中文語音
        let voices = AVSpeechSynthesisVoice.speechVoices()
        for voice in voices{
            if "zh-TW" == voice.language{
                utterance.voice = voice
            }
        }

        speaker.speak(utterance)
    
    }
    
    


    @IBAction func answerSelected(_ sender: UIButton) {
        
        // 若答案尚未完成顯示，不做反應
        if waitForAnswer {
            return
        }
        
        speaker.stopSpeaking(at: .immediate)
    // 若完成問題去答案頁，不然存答案與下一題
        userAnswers.append(sender.tag)
        目前問題指標 += 1
        if 目前問題指標 >= 最大問題數 {
            print(userAnswers)
            self.performSegue(withIdentifier: "goAnalytics", sender: nil)
          
            return
        }
        nextQustion()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goAnalytics" {
            let avc = segue.destination as! AnalyticsViewController
            avc.userAnswers = self.userAnswers
        }
    }
    
// MARK: 由 FireBase 更新題目
    
    func updateQustions(){
        
        
        
        //檢查網路狀態
        if let networkStatus  = rechablity?.connection{
            switch networkStatus {
            case .unavailable:
                let alert = UIAlertController(title: "警告", message: "目前沒有網路，無法下載題目，請檢查網路狀態後再試", preferredStyle: .alert)
                let okButton = UIAlertAction(title: "確定", style: .default, handler: { (action) in
//                    self.dismiss(animated: true, completion: nil)
                    self.navigationController?.popToRootViewController(animated: true)
                })
                alert.addAction(okButton)
                present(alert, animated: true, completion:nil)
                return

            case .wifi:
                print("由 Wi-Fi 網路下載")
            case .cellular:
                print("由手機網路下載")
            default:
                break
            }
        }
    
        
        
        
        let refversion = Database.database().reference(withPath: "/version/db")
        refversion.observeSingleEvent(of: .value, with:{ (snapshot) in
            
            print(self.dbVer != (snapshot.value as? Int)!)
            if self.dbVer != (snapshot.value as? Int)! {
                let reference = Database.database().reference(withPath: "/data/zh-tw")
                reference.observeSingleEvent(of: .value, with: { (snapshot) in
                    let values = snapshot.value as! NSDictionary
                    for item in values {
                        
                        if let _ = Int(item.key as! String){
                            self.qustions.add(item.value)
                        }else{
                            print(item.key)
                                self.dbVer = item.value as! Int
                        }
                    }

                    UserDefaults.standard.set(self.qustions, forKey: "qustions")
                    UserDefaults.standard.set(self.dbVer, forKey: "dbversion")
                    UserDefaults.standard.synchronize()
                    self.startTest()
                }){(error) in
                    print(error.localizedDescription)
                }

            }
            
        }){(error) in
            print(error.localizedDescription)
            print("error!!!")
        }

        

    }
    
    
    
    // MARK: 常用 Functions
    
    
    
    // 由 number 取 inThe  個的陣列, 產生亂數
    
    let getNumberList =  {(numbers:Int) -> [Int] in
        
        // 產生陣列
        var numbersArray = [Int]()
        for i in 0...numbers-1 {
            numbersArray.append(i)
        }
        
        //擾亂陣列
        for _ in 1...( numbers * 2 ) {
            

            let randomSwapL =  Int64(arc4random()) % Int64(numbers)
            let randomSwap:Int = Int(randomSwapL)
            let temp = numbersArray[0]
            numbersArray[0] = numbersArray[randomSwap]
            numbersArray[randomSwap] = temp
        }
        print(numbersArray)
 
        return numbersArray
    }
    
    //顯示等待服務（轉圈圈）
    func showWaiting(){
        let caverView = UIView()
        caverView.frame = self.view.frame
        caverView.backgroundColor = UIColor.white
        caverView.alpha = 0.5
        caverView.tag = 10001
        
        let waitingView = UIActivityIndicatorView(style: .gray)
        waitingView.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        waitingView.center = self.view.center
        waitingView.startAnimating()
        caverView.addSubview(waitingView)
        self.view.addSubview(caverView)
    }
    
    //取消等待服務（取消轉圈圈）
    func stopWaiting(){
        for  view in self.view.subviews{
            if (view.tag == 10001){
                view.removeFromSuperview()
            }
        }
        
    }

//    MARK : 更新題目用
//    func inits(){
//        self.qustionList.append(["number": 1, "qustion": "你回想你被某人強烈吸引的時候，那時，使你被他們吸引的第一件事物是什麼？", "a": "他們看起來的樣子", "b": "他們對你說的一些事，或是你聽到的一些事", "c": "他們觸摸你的方式，或是你感覺到的某些東西"])
//        self.qustionList.append(["number": 2, "qustion": "你回想一個最特別，最棒的假期，在那個假期中，你所記得的第一個經驗是什麼？", "a": "那個度假區看起來的樣子", "b": "聽起來的不同方式", "c": "你在哪裡度假的感覺"])
//
//        self.qustionList.append(["number": 3, "qustion": "當你開車時，你如何駕駛？", "a": "尋找路標，或遵循地圖", "b": "聽從能夠指出正確方向的熟悉聲音", "c": "憑著直覺，或是身在何處的感覺"])
//        self.qustionList.append(["number": 4, "qustion": "當我參與運動比賽時，我特別喜歡:", "a": "整場比賽看起來的樣子，或者，參與其中的我看起來的樣子", "b": "比賽的聲音，例如，球的重擊聲，或是，群眾的吼叫聲", "c": "比賽的感覺，例如，對夥伴的注意力或是對動作的感受"])
//        self.qustionList.append(["number": 5, "qustion": "當我被分配到一項任務時，什麼方式比較容易讓我了解那個任務，並且去執行它？", "a": "以書寫或圖形的方式表達", "b": "向我解釋", "c": "對那個任務的目的、正確性有清楚的感受"])
//        self.qustionList.append(["number": 6, "qustion": "當我受困於某個問題時，怎樣做對我有幫助？", "a": "把它們寫下來，讓我可以清楚地看著他們", "b": "對其他人說話，或者聽別人說，直到我的問題聽起來比較容易被聽懂", "c": "在心裡將它們加以整理，知道他們變得有意義"])
//        self.qustionList.append(["number": 7, "qustion": "我發現如果怎樣做，我比較容易和朋友相處：", "a": "他們以生動、有重點的陳述方式,我溝通", "b": "他們以容易聽懂，以及有變化的說話方式和我互動", "c": "我有一種他們知道我來自於何處的感覺"])
//        self.qustionList.append(["number": 8, "qustion": "當我要做決定時，怎樣做會有幫助？", "a": "在心中描繪出可能的選擇", "b": "聆聽心中雙方的對話", "c": "去體會如果放棄某一個選擇的感受"])
//        self.qustionList.append(["number": 9, "qustion": "我可能會支持哪一類團體:", "a": "攝影、繪畫、閱讀、素描、電影", "b": "音樂、樂器、海的聲音、管樂隊、音樂會", "c": "球類比賽、木工、按摩、內省、感動"])
//        self.qustionList.append(["number": 10, "qustion": "在戀愛關係中，我喜歡:", "a": "看者親密愛人的樣子", "b": "聽着他所說的的每一句話", "c": "感受每一種感覺"])
//        self.qustionList.append(["number": 11, "qustion": "當我買了一本時尚雜誌，看完一次後，接下來會做的事情是什麼？", "a": "再看另一本真正的好雜誌，或把自己穿上那件衣服的樣子畫出來", "b": "好好的聽售貨員的說明，而且／或是，和自己對話，以決定是否要購買", "c": "感覺它，或是觸摸它，看看它是否是我喜歡穿的衣服"])
//        self.qustionList.append(["number": 12, "qustion": "當我想到之前的老情人時，我第一件做的事情是什麼?", "a": "用心中的眼睛看他", "b": "在心中聆聽他的聲音", "c": "對那人升起一種特殊的感覺"])
//        self.qustionList.append(["number": 13, "qustion": "在健身中心，第一個感到滿足的經驗是來自於:", "a": "看到鏡中的自己身材越來越好", "b": "聆聽到自己，或別人說我看起來很棒", "c": "感覺到我的身體變得更強壯，而且更有身材"])
//        self.qustionList.append(["number": 14, "qustion": "當要計算數字時，我利用什麼方式來驗證我的答案?", "a": "注視着數字，看他們看起來是否正確", "b": "在腦中計算著這些數字", "c": "利用手指頭去得到正確的感覺"])
//        self.qustionList.append(["number": 15, "qustion": "當我拼英文字時，我用什麼方式來確定字時正確的?", "a": "想像那個字的樣子，看看他是是否像正確", "b": "在心中把字大聲的念出來，或聆聽那個字", "c": "感覺那個字的拼法"])
//        self.qustionList.append(["number": 16, "qustion": "在學校時，我最喜歡一個科目的原因是?", "a": "這科目在書本或黑板上看起來的樣子", "b": "當教到這一科目時，它聽起來的聲音", "c": "當我學到更多有關這科目的東西時，一種興趣感"])
//        self.qustionList.append(["number": 17, "qustion": "當我喜歡某人時，我立刻獲得的感覺是:", "a": "透過愛的雙眼，看到我們兩個在一起的樣子", "b": "告訴對方【我愛你】，我聽到對方這麼說時的聲音", "c": "一種與對方有關的温暖感覺"])
//        self.qustionList.append(["number": 18, "qustion": "當我不喜歡某人時，第一個覺得討厭的體驗是：", "a": "當我看見他們走進我時", "b": "當他們開始對我說話時", "c": "讓我感覺到他們接近時"])
//        self.qustionList.append(["number": 19, "qustion": "在海邊，第一件讓我感到高興的事是：", "a": "看到沙，微笑的太陽，以及湛藍的海水", "b": "波浪的聲音，笑著的微風，以及遠方的颼颼聲", "c": "沙，鹹濕空氣，以及和煦的感覺"])
//        self.qustionList.append(["number": 20, "qustion": "在宴會中別人談話，如果發生了什麼事，會讓我的整個經驗架構有所改變?", "a": "燈光變亮或變暗", "b": "改變音樂的速度", "c": "室內溫度改變"])
//        self.qustionList.append(["number": 21, "qustion": "在什麼情況下，我知道我的職業生涯正在轉變?", "a": "我看見自己坐在角落的主管辦公室", "b": "我聽到主管說：【你升職了】", "c": "感受到升遷的滿足感"])
//        self.qustionList.append(["number": 22, "qustion": "晚上睡覺前，什麼比較重要?", "a": "屋內幾近黑暗，或者些許溫柔的燈光", "b": "屋內有這很安詳、愉悅的寂靜", "c": "感覺床很舒服"])
//        self.qustionList.append(["number": 23, "qustion": "早上起床時，什麼會特別讓我享受清晨？", "a": "太陽的光線或者是陰暗的天氣", "b": "新鮮微風的聲音，或是雨敲打窗戶的聲音", "c": "溫暖的羊毛被或是法蘭絨被單的感覺"])
//        self.qustionList.append(["number": 24, "qustion": "當我感到到焦慮時，第一件發生的事情是？", "a": "在某種程度來說，世界以一種不同的方式呈現", "b": "聲音開始干擾我", "c": "輕鬆的感覺開始改變"])
//        self.qustionList.append(["number": 25, "qustion": "當我很高興時，我的世界將會：", "a": "清晰美好的閃耀著", "b": "產生完全和諧的共鳴", "c": "非常適切吻合我生活的空間"])
//        self.qustionList.append(["number": 26, "qustion": "我會很怎樣的人相處的比較好？", "a": "透過注視和世界有所關連的人", "b": "透過聽和世界有所關連的人", "c": "透過感覺來和世界有所關連的人"])
//        self.qustionList.append(["number": 27, "qustion": "當我受到激勵時，第一件發生的事情是？", "a": "從一種嶄新，豐富的觀點來看事情", "b": "我告訴自己，這種狀況將會讓我創造出新的可能性", "c": "我確實可以感覺到自己精神昻揚"])
//        self.qustionList.append(["number": 28, "qustion": "有人和你告白【我愛你】時，你會：", "a": "有個人愛我，或是我們在一起的景象", "b": "和我自己的靈魂對話【這真是太棒了】", "c": "一種快樂的滿足感覺"])
//        self.qustionList.append(["number": 29, "qustion": "對我而言，死亡可能是", "a": "不能看見，或是，另一種全新的方式看見", "b": "不能聽到，或是，以一種全新的方式聽", "c": "不能感受，或是，一種全新的方式來感受"])
//        self.qustionList.append(["number": 30, "qustion": "與某人有親和感覺就是", "a": "以一種美好，容易相處的方式來看他", "b": "聽見對方正好就是用我的方式來溝通", "c": "以對方感覺我的方式來感覺對方"])
//        self.qustionList.append(["number": 31, "qustion": "如果想購買新的手機的話你會考慮甚麼條件", "a": "外型是否美觀", "b": "其他朋友或店員的意見", "c": "分析價格及功能是否合乎需求"])
//        self.qustionList.append(["number": 32, "qustion": "下例哪一種學習方式比較適合你", "a": "豐富的學理依據，詳盡的解析", "b": "聽老師講課就可以，不需要其他教材", "c": "體驗式的學習方式"])
//        self.qustionList.append(["number": 33, "qustion": "你在旅行迷路了，找不到你訂的飯店時，你會怎麼辦？", "a": "找地圖或路標", "b": "找人問路", "c": "回想剛走過的路，仔細想想，分析是那兒走錯"])
//        self.qustionList.append(["number": 34, "qustion": "你最喜歡的休閒活動是？", "a": "看電影，看書", "b": "唱卡拉OK，聽CD", "c": "運動，旅行"])
//        self.qustionList.append(["number": 35, "qustion": "你最喜歡的一間餐廳是因為？", "a": "燈光美，裝潢漂亮且特別", "b": "音樂優美，氣氛佳", "c": "服務親切"])
//        self.qustionList.append(["number": 36, "qustion": "你指導部屬的方法是？", "a": "把要求寫下來告訴他", "b": "直接找他當面溝通", "c": "服務親切"])
//        self.qustionList.append(["number": 37, "qustion": "你最喜歡那一種電影？", "a": "科幻片，動作片", "b": "歌舞片，音樂劇", "c": "文藝片，喜劇片"])
//        self.qustionList.append(["number": 38, "qustion": "旅遊會讓你想起....", "a": "優美的風景", "b": "蟲鳴鳥叫，林風海浪聲", "c": "和家人朋友共聚的歡樂時光"])
//        self.qustionList.append(["number": 39, "qustion": "當你第一次學習一個新項目時，你偏好於開始.....", "a": "一個願景與成果想像圖", "b": "與你自己或他人交談該項目", "c": "如果完成該項目的感覺"])
//        self.qustionList.append(["number": 40, "qustion": "當你遇到問題時，你會願意.....", "a": "想像不同的景象", "b": "討論所有的選擇", "c": "返回意見"])
//        self.qustionList.append(["number": 41, "qustion": "當你慶祝勝利時，你喜歡.....", "a": "為每個人呈現一幅明亮的圖畫", "b": "廣播這個消息，讓大家都知道", "c": "拍拍每個人的背"])
//        self.qustionList.append(["number": 42, "qustion": "你在談判時，你更喜歡.....", "a": "假設各種可能性", "b": "選擇爭論 ", "c": "保持一個靈活的姿態"])
//        self.qustionList.append(["number": 43, "qustion": "你在教學研討中，你更喜歡.....", "a": "擴展其意思", "b": "一個詞一個詞地聽", "c": "抓住訊息的重點"])
//        self.qustionList.append(["number": 44, "qustion": "你在會議中，更喜歡.....", "a": "觀察他人的觀點", "b": "聽他人的評論", "c": "感覺他人的力度"])
//        self.qustionList.append(["number": 45, "qustion": "在前往工作的路上，你更喜歡.....", "a": "思考你的時間表", "b": "感覺今天一天會怎麼樣", "c": "專注於將要來臨的一天"])
//        self.qustionList.append(["number": 46, "qustion": "腦力激盪會議中.....", "a": "鳥瞰整個情景", "b": "大聲地說出建議", "c": "感受大家的思考"])
//        self.qustionList.append(["number": 47, "qustion": "當你需要專業資訊時，你會.....", "a": "尋找專家的觀點", "b": "和一個專家交談", "c": "使用其他的觀點"])
//        self.qustionList.append(["number": 48, "qustion": "當你的觀點面對挑戰時，你會.....", "a": "獲得他人立場的感覺", "b": "闡明他人的觀點", "c": "試探他人"])
//        self.qustionList.append(["number": 47, "qustion": "當你在面試新員工時，，你會.....", "a": "考察他們潛在的所有方面", "b": "了解對其個人簡歷的評論", "c": "牢牢抓住他們的經驗"])
//        self.qustionList.append(["number": 47, "qustion": "當你準備一個提案時，你會.....", "a": "闡明整體的圖像", "b": "清楚地說明主要觀點", "c": "開始一個摘要的提綱"])
//
//        for i in 0...( qustionList.count - 1  ){
//
//            let q = qustionList[i] as! NSDictionary
//
//            let item = ["a":q.object(forKey: "a") as! String,
//                        "b":q.object(forKey: "b") as! String,
//                        "c":q.object(forKey: "c") as! String,
//                        "qustion":q.object(forKey: "qustion") as! String,]
//            print(item)
//
//            let ref = FIRDatabase.database().reference(withPath: "/data/zh-tw")
//            ref.child(String((q.object(forKey: "number") as! Int))).updateChildValues(item)
//
//
//        }
//
//    }
    /*
    // MARK: - Navigation

     
     
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

    


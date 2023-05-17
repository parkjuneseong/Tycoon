//
//  GameOverViewController.swift
//  Tycoon
//
//  Created by 박준성 on 2023/02/11.
//

import UIKit

// mold 터치 -> 반죽올림
// 아닐때 터치하면 -> 팥올림 (팥병이 선택되어있을때, 바닐라병이 선택되어있을때)
// 팥올려져있는 상태에서 터치 -> 뒤집음
// 뒤집은 상태에서 터치하면 -> 붕어빵빼기


/*
 붕어빵뺄때, 뒤집을때 bakingList[index] == .overCook이면 점수를 -10점
 
 붕어빵을 뺄때
 - rare나 medium으로 붕어빵이 잘안익으면 5점
 - 두 면다 welldone으로 잘익으면 10점
 
 ex) 고객이 팥x3 바닐라x1을 달라고한다.
 
 A -> 5초를 기다리고 isThread가 false인지 체크해서 false면 멈춰
 
 
 붕어빵을 뺄때 isThread = false
 A가 5초를 기다리는 사이에 isThread = true B라는 Thread를 만듬
 A는 isThread가 true기 때문에 안멈춤
 B도 돌아가
 A랑 B가 동시에돌아가
 
 
 
 A : isThread = true, id = 1 xxxx
 
 B : isThread = true, id = 2 oooo
 
 
 
 */


/*
 
 손님이 정확한 수의 팥, 크림 붕어빵을 받았을때 30점
 아니면 -10
 
 
 팥3개, 크림2개
 
 var customerPod = 3
 var customerVanila = 2
 
 
 
 */

enum Baking: Int {
    case mold = 0
    case rare = 1
    case medium = 2
    case wellDone = 3
    case overCook = 4
}

enum Pod: Int {
    case none = 0
    case cream = 1
    case eye = 2
}

class GameViewController: UIViewController {
    
    var isPlaying = false // 게임이 실행되고있는지 여부
    var id = 0
    var ids = [0, 0, 0, 0, 0, 0, 0, 0, 0]
    var bakingList: [Baking] = [.mold, .mold, .mold, .mold, .mold, .mold, .mold, .mold, .mold] // 현재 그릴 상태
    var isThread = [false, false, false, false, false, false, false, false, false]  // thread가 돌고있는지에 대한 여부
    var isPod = [false, false, false, false, false, false, false, false, false]  // 팥이 들어있는지 여부
    var isOver = [false, false, false, false, false, false, false, false, false]  // 뒤집었는지 여부
    var isPodOrVanila = [true, true, true, true, true, true, true, true, true] // true면 팥, false면 바닐라
    var isWellDone = [0, 0, 0, 0, 0, 0, 0, 0, 0]  // 잘 익었는지 여부: 0이면 rare나 medium, 1이면 welldone, 2면 overcook
    var isPodBottle = true // true면 팥, false면 바닐라
    var score = 0 {
        didSet {    // 해당 변수가 값이 변하면 didSet code 실행
            
            DispatchQueue.main.async {
                self.scoreLabel.text = "Score : \(self.score)"
            }
        }
    }
    //    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
    //      // 1초 후 실행될 부분
    //    }
    
    // 손님이 현재 받은 팥붕어빵과 바닐라 붕어빵
    var customerPod = 0 {
        didSet {
            DispatchQueue.main.async {
                self.customerPodLabel.text = "팥 : \(self.customerPod)개, 크림 : \(self.customerVanila)개"
            }
//            if timer == 0{
//                customerPod = 0
//            }
        }
    }
    var customerVanila = 0 {
        didSet {
            DispatchQueue.main.async {
                self.customerPodLabel.text = "팥 : \(self.customerPod)개, 크림 : \(self.customerVanila)개"
            }
//            if timer == 0{
//                customerVanila = 0
//            }
        }
    }
    private func changeCustomer() {
        self.order = (Int.random(in: 1..<3), Int.random(in: 1..<3))
    }
    var order: (Int, Int) = (Int.random(in: 1..<3), Int.random(in: 1..<3)){
        didSet {
            DispatchQueue.main.async{
               
                self.orderLabel.text = "사장님! 팥\(self.order.0)이랑 크림\(self.order.1)개 주세요"
                self.customerPod = 0
                self.customerVanila = 0
                
            }
        }
    }
    
    @IBOutlet weak var timerLabel: UILabel!
    
    @IBOutlet weak var orderLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    
    @IBOutlet weak var grillImage1: UIImageView!
    @IBOutlet weak var grillPodImage1: UIImageView!
    
    @IBOutlet weak var grillImage2: UIImageView!
    @IBOutlet weak var grillPodImage2: UIImageView!
    
    @IBOutlet weak var grillImage3: UIImageView!
    @IBOutlet weak var grillPodImage3: UIImageView!
    
    @IBOutlet weak var grillImage4: UIImageView!
    @IBOutlet weak var grillPodImage4: UIImageView!
    
    @IBOutlet weak var grillImage5: UIImageView!
    @IBOutlet weak var grillPodImage5: UIImageView!
    
    @IBOutlet weak var grillImage6: UIImageView!
    @IBOutlet weak var grillPodImage6: UIImageView!
    
    @IBOutlet weak var grillImage7: UIImageView!
    @IBOutlet weak var grillPodImage7: UIImageView!
    
    @IBOutlet weak var grillImage8: UIImageView!
    @IBOutlet weak var grillPodImage8: UIImageView!
    
    @IBOutlet weak var grillImage9: UIImageView!
    @IBOutlet weak var grillPodImage9: UIImageView!
    
    @IBOutlet weak var podBottleImage: UIImageView!
    @IBOutlet weak var vanilaBottleImage: UIImageView!
    @IBOutlet weak var podBottleContainer: UIControl!
    @IBOutlet weak var vanilaBottleContainer: UIControl!
    
    @IBOutlet weak var customerPodLabel: UILabel!
    
    override func viewDidLoad() {
        
    }
    //MARK: - timer
    
    var timer = 20 {
        didSet{ // runloop
            DispatchQueue.main.async {
                self.timerLabel.text = "남은시간 : \(self.timer)"
                if self.timer == 0{
                    self.isPlaying = false
                    self.allReset()
                    self.timer = 20
                    let optionVC = GameOverViewController(score: self.score)
                    //                    let optionVC = self.storyboard?.instantiateViewController(withIdentifier: "GameOverViewController")
                    self.present(optionVC , animated: true)
                }
            }
        }
    }
    //MARK: - gameStart
    @IBAction func gameStart(_ sender: Any){
        isPlaying = true
        DispatchQueue.global().async {
            while(self.timer > 0) {
                Thread.sleep(forTimeInterval: 1)
                self.timer-=1
            }
        }
        DispatchQueue.main.async {
            self.orderLabel.text = "사장님! 팥\(self.order.0)개랑 크림\(self.order.1)개 주세요"
        }
        score = 0
    }
    
    @IBAction func podBottleAction(_ sender: Any) {
        DispatchQueue.main.async {
            self.isPodBottle = true
            self.podBottleContainer.backgroundColor = .systemBrown
            self.vanilaBottleContainer.backgroundColor = .clear
        }
    }
    
    @IBAction func vanilaBottleAction(_ sender: Any) {
        DispatchQueue.main.async {
            self.isPodBottle = false
            self.podBottleContainer.backgroundColor = .clear
            self.vanilaBottleContainer.backgroundColor = .systemBrown
        }
    }
    
    /*
     0 1 2
     3 4 5
     6 7 8
     */
    
    @IBAction func grill1Action(_ sender: Any) {
        grillAction(index: 0)
        
    }
    
    @IBAction func grill2Action(_ sender: Any) {
        grillAction(index: 1)
    }
    
    @IBAction func grill3Action(_ sender: Any) {
        grillAction(index: 2)
    }
    
    @IBAction func grill4Action(_ sender: Any) {
        grillAction(index: 3)
    }
    
    @IBAction func grill5Action(_ sender: Any) {
        grillAction(index: 4)
    }
    
    @IBAction func grill6Action(_ sender: Any) {
        grillAction(index: 5)
    }
    
    @IBAction func grill7Action(_ sender: Any) {
        grillAction(index: 6)
    }
    
    @IBAction func grill8Action(_ sender: Any) {
        grillAction(index: 7)
    }
    
    @IBAction func grill9Action(_ sender: Any) {
        grillAction(index: 8)
    }
    
    private func allReset() {
        for i in 0..<9 {
            self.reset(index: i)
        }
    }
    
    private func grillAction(index: Int) {
        if isPlaying == false {
            return
        }
        if bakingList[index] == .mold {
            id += 1
            ids[index] = id
            print("\(id),\(ids)")
            changeGrillImage(index: index, baking: .rare)
            DispatchQueue.global().async {
                let currentId = self.ids[index]
                self.isThread[index] = true
                while(self.isThread[index] == true && currentId == self.ids[index]) {
                    Thread.sleep(forTimeInterval: 3)
                    if (self.isThread[index] == true && currentId == self.ids[index]) {
                        if self.bakingList[index] != .overCook {
                            self.changeGrillImage(index: index, baking: Baking(rawValue: self.bakingList[index].rawValue + 1) ?? .mold)
                        }
                    }
                }
            }
        } else {
            if (isPod[index] == false) {    // 팥 넣기
                putPod(index: index)
            } else if (isOver[index] == false) {    // 뒤집기
                overBread(index: index)
            } else {    // 붕어빵빼기
                score += calculateScore(index: index)
                score += calculateCustomerBread(index: index)
                reset(index: index)
            }
        }
    }
    //MARK: - calculateScore
    private func calculateScore(index: Int) -> Int {
        if bakingList[index] == .overCook {
            return -10
        } else if isWellDone[index] == 2 {
            return -10
        } else if bakingList[index] == .wellDone && isWellDone[index] == 1 {
            return 10
        } else {
            return 5
        }
        
    }
    //MARK: - cal
    
    private func calculateCustomerBread(index: Int) -> Int {
        if isPodOrVanila[index] {
            customerPod += 1
        } else{
            customerVanila += 1
        }
        
        if order.0 < customerPod || order.1 < customerVanila {
            changeCustomer()
            return -20
        } else if order.0 == customerPod && order.1 == customerVanila {
            changeCustomer()
            return 30
        } else {
            return 0
        }
    }
    
  
    //MARK: - reset
    private func reset(index: Int) {
        changeGrillImage(index: index, baking: .mold)
        changeGrillPodImage(index: index, pod: .none, podOrVanila: true)
        isThread[index] = false
        isPod[index] = false
        isOver[index] = false
        isWellDone[index] = 0
        orderLabel.text = ""
        scoreLabel.text = "Score : 0"
        customerPodLabel.text = "팥 :0개, 크림 : 0개"
//        score = 0
//        customerPod = 0
//        customerVanila = 0
        
    }
    
    private func putPod(index: Int) {
        isPod[index] = true
        if isPodBottle {
            isPodOrVanila[index] = true
        } else {
            isPodOrVanila[index] = false
        }
        changeGrillPodImage(index: index, pod: .cream, podOrVanila: isPodOrVanila[index])
    }
    
    private func overBread(index: Int) {
        if bakingList[index] == .wellDone {
            isWellDone[index] = 1
        } else if bakingList[index] == .overCook {
            isWellDone[index] = 2
        } else if bakingList[index] == .rare{
            isWellDone[index] = 3
        }else {
            isWellDone[index] = 0
        }
        isOver[index] = true
        changeGrillPodImage(index: index, pod: .eye, podOrVanila: isPodOrVanila[index])
        changeGrillImage(index: index, baking: .rare)
    }
    
    private func changeGrillImage(index: Int, baking: Baking) {
        // DispatchQueue.main.async = 메인쓰레드위에서 코드를 돌리겠다(UI변경은 무조건 여기서)
        DispatchQueue.main.async {
            var image: UIImage?
            switch baking {
            case .mold: image = UIImage(named: "mold")
            case .rare: image = UIImage(named: "rare")
            case .medium: image = UIImage(named: "medium")
            case .wellDone: image = UIImage(named: "well_done")
            case .overCook: image = UIImage(named: "overcooked")
            }
            self.bakingList[index] = baking
            
            switch index {
            case 0: self.grillImage1.image = image
            case 1: self.grillImage2.image = image
            case 2: self.grillImage3.image = image
            case 3: self.grillImage4.image = image
            case 4: self.grillImage5.image = image
            case 5: self.grillImage6.image = image
            case 6: self.grillImage7.image = image
            case 7: self.grillImage8.image = image
            case 8: self.grillImage9.image = image
            default: break
            }
        }
    }
    
    private func changeGrillPodImage(index: Int, pod: Pod, podOrVanila: Bool) {
        var image: UIImage?
        switch pod {
        case .none: image = UIImage()
        case .cream: image = podOrVanila == true ? UIImage(named: "red_bean_cream") : UIImage(named: "chou_cream")  // 삼항연산자
        case .eye: image = podOrVanila == true ? UIImage(named: "red_bean_point") : UIImage(named: "chou_point")
        }
        
        switch index {
        case 0: self.grillPodImage1.image = image
        case 1: self.grillPodImage2.image = image
        case 2: self.grillPodImage3.image = image
        case 3: self.grillPodImage4.image = image
        case 4: self.grillPodImage5.image = image
        case 5: self.grillPodImage6.image = image
        case 6: self.grillPodImage7.image = image
        case 7: self.grillPodImage8.image = image
        case 8: self.grillPodImage9.image = image
        default: break
        }
    }
}

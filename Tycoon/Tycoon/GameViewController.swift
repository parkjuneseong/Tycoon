//
//  MainViewController.swift
//  Tycoon
//
//  Created by 이청원 on 2023/02/12.
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
    
    @IBOutlet weak var scoreLabel: UILabel!
    
    @IBOutlet weak var grillImage1: UIImageView!
    @IBOutlet weak var grillPodImage1: UIImageView!
    @IBOutlet weak var grillImage2: UIImageView!
    @IBOutlet weak var grillPodImage2: UIImageView!
    
    @IBOutlet weak var podBottleImage: UIImageView!
    @IBOutlet weak var vanilaBottleImage: UIImageView!
    @IBOutlet weak var podBottleContainer: UIControl!
    @IBOutlet weak var vanilaBottleContainer: UIControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    @IBAction func podBottleAction(_ sender: Any) {
        DispatchQueue.main.async {
            self.isPodBottle = true
            self.podBottleContainer.backgroundColor = .systemBlue
            self.vanilaBottleContainer.backgroundColor = .clear
        }
    }
    
    @IBAction func vanilaBottleAction(_ sender: Any) {
        DispatchQueue.main.async {
            self.isPodBottle = false
            self.podBottleContainer.backgroundColor = .clear
            self.vanilaBottleContainer.backgroundColor = .systemBlue
        }
    }
    
    @IBAction func grill1Action(_ sender: Any) {
        grillAction(index: 0)
    }
    
    @IBAction func grill2Action(_ sender: Any) {
        grillAction(index: 1)
    }
    
    private func grillAction(index: Int) {
        if bakingList[index] == .mold {
            id += 1
            ids[index] = id
            changeGrillImage(index: index, baking: .rare)
            // DispatchQueue.global().async = 새로운 쓰레드를 만들어서 그 안에서 코드를 돌리겠다
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
                reset(index: index)
            }
        }
    }
    
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
    
    private func reset(index: Int) {
        changeGrillImage(index: index, baking: .mold)
        changeGrillPodImage(index: index, pod: .none, podOrVanila: true)
        isThread[index] = false
        isPod[index] = false
        isOver[index] = false
        isWellDone[index] = 0
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
        } else {
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
        default: break
        }
    }
}

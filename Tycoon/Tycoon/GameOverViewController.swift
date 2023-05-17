//
//  GameOverViewController.swift
//  Tycoon
//
//  Created by 박준성 on 2023/02/12.
//

import UIKit

class GameOverViewController: UIViewController {

    
    @IBOutlet weak var gameOverScore: UILabel!
    
    
    @IBOutlet weak var reStartButton: UIControl!
    
    
    var score : Int
    init(score: Int) {
        self.score = score
        super.init(nibName: "\(GameOverViewController.self)", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gameOverScore.text = "Score : \(score)!!"
    
    }

    @IBAction func reStartBtnAction(_ sender: Any) {
        print("사라지기")
      dismiss(animated: true)
        
    }
    
// rootViewController는 하나밖에 못쓰는지 ?

}

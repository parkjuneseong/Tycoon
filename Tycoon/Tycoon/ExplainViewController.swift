//
//  ExplainViewController.swift
//  Tycoon
//
//  Created by 박준성 on 2023/02/12.
//

import UIKit

class ExplainViewController: UIViewController {
 
    
    @IBOutlet weak var gameStartImage: UIImageView!
    @IBOutlet weak var optionImage: UIImageView!
    
    @IBAction func startButtonAction(_ sender: Any) {
        print("Game 하는 View")
        let vc = GameViewController()
        self.navigationController?.pushViewController(vc, animated: false)
        
    }
    
    
    @IBAction func optionButtonAction(_ sender: Any) {
        print("옵션 프레젠트 View")
        let optionVC = self.storyboard?.instantiateViewController(withIdentifier: "RuleViewController")
        self.present(optionVC ?? RuleViewController(), animated: true)
    }
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let backButton = UIBarButtonItem(title: "게임종료", style: .done, target: self, action: nil)
        backButton.tintColor = .black
        self.navigationItem.backBarButtonItem = backButton
        
        
    }

    
    

}

//
//  SliderMenuViewController.swift
//  Pothole Detector
//
//  Created by Tega Adigu on 05/12/2018.
//  Copyright © 2018 Tega Adigu. All rights reserved.
//

import UIKit
protocol SlideMenuDelegate {
    func slideMenuItemSelectedAtIndex(_ index: Int32);
}

class MenuViewController: UIViewController {
    
    var btnMenu : UIButton!
    var delegate : SlideMenuDelegate?
    @IBOutlet weak var btnCloseOverlay: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // ON Navigate to Dashboard screen
    @IBAction func btnDashboardTapped(_ sender: UIButton) {
        let mainStoryBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let destinationView = mainStoryBoard.instantiateViewController(withIdentifier: "DashboardViewController") as! DashboardViewController
        self.navigationController?.pushViewController(destinationView, animated: true)
    }
    
    @IBAction func btnNeighborhoodScoreTapped(_ sender: UIButton) {
        let mainStoryBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let destinationView = mainStoryBoard.instantiateViewController(withIdentifier: "NeighborhoodScoreViewController") as! NeighborhoodScoreViewController
        self.navigationController?.pushViewController(destinationView, animated: true)
    }
    
    @IBAction func btnCloseMenuOverlay(_ sender: UIButton) {
        btnMenu.tag = 0
        btnMenu.isHidden = false
        if(self.delegate != nil) {
            var index = Int32(sender.tag)
            if(sender == self.btnCloseOverlay) {
                index = -1;
            }
            delegate?.slideMenuItemSelectedAtIndex(index)
        }
        
        UIView.animate(withDuration: 0.3, animations: {() -> Void in
            self.view.frame = CGRect(x: -UIScreen.main.bounds.size.width, y:0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
            self.view.layoutIfNeeded()
            self.view.backgroundColor = UIColor.clear
        }, completion: {(finished) -> Void in
            self.view.removeFromSuperview()
            self.removeFromParent()
        })
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

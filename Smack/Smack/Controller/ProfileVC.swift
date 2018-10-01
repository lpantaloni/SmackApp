//
//  ProfileVC.swift
//  Smack
//
//  Created by Laurent Pantaloni on 29/09/2018.
//  Copyright © 2018 Laurent Pantaloni. All rights reserved.
//

import UIKit

class ProfileVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if AuthService.instance.isLoggedIn {
            setupView()
        } else {
            userName.text = "Not Logged In"
            userEmail.text = "Not Logged In"
        }
        

        // Do any additional setup after loading the view.
    }

    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userEmail: UILabel!
    @IBOutlet weak var bgView: UIView!
    
    
    @IBAction func closBtnPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func logoutBtnPressed(_ sender: Any) {
        UserDataService.instance.logoutUser()
        NotificationCenter.default.post(name: NOTIF_USER_DATA_DID_CHANGE, object: nil)
        dismiss(animated: true, completion: nil)
    }
    
    func setupView() {
        let userProfile = UserDataService.instance
        userName.text = userProfile.name
        userEmail.text = userProfile.email

        let profileImage = UIImage(named: userProfile.avatarName)
        if profileImage != nil {
            profileImg.image = profileImage
            profileImg.backgroundColor =    UserDataService.instance.returnUIColor(components: UserDataService.instance.avatarColor)
        }
        
        let closeTouch = UITapGestureRecognizer(target: self, action: #selector(ProfileVC.closTap(_:)))
        bgView.addGestureRecognizer(closeTouch)
    }
    
    @objc func closTap(_ recognizer: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
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

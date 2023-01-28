//
//  ResetViewController.swift
//  glow
//
//  Created by devStar on 1/30/22.
//  Copyright © 2022 Dreams. All rights reserved.
//

import UIKit

class ResetViewController: UIViewController {

    // MARK: - Outlet
    
    @IBOutlet weak var emailField: UITextField!
    
    
    // MARK: - Outet Action
    
    @IBAction func onPressReset(_ sender: Any) {
        if let email = emailField.text, !email.isEmpty {
            let param = ["email": email]
            Utility.showProgress()
            AuthRequest.resetPassword(param: param, callback: { status, error in
                Utility.dismissProgress()
                if error == nil, status {
                    Utility.alert(message: "otpコードを送信しました。")
                } else {
                    Utility.alert(message: "メールアドレスが見付かれません。")
                }
            })
        }
    }
    
    @IBAction func onPressLogin(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Static
    
    static func getInstance() -> ResetViewController {
        let viewController = Constants.Storyboard.LOGIN.instantiateViewController(withIdentifier: "ResetViewController") as! ResetViewController
        return viewController
    }

}

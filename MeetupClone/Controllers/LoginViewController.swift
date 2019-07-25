//
//  LoginViewController.swift
//  MeetupClone
//
//  Created by Ashli Rankin on 7/16/19.
//  Copyright © 2019 Lickability. All rights reserved.
//

import UIKit

/// Allows the user to authenticate their account with meetup.
class LoginViewController: UIViewController {
    
    var meetupAuthenticationHandler: MeetupAuthenticationHandler?
    
    @IBAction private func loginButtonPressed(_ sender: UIButton) {
        initiateLoginFlow()
    }
    
    private func setUpAlertController() {
        let alertController = UIAlertController(title: NSLocalizedString("Error", comment: "Error occured"), message: NSLocalizedString("Could not authenticate you account try again.", comment: "Tell the user the was a problem signing them in."), preferredStyle: .alert)
        let tryAgainAction = UIAlertAction(title: "TryAgain", style: .default) { _ in
            self.meetupAuthenticationHandler?.startAuthorizationLogin()
        }
        alertController.addAction(tryAgainAction)
    }
    
    private func initiateLoginFlow() {
        guard let meetupAuthenticationHandler = meetupAuthenticationHandler else {
            assertionFailure("The meetupAuthenticationHandler is nil")
            return }
        if !meetupAuthenticationHandler.hasOAuthToken() {
            meetupAuthenticationHandler.oAuthTokenCompletionHandler = { error in
                if error != nil {
                    self.setUpAlertController()
                } else {
                    self.presentsUserInterfaceOnSuccess()
                }
            }
            meetupAuthenticationHandler.startAuthorizationLogin()
        }
    }
    
    private func presentsUserInterfaceOnSuccess() {
        guard let interfaceController = UIStoryboard(name: "MeetupInfoInterface", bundle: nil).instantiateViewController(withIdentifier: "MeetupInfoTabbarController") as? UITabBarController else {
            return }
        interfaceController.modalTransitionStyle = .crossDissolve
        present(interfaceController, animated: true, completion: nil)
    }
}

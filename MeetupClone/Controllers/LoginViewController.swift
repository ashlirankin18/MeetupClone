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
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction private func loginButtonPressed(_ sender: UIButton) {
        initiateLoginFlow()
    }
    
    @IBOutlet private weak var loginButton: RoundedButton!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startPulseAnimation()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        loginButton.layer.removeAnimation(forKey: "layerAnimation")
    }
    
    private func presentAlertController() {
        let alertController = UIAlertController(title: NSLocalizedString("Error", comment: "Error occured"), message: NSLocalizedString("Could not authenticate you account try again.", comment: "Tells the user there was a problem signing them in."), preferredStyle: .alert)
        let tryAgainAction = UIAlertAction(title: NSLocalizedString("Try Again", comment: "Prompts the user to try thier request again"), style: .default) { [weak self] _ in
            guard let self = self else {
                return
            }
            self.meetupAuthenticationHandler?.startAuthorizationLogin()
        }
        alertController.addAction(tryAgainAction)
        present(alertController, animated: true, completion: nil)
    }
    private func startPulseAnimation() {
        let pulseAnimation: CABasicAnimation = CABasicAnimation(keyPath: "transform.scale")
        pulseAnimation.duration = 2.0
        pulseAnimation.toValue = NSNumber(value: 0.9)
        pulseAnimation.fromValue = NSNumber(value: 1.0)
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .greatestFiniteMagnitude
        pulseAnimation.isRemovedOnCompletion = false
        loginButton.layer.add(pulseAnimation, forKey: "layerAnimation")
    }
    private func initiateLoginFlow() {
        guard let meetupAuthenticationHandler = meetupAuthenticationHandler else {
            assertionFailure("The meetupAuthenticationHandler is nil")
            return }
        if !meetupAuthenticationHandler.hasOAuthToken() {
            meetupAuthenticationHandler.oAuthTokenCompletionHandler = { [weak self] error in
                guard let self = self else {
                    return
                }
                if error != nil {
                    self.presentAlertController()
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

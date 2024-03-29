//
//  UserProfileDataSource.swift
//  MeetupClone
//
//  Created by Ashli Rankin on 7/24/19.
//  Copyright © 2019 Lickability. All rights reserved.
//

import UIKit

/// Represents the dataSource used to configure the tableView in the ProfileViewController 
final class UserProfileDataSource: NSObject, UITableViewDataSource {
    
    /// The model representing a user object
    var meetupUserModel: MeetupUserModel?
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 0 :
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "UserNameCell")  as? UserNameTableViewCell else {
                    assertionFailure("Could not load nib")
                    return UITableViewCell()
            }
            guard let meetupUserModel = meetupUserModel else {
                return UITableViewCell()
            }
            cell.viewModel = UserNameTableViewCell.ViewModel(userName: meetupUserModel.name)
            return cell
            
        default:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "UserBioCell") as? UserBioTableViewCell else {
                return UITableViewCell()
            }
            guard let meetupUserModel = meetupUserModel else {
                return UITableViewCell()
            }
            cell.viewModel = UserBioTableViewCell.ViewModel(bio: meetupUserModel.bio)
            return cell
        }
    }
}

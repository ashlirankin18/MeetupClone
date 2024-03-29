//
//  MeetupDataHandler.swift
//  MeetupClone
//
//  Created by Ashli Rankin on 7/22/19.
//  Copyright © 2019 Lickability. All rights reserved.
//

import Foundation

/// Handles the methods that will request data from  the server.
class MeetupDataHandler {
    
    private var networkHelper: NetworkHelper
    
    private let accessToken: String?
    
    /// Initializes the class with networkHelper.
    init(networkHelper: NetworkHelper, preferences: Preferences) {
        self.networkHelper = networkHelper
        self.accessToken = preferences.accessToken
    }
    
    /// Represent the types that are expected to escape when the asynchrnous func completes.
    typealias UserHandler = (Result<MeetupUserModel, AppError>) -> Void
    
    /// Represent the types that are expected to escape when the asynchrnous func completes.
    typealias GroupHandler = (Result<[MeetupGroupModel], AppError>) -> Void
    
    /// Represent the types that are expected to escape when the asynchrnous func completes.
    typealias EventHandler = (Result<[MeetupEventModel], AppError>) -> Void
    
    ///  Represent the types that are expected to escape when the asynchrnous func completes.
    typealias RSVPHandler = (Result<[MeetupRSVPModel], AppError>) -> Void
    
    /// Retrieves the user data from the server.
    /// - Parameter completionHandler: receives information (expected type) when asynchronous call completes.
  @discardableResult func retrieveUserData(completionHandler: @escaping UserHandler) -> Cancelable? {
        let urlString = "https://api.meetup.com/2/member/self"
        let dataTask = genericRetrievalFunc(urlString: urlString) { (results: Result<MeetupUserModel, AppError>) in
            switch results {
            case .failure(let error):
                completionHandler(.failure(.networkError(error)))
                return
            case .success(let user):
                completionHandler(.success(user))
                return
            }
        }
        return dataTask
    }
    
    /// Retrives groups from the server.
    ///
    /// - Parameters:
    ///   - zipCode: User provided zipcode. If there is not zipcode meetup provides similar groupos based on the location that was given when the account was created
    ///   - completionHandler: receives information (expected type) when asynchronous call completes.
    func retrieveMeetupGroups(searchText: String?, zipCode: String?, completionHandler: @escaping GroupHandler) -> Cancelable? {
        
        guard let urlString = checksQureyParameters(searchText: searchText, zipCode: zipCode)?.absoluteString else {
            return nil
        }
        let dataTask = genericRetrievalFunc(urlString: urlString) { (results: Result<[MeetupGroupModel], AppError>) in
            switch results {
            case .failure(let error):
                completionHandler(.failure(.networkError(error)))
                return
            case .success(let groups):
                completionHandler(.success(groups))
                return
            }
        }
        return dataTask
    }
    
    /// Retrives events from the server based the groups urlname
    ///
    /// - Parameters:
    ///   - groupURLName: The URLName of the group
    ///   - completionHandler: receives information (expected type) when asynchronous call completes.
    @discardableResult func retrieveEvents(with groupURLName: String, completionHandler: @escaping EventHandler) -> Cancelable? {
        let urlString = "https://api.meetup.com/\(groupURLName)/events?&sign=true&photo-host=public&page=20"
        let dataTask = genericRetrievalFunc(urlString: urlString) { (results: Result<[MeetupEventModel], AppError>) in
            
            switch results {
            case .failure(let error):
                completionHandler(.failure(.networkError(error)))
                return
            case .success(let events):
                completionHandler(.success(events))
                return
            }
        }
        return dataTask
    }
    
    /// Retrieves RSVP'S from the server based on the eventID and eventURLName
    ///
    /// - Parameters:
    ///   - eventId: The eventId of a chosen even.
    ///   - eventURLName: The event URL name.
    ///   - completionHandler: receives information (expected type) when asynchronous call completes
    @discardableResult  func retrieveEventRSVP(eventId: String, eventURLName: String, completionHandler: @escaping RSVPHandler ) -> Cancelable? {
        let urlString = "https://api.meetup.com/\(eventURLName)/events/\(eventId)/rsvps?&sign=true&photo-host=public"
        let dataTask = genericRetrievalFunc(urlString: urlString) { (results: Result<[MeetupRSVPModel], AppError>) in
            switch results {
            case .failure(let error):
                completionHandler(.failure(.networkError(error)))
                return
            case .success(let rsvps):
                completionHandler(.success(rsvps))
                return
            }
        }
        return dataTask
    }
    
    private func genericRetrievalFunc<T: Codable>(urlString: String, completion: @escaping (Result<T, AppError>) -> Void) -> Cancelable? {
        guard let accessCode = accessToken else { assertionFailure("AccessToken maybe nil")
            return nil}
        let bearer = ("Bearer \(accessCode)", "Authorization")
        
        let task = networkHelper.performDataTask(URLEndpoint: urlString, httpMethod: .Get, httpBody: nil, httpHeader: bearer) { (results) in
            switch results {
            case .failure(let error):
                completion(.failure(.networkError(error)))
                return
            case .success(let data):
                do {
                    let jsonDecoder = JSONDecoder()
                    jsonDecoder.dateDecodingStrategy = .millisecondsSince1970
                    let object = try jsonDecoder.decode(T.self, from: data)
                    completion(.success(object))
                    return
                } catch {
                    completion(.failure(.decodingError("Could not decode type")))
                    return
                }
            }
        }
        return task
    }
    
    private func checksQureyParameters(searchText: String?, zipCode: String?) -> URL? {
        var component = URLComponents()
        component.scheme = "https"
        component.host = "api.meetup.com"
        component.path = "/find/groups?&sign=true&photo-host=public"
        let qureyItemOne = URLQueryItem(name: "zip", value: zipCode)
        let qureyItemTwo = URLQueryItem(name: "text", value: searchText)
        component.queryItems = [qureyItemOne, qureyItemTwo]
        return component.url
    }
}

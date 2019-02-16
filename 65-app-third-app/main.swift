//
//  main.swift
//  65-app-third-app
//
//  Created by Princess Max on 11.02.2019.
//  Copyright © 2019 Princess Max. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

public struct GithubUser {
    public let projectName : String
}
protocol JSONDecdable {
    init?(JSON:Any)
}
extension GithubUser : JSONDecdable{
   public init?(JSON: Any) {
        guard let JSON = JSON as? [String:Any] else { return nil}
        guard let project_name = JSON["full_name"] as? String else {return nil}
        self.projectName = project_name
    }
}
class DataProvider{
    var githubUsers = [GithubUser]()
    private func getUserAllRepositoryData(url:String, completion: @escaping ([GithubUser]) -> ()){
        Alamofire.request(url).responseJSON { (responseData) -> Void in
            if responseData.result.isFailure {
                print(responseData.result.error?.localizedDescription ?? "for some reason, data could not be obtained")
                completion(self.githubUsers)
            }
            if((responseData.result.value) != nil) {
                guard let swiftyJsonArray = responseData.result.value as? [[String : Any]] else {return}
                for swiftyJson in swiftyJsonArray{
                    guard let user = GithubUser(JSON: swiftyJson) else { return }
                    self.githubUsers.append(user)
                }
                completion(self.githubUsers)
            }
        }
    }
    func getUserDataAsync(url:String, completion: @escaping ([GithubUser]) -> ()){
        let dataLoaderQueue = DispatchQueue.global(qos: .background)
        dataLoaderQueue.async {
            self.getUserAllRepositoryData(url: url, completion: { [weak self] (users: [GithubUser]) in
                guard let self = self else { return }
                self.githubUsers = users
                DispatchQueue.main.async {
                    completion(self.githubUsers)
                }
            })
        }
    }
}

class App {
    var users: [GithubUser] = []
    func run(username: String){
        let url = "https://api.github.com/users/\(username)/repos"
        DataProvider().getUserDataAsync(url: url) { (users:[GithubUser]) in
            for user in users{
              print(user.projectName)
            }
        }
    }
}
print("enter user name")
if let username = readLine(){
    App().run(username: username)
}
RunLoop.main.run()








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

enum AppConstant {
    static let githubURL = "https://api.github.com"
}
public struct GithubUserProjectData {
    public let projectName : String
    public let projectId : Int
}

public class Datas {
    static var projects = [GithubUserProjectData]()
}
protocol JSONDecdable {
    init?(JSON:Any)
}
extension GithubUserProjectData : JSONDecdable{
   public init?(JSON: Any) {
        guard let JSON = JSON as? [String:Any] else { return nil}
        guard let project_name = JSON["full_name"] as? String else {return nil}
        guard let project_id = JSON["id"] as? Int else {return nil}
        self.projectName = project_name
        self.projectId = project_id
    }
}
class DataProvider{
    static func getUserAllRepositoryData(url:String, completion: @escaping () -> ()){
        var githubUsers = [GithubUserProjectData]()
        DispatchQueue.global(qos: .userInteractive).async{
            Alamofire.request(url).responseJSON { (responseData) -> Void in
                if responseData.result.isFailure {
                    print(responseData.result.error?.localizedDescription ?? "for some reason, data could not be obtained")
                }
                if((responseData.result.value) != nil) {
                    guard let swiftyJsonArray = responseData.result.value as? [[String : Any]] else {return}
                    for swiftyJson in swiftyJsonArray{
                        guard let user = GithubUserProjectData(JSON: swiftyJson) else { return }
                        githubUsers.append(user)
                    }
                    Datas.projects = githubUsers
                    DispatchQueue.main.async {
                        completion()
                    }
                }
            }
        }
    }
}

class App {
    func getTheUserProjectsInfo(username: String){
        let url = "\(AppConstant.githubURL)/users/\(username)/repos"
        DataProvider.getUserAllRepositoryData(url: url) {
            for project in Datas.projects{
              print(project.projectName)
            }
        }
    }
}
print("enter the user name")
if let username = readLine(){
    App().getTheUserProjectsInfo(username: username)
}
RunLoop.main.run()








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
//model received from the server with all the parameters
public struct GithubUserProjectData {
    public let projectName : String
    public let projectId : Int
    //other params
}
//model with only custom parameters to view
public struct Project {
    public let projectName : String
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
    var githubUsers = [GithubUserProjectData]()
    private func getUserAllRepositoryData(url:String, completion: @escaping ([GithubUserProjectData]) -> ()){
        Alamofire.request(url).responseJSON { (responseData) -> Void in
            if responseData.result.isFailure {
                print(responseData.result.error?.localizedDescription ?? "for some reason, data could not be obtained")
            }
            if((responseData.result.value) != nil) {
                guard let swiftyJsonArray = responseData.result.value as? [[String : Any]] else {return}
                for swiftyJson in swiftyJsonArray{
                    guard let user = GithubUserProjectData(JSON: swiftyJson) else { return }
                    self.githubUsers.append(user)
                }
                completion(self.githubUsers)
            }
        }
    }
    func getUserProjectsInfoAsync(url:String, completion: @escaping ([Project]) -> ()){
        let dataLoaderQueue = DispatchQueue.global(qos: .background)
        var projects = [Project]()
        dataLoaderQueue.async {
            self.getUserAllRepositoryData(url: url, completion: { [weak self] (users: [GithubUserProjectData]) in
                guard let self = self else { return }
                self.githubUsers = users
                for project in self.githubUsers{
                    projects.append(Project(projectName: project.projectName))
                }
                DispatchQueue.main.async {
                    completion(projects)
                }
            })
        }
    }
}

class App {
    func getTheUserProjectsInfo(username: String){
        let url = "\(AppConstant.githubURL)/users/\(username)/repos"
        DataProvider().getUserProjectsInfoAsync(url: url) { (projects:[Project]) in
            for project in projects{
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








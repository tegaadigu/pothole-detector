//
//  LoginViewController.swift
//  Pothole Detector
//
//  Created by Tega Adigu on 10/12/2018.
//  Copyright © 2018 Tega Adigu. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookLogin

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        if let savedUser = UserModel.loadUserLocally() {
            
            if savedUser.id != 0 {
                let userId = savedUser.id!
                print("saved user id")
                print(userId);
                self.navigateToDashboard(userId: userId)
            }
        }
    }
    

    @IBAction func loginBtnClicked(_ sender: UIButton) {
        let loginManager = LoginManager()
        loginManager.logIn(readPermissions: [ReadPermission.publicProfile, ReadPermission.email], viewController: self) { loginResult in
            switch loginResult {
            case .failed(let error):
                print("failed login request")
                print(error)
            case .cancelled:
                print("User cancelled login.")
            case .success(_ , _, _):
                self.requestUserInfo();
            }
        }
    }
    
    private func requestUserInfo() {
        let req = GraphRequest(graphPath: "me", parameters: ["fields":"email,name"], accessToken: AccessToken.current, httpMethod: .GET)
        req.start({(connection, result) in
            switch result {
            case .failed(let error):
                print(error)
            case .success(let graphResponse):
                if let data = graphResponse.dictionaryValue {
                    let email = data["email"] as? String
                    let name = data["name"] as? String;
                    var fullNameArr = name!.components(separatedBy: " ")
                    let firstName: String = fullNameArr[0]
                    let lastName: String = fullNameArr[1]
                    self.createUser(firstName: firstName, lastName: lastName, email: email!)
                }
            }
        })
    }
    
    //MARK: Create User and send to api endpoint
    private func createUser(firstName: String, lastName: String, email: String) {
        //store pothole to api endpoint
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "bmy2u2cwc4.execute-api.us-west-1.amazonaws.com"
        urlComponents.path = "/beta/user"
        guard let url = urlComponents.url else { fatalError("Could not create URL from components") }
        
        // Specify this request as being a POST method
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        // Make sure that we include headers specifying that our request's HTTP body
        // will be JSON encoded
        var headers = request.allHTTPHeaderFields ?? [:]
        headers["Content-Type"] = "application/json"
        request.allHTTPHeaderFields = headers
        
        // Now let's encode out Post struct into JSON data...
        let encoder = JSONEncoder()
        let dataToPost = PostUser(firstName: firstName, lastName: lastName, email: email);
        do {
            let jsonData = try encoder.encode(dataToPost)
            // ... and set our request's HTTP body
            request.httpBody = jsonData
            print("jsonData: ", String(data: request.httpBody!, encoding: .utf8) ?? "no body data")
        } catch {
            print("Couldnt encode to json")
        }
        
        // Create and run a URLSession data task with our JSON encoded POST request
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: request) { (responseData, response, responseError) in
            guard responseError == nil else {
                print("response error")
                return
            }
            // APIs usually respond with the data you just sent in your POST request
            if let data = responseData {
                guard let createdUser = try? JSONDecoder().decode(User.self, from: data) else {
                    print("Error couldnt decode")
                    return
                }
                print(createdUser)
                DispatchQueue.main.async {
                    let user = UserModel(id: createdUser.id, email: createdUser.email, firstName: createdUser.email, lastName: createdUser.lastName)
                    UserModel.storeUserLocally(user: user)
                    self.navigateToDashboard(userId: createdUser.id)
                }
            }
        }
        task.resume()
    }
    
    //Navigate to dashboard on successful user.
    private func navigateToDashboard(userId: Int) {
        let mainStoryBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let destinationView = mainStoryBoard.instantiateViewController(withIdentifier: "DashboardViewController") as! DashboardViewController
        destinationView.userId = userId;
        self.navigationController?.pushViewController(destinationView, animated: true)
    }
}

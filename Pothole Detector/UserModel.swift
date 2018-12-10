//
//  UserModel.swift
//  Pothole Detector
//
//  Created by Tega Adigu on 10/12/2018.
//  Copyright © 2018 Tega Adigu. All rights reserved.
//

import Foundation

class UserModel: NSObject, NSCoding {
    
    //MARK: Properties
    var id: Int?
    var firstName: String?
    var lastName: String?
    var email: String?
    
    struct PropertyKey {
        static let id = "0"
        static let firstName = "firstName"
        static let lastName = "lastName"
        static let email = "email"
    }
    
    //MARK: - Archiving Paths -
    // lookup the curent application's documents directory and create the file URL by appending meals to the end of the documents URL.
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("user")

    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(email, forKey: PropertyKey.email)
        aCoder.encode(id, forKey: PropertyKey.id)
        aCoder.encode(firstName, forKey: PropertyKey.firstName)
        aCoder.encode(lastName, forKey: PropertyKey.lastName)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let firstName = aDecoder.decodeObject(forKey: PropertyKey.firstName) as? String
        let lastName = aDecoder.decodeObject(forKey: PropertyKey.lastName) as? String
        let email = aDecoder.decodeObject(forKey: PropertyKey.email) as? String
        let id = aDecoder.decodeObject(forKey: PropertyKey.id) as? Int
        
        self.init(id: id, email: email, firstName: firstName, lastName: lastName);
    }
    
    init(id: Int?, email: String?, firstName: String?, lastName: String?) {
        self.id = id
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
    }
    
    static func storeUserLocally(user: UserModel) {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: user, requiringSecureCoding: false)
            try data.write(to: UserModel.ArchiveURL)
            print("User data successfully saved.")
        }   catch {
            fatalError("Error is saving meals data")
        }
    }
    
    static func loadUserLocally() -> UserModel? {
        do {
            let userDataToRead = try NSData(contentsOf: UserModel.ArchiveURL, options: .dataReadingMapped)
            let userData = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(Data(referencing: userDataToRead))
            print("User data successfully read.")
            let user = userData as? UserModel;
            return user
        } catch {
            print("Error in reading user data")
            return nil
        }
    }
}

//Struct for dataModel to store pot-hle
struct PostUser: Codable {
    let firstName: String
    let lastName: String
    let email: String
}

struct User: Decodable {
    let id: Int
    let firstName: String
    let lastName: String
    let email: String
}

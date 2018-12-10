//
//  SpeechTranslator.swift
//  Pothole Detector
//
//  Created by Tega Adigu on 09/12/2018.
//  Copyright © 2018 Tega Adigu. All rights reserved.
//

import Foundation

// Helper function to detected translated speech.
class SpeechTranslator {
    //MARK: check if speech text is Yes or No.
    static func isYes(text: String) -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: "yeah|yup|ya|yaa|yoo|yes", options: .caseInsensitive)
            
            let match = regex.matches(in: text, options: [], range: NSRange(location: 0, length: text.count))
            
            return match.count > 0 ? true : false

        }catch {
            return false
        }
    }
}

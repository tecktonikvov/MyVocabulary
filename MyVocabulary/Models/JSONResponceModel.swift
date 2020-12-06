//
//  JSONResponceModel.swift
//  MyVocabulary
//
//  Created by Mac on 26.11.2020.
//

import Foundation

struct Root: Codable {
    
    struct Translations: Codable {
        
        struct  TranslatedText: Codable {
            var detectedSourceLanguage: String
            var translatedText: String
        }
        var translations: ([TranslatedText])
    }
    let data: Translations
}

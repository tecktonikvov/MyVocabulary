import Foundation
import UIKit

struct JSONTranslator {

    enum TranslateResult<D>{
        case success(D)
        case failure(Error) // еррор это встроеный тип свифт по этому мы можем реализовать типы и описание ошибки протоколом LocalizedError используя enum
    }
    
    func getTranslate( _ word: String, completion: @escaping (TranslateResult<Any>) -> Void) {
        let bundleID = Bundle.main.bundleIdentifier! as String
        guard let url = URL(string: "https://translation.googleapis.com/language/translate/v2?key=AIzaSyDd_UnW6j0QoeTAXP2uFQg-E4lkRZBpUbk")
        else {
            completion(JSONTranslator.TranslateResult.failure(ErrorType.iputJSONSerialisedError))
            return }
        let parameters = ["q": word,
                          "target": "ru",
                          "format": "text"]
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(bundleID, forHTTPHeaderField: "X-Ios-Bundle-Identifier")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
        else {
            completion(JSONTranslator.TranslateResult.failure(ErrorType.outputJSONSerialisedError))
            return }
        request.httpBody = httpBody
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, responce, error) in
            guard responce != nil
            else {
                completion(JSONTranslator.TranslateResult.failure(ErrorType.responseError))
                return }
            
             if data != nil && error == nil {
                let decoder = JSONDecoder()
                
                do {
                    let translated = try decoder.decode(Root.self, from: data!)
                    let translatedText = translated.data.translations.first?.translatedText
                    completion(JSONTranslator.TranslateResult.success(translatedText!))
                } catch {
                    print(error)
                }
            }
        }.resume()
    }
}

//
//  ErrorType.swift
//  MyVocabulary
//
//  Created by Mac on 21.11.2020.
//

import Foundation

enum ErrorType {
    case iputJSONSerialisedError
    case outputJSONSerialisedError
    case responseError
    case noMatchesInResponse
    case noTranslatedWordInMatch
    case incorrectTranlate
    case translatedWordIsSame
}

// Типизируем енум до типа ошибки
extension ErrorType: LocalizedError { // протокол который предоставляет описание ошибок для базовго типа Еррор
    var errorDescription: String? {
        switch self {
        
        case .iputJSONSerialisedError:
            return NSLocalizedString("Ошибка сериализации JSON при получении", comment: "")
            
        case .outputJSONSerialisedError:
            return NSLocalizedString("Ошибка сериализации JSON при передаче", comment: "")

        case .responseError:
            return NSLocalizedString("Код ответа не 200", comment: "")

        case .noMatchesInResponse:
            return NSLocalizedString("Совпадения не найдено", comment: "")

        case .noTranslatedWordInMatch:
            return NSLocalizedString("В совпадении нет перевода", comment: "")

        case .incorrectTranlate:
            return NSLocalizedString("Перевод не корректен", comment: "")
            
        case .translatedWordIsSame:
            return NSLocalizedString("Один из совпадений есть переданое слово", comment: "")

        }
    }
}

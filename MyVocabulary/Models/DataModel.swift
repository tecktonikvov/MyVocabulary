//
//  DataModel.swift
//  MyVocabulary
//
//  Created by Mac on 26.11.2020.
//

import RealmSwift

class UserDataModel: Object {
    @objc dynamic var nameOfUserList = ""
    @objc dynamic var numberOfDuplet = 0
    @objc dynamic var dupletOfWords = ""
    @objc dynamic var numberofListInSection = 0

    static func getUserList() -> [String]{
        let realm = try! Realm()
        let objects = realm.objects(UserDataModel.self)
        
        var dictionary = [Int: String]()
        var userListNamesArray = [String]()
        
        for objOfUserData in objects {
            let indexOfList = objOfUserData["numberofListInSection"] as! Int
            let nameOfListFromObject = objOfUserData["nameOfUserList"] as! String
            dictionary[indexOfList] = nameOfListFromObject
            
        }
        let sortDictionary = dictionary.sorted( by: { $0.0 > $1.0 })// сортируем словарь по ключу
        for (_,v) in sortDictionary { // отделяем от сортированого словаря имена листов
            userListNamesArray.append(v)
        }
        return userListNamesArray.reversed()
    }
    
    
    static func getUserDuplets(userNamesOfLists: String) -> [[String: String]] {
        let realm = try! Realm()
        let objects = realm.objects(UserDataModel.self)
        var userDupletsFromListWithIndex = [Int: [String: String]]()
        var outputDict = [[String: String]]()

        for object in objects {
            if object["nameOfUserList"] as! String == userNamesOfLists {
                let indexOfDuplet = object["numberOfDuplet"] as! Int
                let userDupletString = object["dupletOfWords"] as! String
                print(userDupletString)
                
                if userDupletString != "" {
                    let wordsDoubleArr = userDupletString.components(separatedBy: " || ")
                    userDupletsFromListWithIndex[indexOfDuplet] =  [wordsDoubleArr[0]: wordsDoubleArr[1]]
                } 
            }
        }
        let sortedDict = userDupletsFromListWithIndex.sorted( by: { $0.0 > $1.0 })// сортируем словарь по ключу
        for (_, words) in sortedDict {
            for (engWord, ruWord) in words {
                outputDict.append([engWord: ruWord])
            }
        }
        return outputDict
    }
    
    static func prepareToSaveUserWords(dupletDict: [String: String]) -> String{
        var strToSave = String()
        for (k, v) in dupletDict{
            strToSave += k + " || " + v
        }
        return strToSave
    }
    
    static func prepareToShowUserWords(dupletString: String) -> [String: String] {
        var resultArray: [String: String] = [:]
        let wordsDoubleArr = dupletString.components(separatedBy: " || ")
        resultArray[wordsDoubleArr[0]] =  wordsDoubleArr[1]
    
        return resultArray
    }
    
    static func saveObject(saveObject: UserDataModel) {
        let saveObject = saveObject
        let realm = try! Realm()
        let objects = realm.objects(UserDataModel.self)
        var greatherNumberOfList = 0
        var greatherNumberOfDuplet = 0
        var mathIsFound = false
        
//Validation of number of duplet
        for obj in objects {
            if greatherNumberOfDuplet <= obj["numberOfDuplet"] as! Int {
                greatherNumberOfDuplet = obj["numberOfDuplet"] as! Int + 1
                saveObject["numberOfDuplet"] = greatherNumberOfDuplet
            }
        }
        
    //Validation of numberOfList - neded if we cahnge the number of List
        for objc in objects{
            if !mathIsFound{ // если совпадение не найдено
                if saveObject["nameOfUserList"] as! String == objc["nameOfUserList"] as! String {// если такой список уже есть
                    saveObject["numberofListInSection"] = objc["numberofListInSection"] // мемяем в сохраняемом обьекте индекс
                    StorageManager.saveObject(saveObject) // и сохраняем
                    mathIsFound = true // понятно
                } else { // если такого списка нет( новый список)
                    if greatherNumberOfList <= objc["numberofListInSection"] as! Int { // находим самый большой индекс из всех списков
                        greatherNumberOfList = objc["numberofListInSection"] as! Int + 1
                    }
                }
            }
        }
        if !mathIsFound {
            saveObject["numberofListInSection"] = greatherNumberOfList // присваиваем наибольший индекс новому списку
            StorageManager.saveObject(saveObject)
        }
    }
    
    
    static func deleteList(nameOfUserList: String){
        let realm = try! Realm()
        let objects = realm.objects(UserDataModel.self)
        
        for object in objects {
            if nameOfUserList == object["nameOfUserList"] as! String{
                StorageManager.deleteObject(object: object)
            }
        }
    }
    
    static func deleteWord(nameOfUserWord: [String: String], userListName: String){
        let realm = try! Realm()
        let objects = realm.objects(UserDataModel.self)
        let nameOfUserWord = prepareToSaveUserWords(dupletDict: nameOfUserWord)
        
        for object in objects {
            if userListName == object["nameOfUserList"] as! String && nameOfUserWord == object["dupletOfWords"] as! String {
                
                StorageManager.deleteObject(object: object)
            }
        }
    }
    
    static func updateListName(oldListName: String, newListName: String){
        let realm = try! Realm()
        let objects = realm.objects(UserDataModel.self)
        
        for object in objects {
            if oldListName == object["nameOfUserList"] as! String{
                StorageManager.updateNameOfList(object: object, newListName: newListName)
            }
        }
    }
    
    static func updateIndexOfLists(userNamesOfLists: [String]) {
        let realm = try! Realm()
        let objects = realm.objects(UserDataModel.self)
        
        var index = 0
        for userListName in userNamesOfLists{
            
            for object in objects {
                if object["nameOfUserList"] as! String == userListName {
                    StorageManager.updateIndexOfList(object: object, newListIndex: index)
                }
            }
            index = index + 1
        }
    }
    
    static func updateIndexOfDuplets(userNamesOfLists: String, wordsList: [[String: String]]) {
        let realm = try! Realm()
        let objects = realm.objects(UserDataModel.self)
        var index = 0
        
        for object in objects {                                  // берем каждый обьект из базы
            if object["nameOfUserList"] as! String == userNamesOfLists { // если имя листа обьекта и переданое имя листа совпадают
                for dupletDict in wordsList {                  //перебираем массив с парами слов в виде словаря
                    index = index + 1
                    let dupletString = self.prepareToSaveUserWords(dupletDict: dupletDict) //каждый словарь переводим в строку
                    if dupletString == object["dupletOfWords"] as! String {               // и сравниваем ее с свойтсвом обьекта
                        //object["numberOfDuplet"] = index
                        StorageManager.updateIndexOfDuplet(object: object, newDupletIndex: index)
                    }
                }
                index = 0
            }
        }
    }
    
    static func updateDupletTranslate(listName: String, oldDupletDict: [String: String], newTranslate: String){
        let realm = try! Realm()
        let objects = realm.objects(UserDataModel.self)
        let oldDupletString = UserDataModel.prepareToSaveUserWords(dupletDict: oldDupletDict)
        var newDupletDict = [String: String]()
        for object in objects{
            if object["nameOfUserList"] as! String == listName && object["dupletOfWords"] as! String == oldDupletString {
                let arr = (object["dupletOfWords"] as! String).components(separatedBy: " || ")
                newDupletDict[arr[0]] = newTranslate
                let resultStr = UserDataModel.prepareToSaveUserWords(dupletDict: newDupletDict)
                StorageManager.updateUserDuplet(object: object, newDupletOfWords: resultStr)
            }
        }
    }
    
    static func sortVocabByEng(array: [[String: String]]) -> [[String: String]] {
        var resultArrayOfDict = [[String: String]]()
        var dict = [String: String]()
        for dupletDict in array{
            for (k, v) in dupletDict {
                dict[k] = v
            }
        }
        
        let sortedDict = dict.sorted(by: { $0.0.uppercased() < $1.0.uppercased() })
        for (k, v) in sortedDict {
            resultArrayOfDict.append([k: v])
        }
        return resultArrayOfDict
        
    }
    
    static func sortVocabByRu(array: [[String: String]]) -> [[String: String]] {
        var resultArrayOfDict = [[String: String]]()
        var dict = [String: String]()
        for dupletDict in array{
            for (k, v) in dupletDict {
                dict[k] = v
            }
        }
        
        let sortedDict = dict.sorted( by: { $0.1.uppercased() < $1.1.uppercased() })
        print(sortedDict)
        for (k, v) in sortedDict {
            resultArrayOfDict.append([k: v])
        }
        return resultArrayOfDict
    }
}


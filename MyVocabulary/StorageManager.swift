//
//  StorageManager.swift
//  MyVocabulary
//
//  Created by Mac on 26.11.2020.
//

import RealmSwift

let realm = try! Realm()

class StorageManager {
    
    static func saveObject(_ dataModel: UserDataModel) {
            try! realm.write {
                realm.add(dataModel)
            }
    }
    
    static func deleteObject(object: UserDataModel){
            try! realm.write {
                realm.delete(object)
            }
    }
    
    static func updateNameOfList(object: UserDataModel, newListName: String){
            try! realm.write {
                object.nameOfUserList = newListName
            }
    }
    
    static func updateIndexOfList(object: UserDataModel, newListIndex: Int){
            try! realm.write {
                object.numberofListInSection = newListIndex
            }
    }
    
    static func updateIndexOfDuplet(object: UserDataModel, newDupletIndex: Int){
            try! realm.write {
                object.numberOfDuplet = newDupletIndex
            }
    }
    
    static func updateUserDuplet(object: UserDataModel, newDupletOfWords: String){
            try! realm.write {
                object.dupletOfWords = newDupletOfWords
            }
    }
}

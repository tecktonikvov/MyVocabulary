//
//  MainViewController.swift
//  MyVocabulary
//
//  Created by Mac on 15.11.2020.
//

import UIKit
import RealmSwift


class MainViewController: UIViewController, KeyboardDetect {

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addWordButton: UIBarButtonItem!
    @IBOutlet weak var editButtn: UIBarButtonItem!
    
    private var indexOfEditCell = 99999
    var nameOfSelectedList = String()
    private var wordToTranslate = String()
    private var vocabruary = [[String: String]]()
    private var searchIsActive = false
    private var isAddingNewWordBegin = false
    private var isEditingCellBegin = false
    private var keyboardIsActive = false
    private let translator = JSONTranslator()
    
    lazy var cancellButton: UIBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonItem.SystemItem.cancel, target: self, action: #selector(cancellFunc))
    lazy var addButton: UIBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addWordButtonAction))
    lazy var editButton: UIBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonItem.SystemItem.edit, target: self, action: #selector(editButtnAction))
    
    private var translatedText = String(){
        didSet {
            OperationQueue.main.addOperation { [self] in // OperationQueue.main.addOperation нужно потому что выкидывает ошибку что что то выполняется не в главном потоке
                vocabruary.remove(at: 0)                 // когда доступ к свойству уже был произведен из главного потока
                vocabruary.append([wordToTranslate: translatedText])
                vocabruary = vocabruary.reversed()
                tableView.reloadData()
                print(vocabruary)
                //Prepeare to save Object to Save()
                let objToSave = UserDataModel()
                objToSave.dupletOfWords = UserDataModel.prepareToSaveUserWords(dupletDict: vocabruary.first!)
                objToSave.nameOfUserList = nameOfSelectedList
                UserDataModel.saveObject(saveObject: objToSave)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        vocabruary = UserDataModel.getUserDuplets(userNamesOfLists: nameOfSelectedList)
        registerForKeyboardNotification()
    }
    
    deinit {
        removeKeyboardNotifications()
    }
    
    @IBAction func addWordButtonAction(_ sender: UIBarButtonItem) {
        indexOfEditCell = 0
        tableView.setContentOffset(.zero, animated: false)//Scroll to top of tableView
        vocabruary = vocabruary.reversed()
        vocabruary.append(["": ""])
        vocabruary = vocabruary.reversed()
        isAddingNewWordBegin = true
        //addWordButton.isEnabled = false
        tableView.reloadData()
        (tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! WordTableCell).wordEngTextField.becomeFirstResponder()
        navigationBar.rightBarButtonItems = [cancellButton]
        segmentedControl.isEnabled = false
    }
    
    @IBAction func editButtnAction(_ sender: UIBarButtonItem) {
        tableView.isEditing = !tableView.isEditing
        UserDataModel.updateIndexOfDuplets(userNamesOfLists: nameOfSelectedList, wordsList: vocabruary)
        if tableView.isEditing == true{
            navigationBar.rightBarButtonItems = [editButton]
            segmentedControl.isEnabled = false
            
        } else {
            navigationBar.rightBarButtonItems = [addButton, editButton]
            segmentedControl.isEnabled = true
        }
    }
    
    @IBAction func segmentedControllAction(_ sender: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            vocabruary = UserDataModel.getUserDuplets(userNamesOfLists: nameOfSelectedList)
            tableView.reloadData()
        case 1:
            vocabruary = UserDataModel.sortVocabByEng(array: vocabruary)
            tableView.reloadData()
        case 2:
            vocabruary = UserDataModel.sortVocabByRu(array: vocabruary)
            tableView.reloadData()
        default:
            return
        }
    }
    func fetchTranslate (_ word: String){
        translator.getTranslate(word) {[self] (result) in // Используем result для получения результата работы комплишн хендлнра
            switch result {
            case .success(let translatedText): // получили в перемнную translatedText данные из кейса
                self.translatedText = translatedText as! String
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    @objc func cancellFunc() {
        isEditingCellBegin = false
        navigationBar.rightBarButtonItems = [addButton, editButton]
        if isAddingNewWordBegin{
            vocabruary.remove(at: 0)
        }
        isAddingNewWordBegin = false
        keyboardIsActive = false
        segmentedControl.isEnabled = true
        (tableView.cellForRow(at: IndexPath(row: indexOfEditCell, section: 0)) as! WordTableCell).ruTextField.resignFirstResponder()
        tableView.reloadData()
    }
    
    func registerForKeyboardNotification(){
        //Отслеживание появления клавиатуры
        NotificationCenter.default.addObserver(self, selector: #selector(keybordWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        //Отслеживание скрытия клавиатуры
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func removeKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keybordWillShow(_ notification: Notification) {
        let userInfo = notification.userInfo
        let kbFrameSize = (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let kbFrameSizeInt = Int(kbFrameSize.height)
        let yPositionOfRow = Int((tableView.cellForRow(at: IndexPath(row: indexOfEditCell, section: 0))?.frame.minY)!)
        let viewFrameHeight = Int(self.tableView.frame.height)
        let rowIsUnderKeyboard: Bool = viewFrameHeight - (yPositionOfRow + 35) <= kbFrameSizeInt
            print("rowIsUnderKeyboard \(rowIsUnderKeyboard) :: isEditingCellBegin \(isEditingCellBegin) ")
        if isEditingCellBegin && rowIsUnderKeyboard {
            print("table Up")
            let kbFrameSize = (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue // получили значение фрейма клавиатуры
            tableView.contentOffset = CGPoint(x: 0, y: kbFrameSize.height)
            tableView.scrollToRow(at: IndexPath(row: indexOfEditCell, section: 0), at: .bottom, animated: true)
        }
    }
    
    @objc func keyboardWillHide(){
        tableView.contentOffset = CGPoint.zero
    }
    

//MARK: - SWIPE Actions
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        //Setup Delete Action
        let delete = UIContextualAction(style: .destructive, title: "Delete"){ [self] (action, view, completionHandler) in
            UserDataModel.deleteWord(nameOfUserWord: vocabruary[indexPath.row], userListName: nameOfSelectedList)
            vocabruary.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .left)
            completionHandler(true)
            tableView.reloadData()
        }
        
        //Setup Edit Action
        let edit = UIContextualAction(style: .normal, title: "Edit"){ [self] (action, view, completionHandler) in
            indexOfEditCell = indexPath.row
            navigationBar.rightBarButtonItems = [cancellButton]
            isEditingCellBegin = true
            completionHandler(true)
            print(indexOfEditCell)
            let editCell = tableView.cellForRow(at: IndexPath(row: indexOfEditCell, section: 0)) as! WordTableCell
            tableView.reloadRows(at: [indexPath], with: .right)
            segmentedControl.isEnabled = false
            //editCell.ruTextField.becomeFirstResponder()
        }
        
        let none = UISwipeActionsConfiguration(actions: [])
        let swipe = UISwipeActionsConfiguration(actions: [delete, edit])
        swipe.performsFirstActionWithFullSwipe = false
        
        if !keyboardIsActive {
            return swipe
        } else {
            return none
        }
    }
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    //MARK: - Table VIew data source
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        return CGFloat.leastNormalMagnitude // убирает блядский отступ в хедере тейбл вью
    }
    //Make disable delete button in isEditing mode
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        UITableViewCell.EditingStyle.none
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vocabruary.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! WordTableCell
        cell.wordEngTextField.isHidden = true
        cell.ruTextField.isHidden = true
        cell.engLabel.isHidden = false
        cell.ruLabel.isHidden = false
        
        let word = vocabruary[indexPath.row]
        for (key, value) in word {
            cell.engLabel.text = key
            cell.ruLabel.text = value
        }
        
        if isAddingNewWordBegin{
            if indexOfEditCell == indexPath.row {
                cell.wordEngTextField.isHidden = false
                cell.engLabel.isHidden = true
                cell.ruLabel.isHidden = true
                cell.wordEngTextField.text = ""
                cell.wordEngTextField.becomeFirstResponder()
            }
        }
        
        if isEditingCellBegin{
            if indexOfEditCell == indexPath.row {
                print("cell in edit mode index path: \(indexPath.row)")
                cell.ruLabel.isHidden = true
                cell.ruTextField.isHidden = false
                cell.ruTextField.text = cell.ruLabel.text
                cell.ruTextField.becomeFirstResponder()
            }
        }
        return cell
    }
    
    //MARK: - Override to support rearranging the table view.
    func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let elementToMove = vocabruary[fromIndexPath.row]
        vocabruary.remove(at: fromIndexPath.row)
        vocabruary.insert(elementToMove, at: to.row)
        print(vocabruary)
    }
    
    // Override to support conditional rearranging of the table view.
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    
}

extension MainViewController: UITextFieldDelegate {
    //MARK: - UITextField Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if isAddingNewWordBegin {
            wordToTranslate = (tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! WordTableCell).wordEngTextField.text!
            fetchTranslate(wordToTranslate)
            isAddingNewWordBegin = false
            segmentedControl.isEnabled = true
            navigationBar.rightBarButtonItems = [addButton, editButton]
        }
        
        if isEditingCellBegin {
            let oldTranslate = vocabruary[indexOfEditCell]
            let newTranslate = (tableView.cellForRow(at: IndexPath(row: indexOfEditCell, section: 0)) as! WordTableCell).ruTextField.text!
            UserDataModel.updateDupletTranslate(listName: nameOfSelectedList, oldDupletDict: oldTranslate, newTranslate: newTranslate)
            vocabruary = UserDataModel.getUserDuplets(userNamesOfLists: nameOfSelectedList) //получаем из базы обновленый спписок
            isEditingCellBegin = false
            segmentedControl.isEnabled = true
            tableView.reloadData()
        }
        return false
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        keyboardIsActive = true
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        keyboardIsActive = false
        return true
    }
    
    
}

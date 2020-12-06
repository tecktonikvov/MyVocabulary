//
//  ListViewController.swift
//  MyVocabulary
//
//  Created by Mac on 27.11.2020.
//

import UIKit
import RealmSwift

class ListViewController: UIViewController, KeyboardDetect {
//MARK: - IUOutlets
    
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var cancellBarButton: UIBarButtonItem!
    @IBOutlet weak var editBarButn: UIBarButtonItem!
    
//MARK: - Default setup
    var nameOfUserList: [String] = []
    var nameOfSelectedList = String()
    var indexOfEditCell: Int = 99999
    var maxCharsInListName: Int = 30
    var keyboardIsActive = false
    var isAddedNewListBegin = false
    var isEditingCellBegin = false
    var leftBarButton = UIBarButtonItem()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameOfUserList = UserDataModel.getUserList()
        tableView.tableFooterView = UIView()
        leftBarButton = navBar.leftBarButtonItem!
        registerForKeyboardNotification()
    }
    
    deinit {
        removeKeyboardNotifications()
    }
    
//MARK: - IBOActions
    @IBAction func addButtonAction(_ sender: UIButton) {
        indexOfEditCell = 0
        tableView.setContentOffset(.zero, animated: false)//Scroll to top of tableView
        nameOfUserList = nameOfUserList.reversed()
        nameOfUserList.append("")
        nameOfUserList = nameOfUserList.reversed()
        isAddedNewListBegin = true
        addButton.isEnabled = false
        tableView.reloadData()
        //print(tableView.cellForRow(at: IndexPath(row: 0, section: 0)))
        let newListCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! ListCell
        newListCell.listTextField.becomeFirstResponder()
        navBar.leftBarButtonItem = leftBarButton
    }
    
    @IBAction func editBarButnAction(_ sender: Any) {
        tableView.isEditing = !tableView.isEditing
        UserDataModel.updateIndexOfLists(userNamesOfLists: nameOfUserList)
    }
    
    @IBAction func cancellBarButnAction(_ sender: UIBarButtonItem) {
        cancellEdit()
    }
    
//MARK: - SWIPE Actions
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

      //Setup Delete Action
        let delete = UIContextualAction(style: .destructive, title: "Delete"){ [self] (action, view, completionHandler) in
            UserDataModel.deleteList(nameOfUserList: nameOfUserList[indexPath.row])
            nameOfUserList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .left)
            completionHandler(true)
        }
        delete.image = #imageLiteral(resourceName: "trashIcon")
      //Setup Edit Action
        let edit = UIContextualAction(style: .normal, title: "Edit"){ [self] (action, view, completionHandler) in
            indexOfEditCell = indexPath.row
            editBarButn.isEnabled = false
            isEditingCellBegin = true
            completionHandler(true)
            print("reload row edit action \(indexPath.row)")
            
            tableView.reloadRows(at: [indexPath], with: .right)
            let editCell = tableView.cellForRow(at: IndexPath(row: indexOfEditCell, section: 0)) as! ListCell
            editCell.listTextField.becomeFirstResponder()
            navBar.leftBarButtonItem = leftBarButton
        }
        edit.image = #imageLiteral(resourceName: "editIcon")
        
        let none = UISwipeActionsConfiguration(actions: [])
        let swipe = UISwipeActionsConfiguration(actions: [edit, delete])
        swipe.performsFirstActionWithFullSwipe = false

        if !keyboardIsActive {
            return swipe
        } else {
            return none
        }
    }

//MARK: - User input validate functions
    func validateInputWhenListCellEdit() {
        let editCell = tableView.cellForRow(at: IndexPath(row: indexOfEditCell, section: 0)) as! ListCell
        let oldNameList: String = nameOfUserList[indexOfEditCell]
        let newNameList: String = editCell.listTextField.text!
        let newNameIsNotLikeOld: Bool = oldNameList != newNameList
        
        nameOfUserList[indexOfEditCell] = ""
        if newNameIsNotLikeOld && nameOfUserList.contains(newNameList) { // если новое имя не такое как старое но уже существует
            showAllert(title: "Неверное имя", message: "Список с таким именем уже существует")
            nameOfUserList[indexOfEditCell] = oldNameList
            
        } else if !newNameIsNotLikeOld { // если такоеже как старое
            nameOfUserList[indexOfEditCell] = oldNameList // возращяем старое имя в массив
            isEditingCellBegin = false
            editCell.listTextField.endEditing(true)
            editBarButn.isEnabled = true
            keyboardIsActive = false
            addButton.isEnabled = true
            tableView.reloadRows(at: [IndexPath(row: indexOfEditCell, section: 0)], with: .none)

        } else {// если имя новое
            UserDataModel.updateListName(oldListName: oldNameList, newListName: newNameList) //меняем имя в записях в базе
            nameOfUserList[indexOfEditCell] = newNameList // добавляем новое имя в массив
            isEditingCellBegin = false
            editCell.listTextField.endEditing(true)
            editBarButn.isEnabled = true
            keyboardIsActive = false
            addButton.isEnabled = true
            tableView.reloadRows(at: [IndexPath(row: indexOfEditCell, section: 0)], with: .none)
        }
    }
    
    func validateInputWhenAddNewList() {
        let newCell = tableView.cellForRow(at: IndexPath(row: indexOfEditCell, section: 0)) as! ListCell
        let newNameList = newCell.listTextField.text!
        
        if nameOfUserList.contains(newNameList) { // если новое имя уже существует
            showAllert(title: "Неверное имя", message: "Список с таким именем уже существует")
            
        } else {
            nameOfUserList[0] = newNameList
            let dataModel = UserDataModel() // Create the data object and intialized and save it
            dataModel.nameOfUserList = nameOfUserList.first!
            dataModel.numberOfDuplet = 0
            UserDataModel.saveObject(saveObject: dataModel)
            isAddedNewListBegin = false
            newCell.listTextField.resignFirstResponder()
            tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
            addButton.isEnabled = true
            keyboardIsActive = false
            editBarButn.isEnabled = true
        }
    }
    
    func cancellEdit() {
        navBar.leftBarButtonItem = nil
        editBarButn.isEnabled = true
        keyboardIsActive = false
        addButton.isEnabled = true
        
        if isEditingCellBegin {
            isEditingCellBegin = false
            let editCell = tableView.cellForRow(at: IndexPath(row: indexOfEditCell, section: 0)) as! ListCell
            editCell.listTextField.endEditing(true)
            editCell.listTextField.resignFirstResponder()
            tableView.reloadRows(at: [IndexPath(row: indexOfEditCell, section: 0)], with: .none)
        }
        
        if isAddedNewListBegin {
            nameOfUserList.remove(at: 0)
            isAddedNewListBegin = false
            tableView.reloadData()
        }
    }
   
 //MARK: - Keyboard notofication
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
        let viewFrameHeight = Int(self.scrollView.frame.height)
        let rowIsUnderTheKeyboard: Bool = viewFrameHeight - (yPositionOfRow + 35) <= kbFrameSizeInt
        
        if isEditingCellBegin && rowIsUnderTheKeyboard {
            let kbFrameSize = (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue // получили значение фрейма клавиатуры
            scrollView.contentOffset = CGPoint(x: 0, y: kbFrameSize.height)
            tableView.scrollToRow(at: IndexPath(row: indexOfEditCell, section: 0), at: .bottom, animated: true)
        }
    }
    
    @objc func keyboardWillHide(){
        scrollView.contentOffset = CGPoint.zero
    }

// MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationController: MainViewController = segue.destination as! MainViewController
        destinationController.nameOfSelectedList = nameOfSelectedList
        removeKeyboardNotifications()
    }
    
// MARK: - MicroServices
    func showAllert(title: String, message: String) {
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in
        }
        alertView.addAction(ok)
        self.present(alertView, animated: true, completion:{
            alertView.view.superview?.isUserInteractionEnabled = true
        })
    }
}

extension ListViewController: UITableViewDelegate, UITableViewDataSource {
    //MARK: - Table view data source, dlegate
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navBar.leftBarButtonItem = nil
        
        // deselect the selected row if any
        let selectedRow: IndexPath? = tableView.indexPathForSelectedRow
        if let selectedRowNotNill = selectedRow {
            tableView.deselectRow(at: selectedRowNotNill, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        nameOfSelectedList = nameOfUserList[indexPath.row]
        return indexPath
    }
    
    func numberOfSections(in tableView: UITableView) -> Int { return 1 }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameOfUserList.count
    }
    //Make disable delete button in isEditing mode
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        UITableViewCell.EditingStyle.none
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Default setup cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath) as! ListCell
        let textField: UITextField = cell.listTextField
        
        textField.delegate = self
        cell.accessoryType = .disclosureIndicator
        cell.listCellLabel.text = nameOfUserList[indexPath.row]
        cell.listTextField.isHidden = true
        cell.listTextField.borderStyle = .none
        cell.listTextField.clearButtonMode = .always
        cell.listTextField.returnKeyType = .done
        cell.listCellLabel.isHidden = false
        editBarButn.isEnabled = true
        
        // Logic of edit cell creation
        if isEditingCellBegin || isAddedNewListBegin {
            if indexOfEditCell == indexPath.row {
                cell.accessoryType = .none
                cell.listCellLabel.isHidden = true
                cell.listTextField.isHidden = false
                cell.listTextField.text = nameOfUserList[indexPath.row]
                editBarButn.isEnabled = false
                cell.listTextField.becomeFirstResponder()
            }
        }
        if indexPath.row == nameOfUserList.count - 1 {
        }
        return cell
    }
    
    //MARK: - Override to support rearranging the table view.
    func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let elementToMove = nameOfUserList[fromIndexPath.row]
        nameOfUserList.remove(at: fromIndexPath.row)
        nameOfUserList.insert(elementToMove, at: to.row)
        print(nameOfUserList)
    }
    
    // Override to support conditional rearranging of the table view.
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
}

extension ListViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if isEditingCellBegin {
            validateInputWhenListCellEdit()
        }
        
        if isAddedNewListBegin {
            validateInputWhenAddNewList()
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

protocol KeyboardDetect {
    func registerForKeyboardNotification()
    func removeKeyboardNotifications()
}

<h1 align="center">MyVocabulary</h1>


<p align="center">

<img src="https://img.shields.io/badge/Made%20by-Kotsiubenko%20Volodymyr-brightgreen" >

<img src="https://img.shields.io/badge/API-Google%20translator-blue">

<img src="https://img.shields.io/badge/realm-10.0.0-blue">

<img src="https://img.shields.io/badge/swift%205-%20100%25-orange">

<img src="https://img.shields.io/badge/issues-2%20open-yellow">

</p>

## About the project.

Hello everyone, this is my first successful training project.
This is a dictionary - translator from English to Russian, which is based on simplicity and ease of use. It was designed for personal use and to help you learn English. Written in Swift 5, with a realm 10.0.0 database, and uses the Google translator API for translation


## Description

The application uses **UITableView**, and contains 2 views. The initial view controller name is: **ListViewController**, it represented as a UIViewController that contains a ScrollView that contains a TableView, the cells of which contain the names of the dictionary sheets that the user can add, delete, edit names and sort by dragging and dropping. 

<p align="center" > 
<img src="http://images.vfl.ru/ii/1607352116/e817489a/32582341.gif"></p>


User input has validation, and if the input is not correct, the user will see an Alert with a description of the error.
Deletion and editing implemented using UIContextualAction. 

<p align="center" > 
<img src="http://images.vfl.ru/ii/1607352116/76d809a0/32582342.gif"></p>

<p>Also implemented raising the TableView content after calling the keyboard to the height of the keyboard frame size

<p align="center" > 
<img src="http://images.vfl.ru/ii/1607352118/d958bd49/32582343.gif"></p>


When tapping on a cell, we go to the **MainViewController** which is an instance of the UITableViewController class.
It contains cells with pairs of words. The user can add, delete, drag and drop, edit Russian translation, and sort by English or Russian characters. 
Delete and edit actions are implemented using **UIContextualAction**.
There is also user input validation and content hoisting above the keyboard, just like in ListViewController

<p align="center" > 
<img src="http://images.vfl.ru/ii/1607352013/fe9cfbf5/32582318.gif"><img src="http://images.vfl.ru/ii/1607352075/201d77a1/32582334.gif"> </p>

## Issues
- Floating bug: Sometimes becomeFirstResponder fails.
- Add button in ListViewController hides when the swipe action starts and then does not appear

## Future scope
- Add sear in navigation controller
- Fix add button

//
//  ViewController.swift
//  currencyXML
//
//  Created by username on 20.09.2021.
//

import UIKit
import UserNotifications

class TableViewController: UITableViewController {

    static let shared = TableViewController()
    var currentValue: String?                // the current value for one of the keys in the dictionary
    var curValues: [String] = []
    var curValue = ""
    var curDates: [String] = []
    var elementName: String = String()
    var threshold = Double()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        if let threshold = Persistance.shared.threshold {
            self.threshold = threshold
            print(self.threshold)
        }
        else {
            self.threshold = 80.0
            Persistance.shared.threshold = 80.0
        }
        let network = Network()
        network.fetchData { (result) in
                switch result {
                case .success(let data):
                    self.updateUI(with: data)
                case .failure(let error):
                    print(error)
                }
        }
    }
    
    func updateUI(with data: Data) {
        
        let string = String(data: data, encoding: .windowsCP1251)
        print(string!)
        curDates = []
        for sent in string!.split(separator: " ") { //приходится вот так коряво вытаскивать даты, т.к. для них нет отдельной записи в XML
            if sent.contains("Date=") {
                let newDate = String(sent).replacingOccurrences(of: "Date=", with: "")
                curDates.append(newDate.replacingOccurrences(of: "\"", with: ""))
            }
        }
        DispatchQueue.main.async {
            let parser = XMLParser(data: data)
            parser.delegate = self
            parser.parse()
            
            self.tableView.reloadData()
            
            if let lastCurrVal = Double(self.curValues[self.curValues.count - 1].replacingOccurrences(of: ",", with: ".", options: .literal, range: nil)) {
                print(lastCurrVal)
                if lastCurrVal > self.threshold {
                    let center = UNUserNotificationCenter.current()
                    let content = UNMutableNotificationContent()
                    content.title = "Рубль рухнул!"
                    content.body = "Курс доллара превысил заданное пороговое значение!"
                    content.sound = UNNotificationSound.default
                    let trigger  = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
                    let request = UNNotificationRequest(identifier: "ThresholdNotification", content: content, trigger: trigger)
                    center.add(request)
                }
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.curValues.count//dayQty
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        var val = curValues[self.curValues.count - indexPath.row - 1]
        cell.detailTextLabel?.text = String(val)
        val = curDates[self.curValues.count - indexPath.row - 1]
        cell.textLabel?.text = val
        return cell
    }

}

extension TableViewController: XMLParserDelegate {

    func parserDidStartDocument(_ parser: XMLParser) {
        curValues = []
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
      
        if elementName == "Record" {
            curValue = ""
        }
        self.elementName = elementName
    }

    

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        
        let data = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if (!data.isEmpty) {
            if self.elementName == "Value" {
                curValue += data
            }
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        if elementName == "Record" {
            let value = curValue
            curValues.append(value)
        }
    }


    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print(parseError)
        currentValue = nil
    }

}


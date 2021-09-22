//
//  ViewController.swift
//  currencyXML
//
//  Created by username on 20.09.2021.
//

import UIKit
import UserNotifications
import BackgroundTasks
//var dayQty = 0
//let recordKey = "Record"
//let dictionaryKeys = Set<String>(["Nominal", "Value"])

// a few variables to hold the results as we parse the XML

//var results: [[String: String]]?         // the whole array of dictionaries
//var currentDictionary: [String: String]? // the current dictionary
//var currentValue: String?                // the current value for one of the keys in the dictionary
//var output: String = ""
//var value: [String] = []


class TableViewController: UITableViewController {

    var currentValue: String?                // the current value for one of the keys in the dictionary
    var curValues: [String] = []
    var curValue = ""
    var elementName: String = String()
    var threshold = Double()
    
    
    var dateFormater: DateFormatter = {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "dd/MM/yyyy"
        return dateFormater
    }()

/*
    func scheduleAppRefresh() {
       let request = BGAppRefreshTaskRequest(identifier: bgTaskIdentifier)
       // Fetch no earlier than 15 minutes from now.
       request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)
            
       do {
          try BGTaskScheduler.shared.submit(request)
       } catch {
          print("Could not schedule app refresh: \(error)")
       }
    }
   
    func handleAppRefresh(task: BGAppRefreshTask) {
       // Schedule a new refresh task.
       scheduleAppRefresh()

       // Create an operation that performs the main part of the background task.
       let operation = RefreshAppContentsOperation()
       
       // Provide the background task with an expiration handler that cancels the operation.
       task.expirationHandler = {
          operation.cancel()
       }

       // Inform the system that the background task is complete
       // when the operation completes.
       operation.completionBlock = {
          task.setTaskCompleted(success: !operation.isCancelled)
       }

       // Start the operation.
       OperationQueue.addOperation(operation)
     }
*/
    func fetchData(completion: @escaping (Result<Data, Error>) -> Void) {
        var urlComponents = URLComponents(string: "http://www.cbr.ru/scripts/XML_dynamic.asp")!
        
        let today = Date()
        let todayStr = dateFormater.string(from: today)
        let monthAgo = Calendar.current.date(byAdding: .month, value: -1, to: today)
        let monthAgoStr = dateFormater.string(from: monthAgo!)
        urlComponents.queryItems = [
            "date_req1": monthAgoStr,
            "date_req2": todayStr,
            "VAL_NM_RQ": "R01235"
        ].map { URLQueryItem(name: $0.key, value: $0.value)}
        
        let task = URLSession.shared.dataTask(with: urlComponents.url!) { (data,
           response, error) in
            if let data = data {
                do {
                    let string = try String(data: data, encoding: .windowsCP1251)
                    print(string!)
                    completion(.success(data))
                } catch {
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Persistance.shared.threshold = 75.0
        if let threshold = Persistance.shared.threshold {
            self.threshold = threshold
            print(self.threshold)
        }
        else {
            self.threshold = 80.0
            Persistance.shared.threshold = 80.0
        }
       
        fetchData { (result) in
                switch result {
                case .success(let data):
                    self.updateUI(with: data)
                case .failure(let error):
                    print(error)
                }
        }
    }
    
    func updateUI(with data: Data) {
        DispatchQueue.main.async {
            let parser = XMLParser(data: data)
            parser.delegate = self
            parser.parse()
            self.tableView.reloadData()
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
        let val = curValues[self.curValues.count - indexPath.row - 1]
        //let val = dayQty
        cell.detailTextLabel?.text = String(val)
        return cell
    }

}

extension TableViewController: XMLParserDelegate {

    // initialize results structure

    func parserDidStartDocument(_ parser: XMLParser) {
        //results = []
        curValues = []
    }

    // start element
    //
    // - If we're starting a "record" create the dictionary that will hold the results
    // - If we're starting one of our dictionary keys, initialize `currentValue` (otherwise leave `nil`)

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        /*
        if elementName == recordKey {
            currentDictionary = [:]
        } else if dictionaryKeys.contains(elementName) {
            currentValue = ""
        }*/
        if elementName == "Record" {
            curValue = ""//String()
        }
        self.elementName = elementName
    }

    // found characters
    //
    // - If this is an element we care about, append those characters.
    // - If `currentValue` still `nil`, then do nothing.

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        /*
        currentValue? += string*/
        let data = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if (!data.isEmpty) {
            if self.elementName == "Value" {
                curValue += data
            }
        }
    }

    // end element
    //
    // - If we're at the end of the whole dictionary, then save that dictionary in our array
    // - If we're at the end of an element that belongs in the dictionary, then save that value in the dictionary

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        /*
        if elementName == recordKey {
            results!.append(currentDictionary!)
            currentDictionary = nil
        } else if dictionaryKeys.contains(elementName) {
            currentDictionary![elementName] = currentValue
            currentValue = nil
        }*/
        if elementName == "Record" {
            let value = curValue
            curValues.append(value)
        }
    }

    // Just in case, if there's an error, report it. (We don't want to fly blind here.)

    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print(parseError)

        currentValue = nil
        //currentDictionary = nil
        //results = nil
        
    }

}


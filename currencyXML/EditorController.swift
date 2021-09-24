//
//  EditorController.swift
//  currencyXML
//
//  Created by username on 21.09.2021.
//

import UIKit

class EditorController: UITableViewController {

   
    @IBOutlet weak var thresholdText: UITextField!
    
    @IBAction func editingDidEndOnExit(_ sender: Any) {
        if let newTreshold = Double(thresholdText.text!) {
            Persistance.shared.threshold = newTreshold
            thresholdText.text = "\(newTreshold)"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let threshold = Persistance.shared.threshold
        thresholdText.text = "\(threshold!)"
        thresholdText.delegate = self
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

}

extension EditorController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if string.isNumber || (string == "." && !textField.text!.contains(".") && textField.text! != "") || string == "\n" {
            return true
        }
        return false
    }
}

extension String {
    var isNumber: Bool {
        return !isEmpty && rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
    }
}


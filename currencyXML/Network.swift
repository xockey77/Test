//
//  Nethwork.swift
//  currencyXML
//
//  Created by username on 20.09.2021.
//

import Foundation

class Network {
    
    var dateFormater: DateFormatter = {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "dd/MM/yyyy"
        return dateFormater
    }()

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
                    completion(.success(data))
                } catch {
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
}

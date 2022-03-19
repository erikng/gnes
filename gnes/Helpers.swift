//
//  HelperFunctions.swift
//  gnes
//
//  Created by Erik Gomez on 3/19/22.
//

import Foundation

// Functions

// Pretty print the config
func printConfig(configData: [String:Any]) {
    if CommandLine.arguments.contains("-stdout-enabled") {
        print("Cannot dump data to -stdout-enabled!")
        exit(1)
    } else if CommandLine.arguments.contains("-stdout-xml") {
        if dumpRaw {
            print("Cannot dump raw data to -stdout-xml!")
            exit(1)
        }
        do {
            let plistData = try PropertyListSerialization.data(fromPropertyList: configData, format: .xml, options: 0)
            let xmlPlistData = try XMLDocument.init(data: plistData, options: .nodePreserveAll)
            let prettyXMLData = xmlPlistData.xmlData(options: .nodePrettyPrint)
            let prettyXMLString = String(data: prettyXMLData, encoding: .utf8)
            print(prettyXMLString as AnyObject)
        } catch {
            print("issue with data!")
        }
    } else if CommandLine.arguments.contains("-stdout-json") {
        if dumpRaw {
            print("Cannot dump raw data to -stdout-json!")
            exit(1)
        }
        print(String(data: try! JSONSerialization.data(withJSONObject: configData, options: [.prettyPrinted, .sortedKeys]), encoding: .utf8)!)
    } else if CommandLine.arguments.contains("-stdout-raw") {
        print(configData)
    } else {
        print(configData as AnyObject)
    }
}

// Extensions to bridge functions that Swift doesn't natively do

// Convert Date to a String
extension Date
{
    func toString(dateFormat format: String) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}

// Return nil if a key does not exist in a Dictionary, rather than completely crash the app
// Comparable to aDictionary.get("something", None) in Python
extension NSObject {
    @objc
    func value(forUndefinedKey key: String) -> String? {
        nil
    }
}

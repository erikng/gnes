//
//  main.swift
//  gnes
//
//  Created by Erik Gomez on 3/4/22.
//

import AppKit
import Foundation
import NetworkExtension

var debug = false
var dump = false
var dumpRaw = false
var identifier = String()
var type = String()
var appConfig = [String:Any]()
var foundAppConfig = [String:Any]()
var payloadInfo = [String:Any]()
var providerInfo = [String:Any]()
var typeInfo = [String:Any]()
var dumpConfig = [String:Any]()
var foundIdentifiers = [String:Any]()
var foundContentFilterIdentifiers = [String]()
var foundDnsProxyIdentifiers = [String]()
var foundUnknownIdentifiers = [String]()
var foundVPNIdentifiers = [String]()

// TODO: support NEHotSpot and NEWifi?
// TODO: Return if more network extensions are installed vs what the admin expects to see. Useful for finding unapproved DNS or VPN modules
let helpInfo = """
NAME
     gnes – Get Network Extension Status

SYNOPSIS
     gnes -dump [-all -identifiers -raw] [-identifier %identifier%] [-type %type%] %output%

DESCRIPTION
     The gnes command is used to read and print network extension status

OPTIONS
     The options are as follows:

     -dump
             Optional: Returns requested data. Must be combined with sub-option. Can be combined with some optional outputs
                -all: Returns all found bundle identifier and their data. Can be combined with -stdout-json, -stdout-raw, -stdout-xml and None
                -identifiers: Returns all found bundle identifier. Can be combined with -stdout-json, -stdout-raw, -stdout-xml and None
                -raw: Returns all found data directly from NEConfiguration. Can be combined with -stdout-raw and None

     -identifier
             Required: The bundle identifier of the network extension to query

     -type
             Required: The type of the network extension to query. Needed due to multiple network extensions utilizing the same bundle identifier
                Allowed values: "contentFilter", "dnsProxy", "vpn"

     output
            Optional: Specific output formats:
                -stdout-enabled: Returns Network Extensions enabled status
                -stdout-json: Returns Network Extension(s) data in JSON format
                -stdout-raw: Returns Network Extension(s) data in raw Swift format
                -stdout-xml: Returns Network Extension(s) data in PLIST format
                None passed: Returns standard Network Extension(s) data in Swift printed format
"""

var arguments = CommandLine.arguments
arguments.removeFirst()
if arguments.isEmpty {
    print(helpInfo)
    exit(1)
}

if arguments.contains("-raw") {
    dumpRaw = true
}

let NetworkExtensionData = getAllNetworkExtensions()

if arguments.contains("-dump") {
    if arguments.contains("-all") {
        printConfig(configData: NetworkExtensionData)
        exit(0)
    } else if arguments.contains("-identifiers") {
        foundIdentifiers["contentFilter"] = foundContentFilterIdentifiers
        foundIdentifiers["dnsProxy"] = foundDnsProxyIdentifiers
        foundIdentifiers["vpn"] = foundVPNIdentifiers
        foundIdentifiers["unknown"] = foundUnknownIdentifiers
        printConfig(configData: foundIdentifiers)
        exit(0)
    } else if dumpRaw {
        printConfig(configData: NetworkExtensionData)
        exit(0)
    } else {
        print(helpInfo)
        exit(1)
    }
} else if arguments.contains("-identifier") && arguments.contains("-type") {
    let identifierArg = arguments.firstIndex(where: {$0 == "-identifier"})
    identifier = arguments[identifierArg! + 1]
    let typeArg = arguments.firstIndex(where: {$0 == "-type"})
    type = arguments[typeArg! + 1]
}

for (_, value) in NetworkExtensionData {
    let castedValue = value as! Dictionary<String, Any>
    if castedValue["application"] != nil {
        if castedValue["application"] as! String == identifier && castedValue["type"] as! String == type {
            if CommandLine.arguments.contains("-stdout-enabled") {
                print(castedValue["enabled"]!)
                exit(0)
            }
            printConfig(configData: castedValue)
            exit(0)
        }
    }
}

print("Did not find network extension!")
exit(1)

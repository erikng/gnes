//
//  main.swift
//  gnes
//
//  Created by Erik Gomez on 3/4/22.
//

import Foundation
import NetworkExtension
// TODO: SystemExtension data https://developer.apple.com/documentation/systemextensions/ossystemextensionmanager/3295261-sharedmanager?language=objc
import SystemExtensions
let sharedSEManager = OSSystemExtensionManager.self.shared

extension Date
{
    func toString(dateFormat format: String) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}

var identifier = ""
var type = ""
var appConfig = [:] as Dictionary
var payloadInfo = [:] as Dictionary
var providerInfo = [:] as Dictionary
var typeInfo = [:] as Dictionary
var foundIdentifiers = [:] as Dictionary
var foundContentFilterIdentifiers = [String]()
var foundDnsProxyIdentifiers = [String]()
var foundUnknownIdentifiers = [String]()
var foundVPNIdentifiers = [String]()
var debug = false
var enabled = false
var foundExtension = false
var rawConfig = NEConfiguration()

// TODO: support NEHotSpot and NEWifi?
// TODO: Return if more network extensions are installed vs what the admin expects to see. Useful for finding unapproved DNS or VPN modules
let helpInfo = """
NAME
     gnes – Get Network Extension Status

SYNOPSIS
     gnes -debug [-identifier identifier] [-type type] output

DESCRIPTION
     The gnes command is used to read and print network extension status

OPTIONS
     The options are as follows:

     -debug
             Optional: Returns all found bundle identifiers and type if passed identifier is not found

     -identifier
             Required: The bundle identifier of the network extension to query

     -type
             Required: The type of network extension you are querying. Needed when an application installs multiple network extensions with the same bundle identifier
                "contentFilter", "dnsProxy", "vpn"

     output
            Optional: Specific output formats:
                -stdout-xml -stdout-json -stdout-enabled -stdout-raw
"""

let arguments = CommandLine.arguments

if arguments.contains("-identifier") && arguments.contains("-type") {
    let identifierArg = arguments.firstIndex(where: {$0 == "-identifier"})
    identifier = arguments[identifierArg! + 1]
    let typeArg = arguments.firstIndex(where: {$0 == "-type"})
    type = arguments[typeArg! + 1]
} else {
    print(helpInfo)
    exit(1)
}

if arguments.contains("-debug") {
    debug = true
}

let sharedManager = NEConfigurationManager.self.shared()
_ = sharedManager?.reloadFromDisk()
let loadedConfigurations = sharedManager?.loadedConfigurations
if loadedConfigurations != nil {
    for (_, value) in loadedConfigurations! as NSDictionary {
        let config = value as! NEConfiguration
        if debug {
            if config.contentFilter != nil {
                foundContentFilterIdentifiers.append(config.application)
            } else if config.dnsProxy != nil {
                foundDnsProxyIdentifiers.append(config.application)
            } else if config.vpn != nil {
                foundVPNIdentifiers.append(config.application)
            } else {
                foundUnknownIdentifiers.append(config.application)
            }
        }
        if config.application == identifier && !foundExtension {
            rawConfig = config
            if (config.contentFilter != nil) && type != "contentFilter" {
                continue
            } else if (config.dnsProxy != nil) && type != "dnsProxy" {
                continue
            } else if (config.vpn != nil) && type != "vpn" {
                continue
            }
            foundExtension = true
            appConfig["application"] = config.application
            appConfig["applicationName"] = config.applicationName
            appConfig["grade"] = config.grade
            appConfig["identifier"] = config.identifier.uuidString
            appConfig["name"] = config.name
            if (config.contentFilter != nil) {
                appConfig["type"] = "contentFilter"
                providerInfo["pluginType"] = config.contentFilter.provider.value(forKeyPath: "pluginType")
                providerInfo["dataProviderDesignatedRequirement"] = config.contentFilter.provider.value(forKeyPath: "dataProviderDesignatedRequirement")
                providerInfo["dataProviderBundleIdentifier"] = config.contentFilter.provider.filterDataProviderBundleIdentifier
                providerInfo["packetProviderBundleIdentifier"] = config.contentFilter.provider.filterPacketProviderBundleIdentifier
                providerInfo["organization"] = config.contentFilter.provider.organization
                providerInfo["filterPackets"] = config.contentFilter.provider.filterPackets
                providerInfo["filterSockets"] = config.contentFilter.provider.filterSockets
                providerInfo["preserveExistingConnections"] = (config.contentFilter.provider.value(forKeyPath: "preserveExistingConnections") as! Int != 0)
                typeInfo["provider"] = providerInfo
                enabled = (config.contentFilter.enabled != 0)
                typeInfo["enabled"] = (config.contentFilter.enabled != 0)
                typeInfo["filterGrade"] = config.contentFilter.grade
                appConfig["contentFilter"] = typeInfo
            } else if (config.dnsProxy != nil) {
                appConfig["type"] = "dnsProxy"
                // dnsProxy = type 6
                providerInfo["type"] = config.dnsProxy.protocol.value(forKeyPath: "type")
                providerInfo["identifier"] = (config.dnsProxy.protocol.value(forKeyPath: "identifier") as! UUID).uuidString
                providerInfo["identityDataImported"] = (config.dnsProxy.protocol.value(forKeyPath: "identityDataImported") as! Bool)
                providerInfo["disconnectOnSleep"] = config.dnsProxy.protocol.disconnectOnSleep
                providerInfo["disconnectOnIdle"] = (config.dnsProxy.protocol.value(forKeyPath: "disconnectOnIdle") as! Bool)
                providerInfo["disconnectOnIdleTimeout"] = (config.dnsProxy.protocol.value(forKeyPath: "disconnectOnIdleTimeout") as! Bool)
                providerInfo["disconnectOnWake"] = (config.dnsProxy.protocol.value(forKeyPath: "disconnectOnWake") as! Bool)
                providerInfo["disconnectOnWakeTimeout"] = (config.dnsProxy.protocol.value(forKeyPath: "disconnectOnWakeTimeout") as! Bool)
                providerInfo["disconnectOnUserSwitch"] = (config.dnsProxy.protocol.value(forKeyPath: "disconnectOnUserSwitch") as! Bool)
                providerInfo["disconnectOnLogout"] = (config.dnsProxy.protocol.value(forKeyPath: "disconnectOnLogout") as! Bool)
                providerInfo["includeAllNetworks"] = config.dnsProxy.protocol.includeAllNetworks
                providerInfo["excludeLocalNetworks"] = config.dnsProxy.protocol.excludeLocalNetworks
                providerInfo["enforceRoutes"] = config.dnsProxy.protocol.enforceRoutes
                providerInfo["pluginType"] = config.dnsProxy.protocol.value(forKeyPath: "pluginType")
                providerInfo["designatedRequirement"] = config.dnsProxy.protocol.providerBundleIdentifier
                providerInfo["designatedRequirement"] = config.dnsProxy.protocol.value(forKeyPath: "designatedRequirement")
                typeInfo["protocol"] = providerInfo
                typeInfo["enabled"] = (config.dnsProxy.enabled != 0)
                enabled = (config.dnsProxy.enabled != 0)
                appConfig["dnsProxy"] = typeInfo
            } else if (config.vpn != nil) {
                appConfig["type"] = "vpn"
                // app-proxy = type 4
                providerInfo["type"] = config.vpn.protocol.value(forKeyPath: "type")
                providerInfo["identifier"] = (config.vpn.protocol.value(forKeyPath: "identifier") as! UUID).uuidString
                providerInfo["serverAddress"] = config.vpn.protocol.serverAddress
                providerInfo["identityDataImported"] = (config.vpn.protocol.value(forKeyPath: "identityDataImported") as! Bool)
                providerInfo["disconnectOnSleep"] = config.vpn.protocol.disconnectOnSleep
                providerInfo["disconnectOnIdle"] = (config.vpn.protocol.value(forKeyPath: "disconnectOnIdle") as! Bool)
                providerInfo["disconnectOnIdleTimeout"] = (config.vpn.protocol.value(forKeyPath: "disconnectOnIdleTimeout") as! Bool)
                providerInfo["disconnectOnWake"] = (config.vpn.protocol.value(forKeyPath: "disconnectOnWake") as! Bool)
                providerInfo["disconnectOnWakeTimeout"] = (config.vpn.protocol.value(forKeyPath: "disconnectOnWakeTimeout") as! Bool)
                providerInfo["disconnectOnUserSwitch"] = (config.vpn.protocol.value(forKeyPath: "disconnectOnUserSwitch") as! Bool)
                providerInfo["disconnectOnLogout"] = (config.vpn.protocol.value(forKeyPath: "disconnectOnLogout") as! Bool)
                providerInfo["includeAllNetworks"] = config.vpn.protocol.includeAllNetworks
                providerInfo["excludeLocalNetworks"] = config.vpn.protocol.excludeLocalNetworks
                providerInfo["enforceRoutes"] = config.vpn.protocol.enforceRoutes
                providerInfo["pluginType"] = config.vpn.protocol.value(forKeyPath: "pluginType")
                providerInfo["authenticationMethod"] = config.vpn.protocol.value(forKeyPath: "authenticationMethod")
                providerInfo["reassertTimeout"] = config.vpn.protocol.value(forKeyPath: "reassertTimeout")
                providerInfo["providerBundleIdentifier"] = config.vpn.protocol.value(forKeyPath: "providerBundleIdentifier")
                providerInfo["designatedRequirement"] = config.vpn.protocol.value(forKeyPath: "designatedRequirement")
                typeInfo["protocol"] = providerInfo
                
                typeInfo["enabled"] = (config.vpn.enabled != 0)
                enabled = (config.vpn.enabled != 0)
                typeInfo["onDemandEnabled"] = (config.vpn.onDemandEnabled != 0)
                typeInfo["disconnectOnDemandEnabled"] = (config.vpn.disconnectOnDemandEnabled != 0)
                typeInfo["onDemandUserOverrideDisabled"] = (config.vpn.onDemandUserOverrideDisabled != 0)
                appConfig["VPN"] = typeInfo
            }
            if (config.payloadInfo != nil) {
                payloadInfo["payloadUUID"] = config.payloadInfo.payloadUUID
                payloadInfo["payloadOrganization"] = config.payloadInfo.payloadOrganization
                payloadInfo["profileUUID"] = config.payloadInfo.profileUUID
                payloadInfo["profileIdentifier"] = config.payloadInfo.profileIdentifier
                payloadInfo["isSetAside"] = (config.payloadInfo.isSetAside != 0)
                payloadInfo["profileIngestionDate"] = (config.payloadInfo.profileIngestionDate.toString(dateFormat: "yyyy-MM-dd HH:mm:ss Z"))
                payloadInfo["systemVersion"] = config.payloadInfo.systemVersion
                if config.payloadInfo.profileSource == 2 {
                    payloadInfo["profileSource"] = "mdm"
                } else {
                    payloadInfo["profileSource"] = config.payloadInfo.profileSource
                }
                appConfig["payloadInfo"] = payloadInfo
            }
        }
    }
} else {
    print("Could not load configurations from disk!")
    exit(1)
}
if !appConfig.isEmpty {
    if CommandLine.arguments.contains("-stdout-xml") {
        let plistData = try PropertyListSerialization.data(fromPropertyList: appConfig, format: .xml, options: 0)
        let xmlPlistData = try XMLDocument.init(data: plistData, options: .nodePreserveAll)
        let prettyXMLData = xmlPlistData.xmlData(options: .nodePrettyPrint)
        let prettyXMLString = String(data: prettyXMLData, encoding: .utf8)
        print(prettyXMLString as AnyObject)
    } else if CommandLine.arguments.contains("-stdout-json") {
        print(String(data: try! JSONSerialization.data(withJSONObject: appConfig, options: [.prettyPrinted, .sortedKeys]), encoding: .utf8)!)
    } else if CommandLine.arguments.contains("-stdout-enabled") {
        print(enabled)
    } else if CommandLine.arguments.contains("-stdout-raw") {
        print(rawConfig)
    } else {
        print(appConfig as AnyObject)
    }
} else {
    if debug {
        print("Did not find network extension!")
        foundIdentifiers["contentFilter"] = foundContentFilterIdentifiers
        foundIdentifiers["dnsProxy"] = foundDnsProxyIdentifiers
        foundIdentifiers["vpn"] = foundVPNIdentifiers
        foundIdentifiers["unknown"] = foundUnknownIdentifiers
        print(String(data: try! JSONSerialization.data(withJSONObject: foundIdentifiers, options: [.prettyPrinted, .sortedKeys]), encoding: .utf8)!)
    } else {
        print("Did not find network extension!")
    }
}

//if let NetworkExtensionBundle = Bundle(path: "/System/Library/Frameworks/NetworkExtension.framework") {
//    let NEConfigurationManager: AnyClass? = NetworkExtensionBundle.classNamed("NEConfigurationManager")
//    let sharedManager = NEConfigurationManager?.sharedManager() as AnyObject?
//    _ = sharedManager?.reloadFromDisk()
//    let loadedConfigurations = sharedManager?.loadedConfigurations as! NSDictionary
//    for (key, value) in loadedConfigurations {
//        let config = value as! NEConfiguration
//        let application = config.application
//        if application == identifier {
//            enabled = (config.contentFilter.enabled != 0)
//        }
//    }
//}

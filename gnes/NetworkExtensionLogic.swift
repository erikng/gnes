//
//  NetworkExtensionLogic.swift
//  gnes
//
//  Created by Erik Gomez on 3/19/22.
//

import Foundation
import NetworkExtension

func getAllNetworkExtensions() -> [String:Any] {
    let sharedManager = NEConfigurationManager.self.shared()
    _ = sharedManager?.reloadFromDisk()
    let loadedConfigurations = sharedManager?.loadedConfigurations
    if loadedConfigurations != nil {
        for (key, value) in loadedConfigurations! as NSDictionary {
            // reset these keys every time to properly capture
            appConfig = [:]
            providerInfo = [:]
            typeInfo = [:]
            var rawConfig = NEConfiguration()
            let config = value as! NEConfiguration
            
            // Base values for all Network Extensions
            appConfig["application"] = config.application
            appConfig["applicationName"] = config.applicationName
            appConfig["grade"] = config.grade
            appConfig["identifier"] = config.identifier.uuidString
            appConfig["name"] = config.name
            
            // Base values for all Network Extensions that have MDM profile information
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
            
            // Values for specific Network Extensions
            if (config.contentFilter != nil) { // contentFilter Extensions
                foundContentFilterIdentifiers.append(config.application)
                appConfig["type"] = "contentFilter"
                providerInfo["pluginType"] = config.contentFilter.provider.value(forKeyPath: "pluginType")
                if let dataProviderDesignatedRequirement = config.contentFilter.provider.value(forKeyPath: "dataProviderDesignatedRequirement") {
                    providerInfo["dataProviderDesignatedRequirement"] = dataProviderDesignatedRequirement
                }
                providerInfo["dataProviderBundleIdentifier"] = config.contentFilter.provider.filterDataProviderBundleIdentifier
                providerInfo["packetProviderBundleIdentifier"] = config.contentFilter.provider.filterPacketProviderBundleIdentifier
                providerInfo["organization"] = config.contentFilter.provider.organization
                providerInfo["filterPackets"] = config.contentFilter.provider.filterPackets
                providerInfo["filterSockets"] = config.contentFilter.provider.filterSockets
                if let preserveExistingConnections = config.contentFilter.provider.value(forKeyPath: "preserveExistingConnections") {
                    providerInfo["preserveExistingConnections"] = (preserveExistingConnections as! Int != 0)
                }
                typeInfo["provider"] = providerInfo
                typeInfo["enabled"] = (config.contentFilter.enabled != 0)
                typeInfo["filterGrade"] = config.contentFilter.grade
                appConfig["enabled"] = (config.contentFilter.enabled != 0)
                appConfig["contentFilter"] = typeInfo
            } else if (config.dnsProxy != nil) { // dnsProxy Extensions
                foundDnsProxyIdentifiers.append(config.application)
                appConfig["type"] = "dnsProxy"
                // dnsProxy = type 6
                if let type = config.dnsProxy.protocol.value(forKeyPath: "type") {
                    providerInfo["type"] = type
                }
                if let identifier = config.dnsProxy.protocol.value(forKeyPath: "identifier") {
                    providerInfo["identifier"] = (identifier as! UUID).uuidString
                }
                if let identityDataImported = config.dnsProxy.protocol.value(forKeyPath: "identityDataImported") {
                    providerInfo["identityDataImported"] = (identityDataImported as! Bool)
                }
                providerInfo["disconnectOnSleep"] = config.dnsProxy.protocol.disconnectOnSleep
                if let disconnectOnIdle = config.dnsProxy.protocol.value(forKeyPath: "disconnectOnIdle") {
                    providerInfo["disconnectOnIdle"] = (disconnectOnIdle as! Bool)
                }
                if let disconnectOnIdleTimeout = config.dnsProxy.protocol.value(forKeyPath: "disconnectOnIdleTimeout") {
                    providerInfo["disconnectOnIdleTimeout"] = (disconnectOnIdleTimeout as! Int)
                }
                if let disconnectOnWake = config.dnsProxy.protocol.value(forKeyPath: "disconnectOnWake") {
                    providerInfo["disconnectOnWake"] = (disconnectOnWake as! Bool)
                }
                if let disconnectOnWakeTimeout = config.dnsProxy.protocol.value(forKeyPath: "disconnectOnWakeTimeout") {
                    providerInfo["disconnectOnWakeTimeout"] = (disconnectOnWakeTimeout as! Int)
                }
                if let disconnectOnUserSwitch = config.dnsProxy.protocol.value(forKeyPath: "disconnectOnUserSwitch") {
                    providerInfo["disconnectOnUserSwitch"] = (disconnectOnUserSwitch as! Bool)
                }
                if let disconnectOnLogout = config.dnsProxy.protocol.value(forKeyPath: "disconnectOnLogout") {
                    providerInfo["disconnectOnLogout"] = (disconnectOnLogout as! Bool)
                }
                providerInfo["includeAllNetworks"] = config.dnsProxy.protocol.includeAllNetworks
                providerInfo["excludeLocalNetworks"] = config.dnsProxy.protocol.excludeLocalNetworks
                providerInfo["enforceRoutes"] = config.dnsProxy.protocol.enforceRoutes
                if let pluginType = config.dnsProxy.protocol.value(forKeyPath: "pluginType") {
                    providerInfo["pluginType"] = pluginType
                }
                providerInfo["designatedRequirement"] = config.dnsProxy.protocol.providerBundleIdentifier
                if let designatedRequirement = config.dnsProxy.protocol.value(forKeyPath: "designatedRequirement") {
                    providerInfo["designatedRequirement"] = designatedRequirement
                }
                typeInfo["protocol"] = providerInfo
                typeInfo["enabled"] = (config.dnsProxy.enabled != 0)
                appConfig["enabled"] = (config.dnsProxy.enabled != 0)
                appConfig["dnsProxy"] = typeInfo
            } else if (config.vpn != nil) { // VPN Extensions
                foundVPNIdentifiers.append(config.application)
                appConfig["type"] = "vpn"
                // app-proxy = type 4
                if let type = config.vpn.protocol.value(forKeyPath: "type") {
                    providerInfo["type"] = type
                }
                if let identifier = config.vpn.protocol.value(forKeyPath: "identifier") {
                    providerInfo["identifier"] = (identifier as! UUID).uuidString
                }
                providerInfo["serverAddress"] = config.vpn.protocol.serverAddress
                if let identityDataImported = config.vpn.protocol.value(forKeyPath: "identityDataImported") {
                    providerInfo["identityDataImported"] = (identityDataImported as! Bool)
                }
                providerInfo["disconnectOnSleep"] = config.vpn.protocol.disconnectOnSleep
                if let disconnectOnIdle = config.vpn.protocol.value(forKeyPath: "disconnectOnIdle") {
                    providerInfo["disconnectOnIdle"] = (disconnectOnIdle as! Bool)
                }
                if let disconnectOnIdleTimeout = config.vpn.protocol.value(forKeyPath: "disconnectOnIdleTimeout") {
                    providerInfo["disconnectOnIdleTimeout"] = (disconnectOnIdleTimeout as! Int)
                }
                if let disconnectOnWake = config.vpn.protocol.value(forKeyPath: "disconnectOnWake") {
                    providerInfo["disconnectOnWake"] = (disconnectOnWake as! Bool)
                }
                if let disconnectOnWakeTimeout = config.vpn.protocol.value(forKeyPath: "disconnectOnWakeTimeout") {
                    providerInfo["disconnectOnWakeTimeout"] = (disconnectOnWakeTimeout as! Int)
                }
                if let disconnectOnUserSwitch = config.vpn.protocol.value(forKeyPath: "disconnectOnUserSwitch") {
                    providerInfo["disconnectOnUserSwitch"] = (disconnectOnUserSwitch as! Bool)
                }
                if let disconnectOnLogout = config.vpn.protocol.value(forKeyPath: "disconnectOnLogout") {
                    providerInfo["disconnectOnLogout"] = (disconnectOnLogout as! Bool)
                }
                providerInfo["includeAllNetworks"] = config.vpn.protocol.includeAllNetworks
                providerInfo["excludeLocalNetworks"] = config.vpn.protocol.excludeLocalNetworks
                providerInfo["enforceRoutes"] = config.vpn.protocol.enforceRoutes
                if let pluginType = config.vpn.protocol.value(forKeyPath: "pluginType") {
                    providerInfo["pluginType"] = pluginType
                }
                if let authenticationMethod = config.vpn.protocol.value(forKeyPath: "authenticationMethod") {
                    providerInfo["authenticationMethod"] = authenticationMethod
                }
                if let reassertTimeout = config.vpn.protocol.value(forKeyPath: "reassertTimeout") {
                    providerInfo["reassertTimeout"] = reassertTimeout
                }
                if let providerBundleIdentifier = config.vpn.protocol.value(forKeyPath: "providerBundleIdentifier") {
                    providerInfo["providerBundleIdentifier"] = providerBundleIdentifier
                }
                if let designatedRequirement = config.vpn.protocol.value(forKeyPath: "designatedRequirement") {
                    providerInfo["designatedRequirement"] = designatedRequirement
                }
                typeInfo["protocol"] = providerInfo
                typeInfo["enabled"] = (config.vpn.enabled != 0)
                typeInfo["onDemandEnabled"] = (config.vpn.onDemandEnabled != 0)
                typeInfo["disconnectOnDemandEnabled"] = (config.vpn.disconnectOnDemandEnabled != 0)
                typeInfo["onDemandUserOverrideDisabled"] = (config.vpn.onDemandUserOverrideDisabled != 0)
                appConfig["enabled"] = (config.vpn.enabled != 0)
                appConfig["VPN"] = typeInfo
            } else { // Unknown Extensions
                foundUnknownIdentifiers.append(config.application)
            }
            if dumpRaw {
                dumpConfig[(key as! UUID).uuidString] = value
            } else {
                dumpConfig[(key as! UUID).uuidString] = appConfig
            }
        }
    } else {
        print("Could not load Network Extension configurations!")
        exit(1)
    }
    return dumpConfig
}
